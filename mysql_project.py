"""Load the supplied IPL project into MySQL 8 and run its existing analysis."""
from pathlib import Path
import argparse, csv, getpass, json, os, re, shutil, sys
import pandas as pd
import pymysql

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'mysql_output'
FACTORS = [2.1229721486,1.9370183837,1.7455333727,1.6363863999,1.5598002096,1.4923461630,1.4442525530,1.3893723453,1.3261165843,1.2437784508,1.1830861323,1.10879675,1.0495]

def quote(s):
    return '`' + s.replace('`','``') + '`'

def config():
    f=ROOT/'mysql_config.json'
    if not f.exists():
        raise RuntimeError('Copy mysql_config.example.json to mysql_config.json first (see START_HERE.md).')
    c=json.loads(f.read_text(encoding='utf-8-sig'))
    if not re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*',c.get('database','')):
        raise RuntimeError('Database name must start with a letter and contain only letters, numbers and underscores.')
    c['password'] = os.environ['IPL_MYSQL_PASSWORD'] if 'IPL_MYSQL_PASSWORD' in os.environ else (c.get('password') or getpass.getpass('MySQL password: '))
    return c

def connect(c, database=True):
    conn=pymysql.connect(host=c.get('host','127.0.0.1'),port=int(c.get('port',3306)),user=c.get('user','root'),password=c['password'],database=c['database'] if database else None,charset='utf8mb4',autocommit=False,connect_timeout=15)
    with conn.cursor() as cur:
        cur.execute('SELECT VERSION()');v=cur.fetchone()[0]
        if 'MariaDB' in v or int(v.split('.')[0])<8:
            raise RuntimeError('This project requires Oracle MySQL 8.0 or 8.4. Server reports '+v)
    return conn

def inputs():
    files=[ROOT/'matches.csv',ROOT/'deliveries.csv',ROOT/'auctions_final.csv']
    files+=sorted(f for f in ROOT.glob('*.csv') if f not in files)
    files+=sorted((ROOT/'auction roi').glob('*.csv'))
    files+=[ROOT/'IPL auction data till 2025/data.csv']
    return [(f, 'auction_source_data' if f.name=='data.csv' else re.sub('[^a-z0-9_]+','_',f.stem.lower()).strip('_')) for f in files]

def frame(f):
    df=pd.read_csv(f,low_memory=False)
    df=df.loc[:,~df.columns.str.match(r'^Unnamed:')]
    if f.name=='matches.csv':df['date']=pd.to_datetime(df['date'],dayfirst=True).dt.date
    return df

def ddl(table,df):
    columns=[]
    for name in df.columns:
        dtype=df[name].dtype
        if table=='matches' and name=='date':typ='DATE'
        elif pd.api.types.is_integer_dtype(dtype):typ='BIGINT'
        elif pd.api.types.is_numeric_dtype(dtype):typ='DOUBLE'
        else:typ='VARCHAR(512)'
        required = (table=='matches' and name=='match_id') or (table=='deliveries' and name in ['match_id','inning','over','ball']) or (table=='auctions_final' and name=='id')
        columns.append(f'{quote(name)} {typ} '+('NOT NULL' if required else 'NULL'))
    if table=='matches':
        columns += ['PRIMARY KEY (`match_id`)',
          "`defending_team` VARCHAR(512) GENERATED ALWAYS AS (CASE WHEN toss_decision='bat' THEN toss_winner WHEN toss_winner=team1 THEN team2 ELSE team1 END) STORED",
          "`chasing_team` VARCHAR(512) GENERATED ALWAYS AS (CASE WHEN toss_decision='field' THEN toss_winner WHEN toss_winner=team1 THEN team2 ELSE team1 END) STORED"]
    if table=='deliveries':columns+=['PRIMARY KEY (`match_id`,`inning`,`over`,`ball`)', 'FOREIGN KEY (`match_id`) REFERENCES `matches` (`match_id`)']
    if table=='auctions_final':columns+=['PRIMARY KEY (`id`)','INDEX `player_year` (`name`(100),`year`)']
    return 'CREATE TABLE '+quote(table)+' (\n  '+',\n  '.join(columns)+'\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;'

def load_table(conn,table,df):
    with conn.cursor() as cur:
        cur.execute(ddl(table,df))
        q='INSERT INTO '+quote(table)+' ('+','.join(map(quote,df.columns))+') VALUES ('+','.join(['%s']*len(df.columns))+')'
        rows=df.astype(object).where(pd.notnull(df),None).values.tolist()
        for i in range(0,len(rows),2000):cur.executemany(q,rows[i:i+2000])
    conn.commit()
    print(f'Loaded {table}: {len(df):,} rows',flush=True)

VIEW = '''CREATE VIEW auctions_dedup AS SELECT * FROM
(SELECT a.*, ROW_NUMBER() OVER (PARTITION BY name,year ORDER BY id DESC) AS dedup_row FROM auctions_final a) t
WHERE dedup_row=1'''

def setup(c,replace=False):
    conn=connect(c,False)
    with conn.cursor() as cur:
        cur.execute('CREATE DATABASE IF NOT EXISTS '+quote(c['database'])+' CHARACTER SET utf8mb4 COLLATE utf8mb4_bin')
        cur.execute('USE '+quote(c['database']))
        cur.execute('SHOW TABLES'); existing={r[0] for r in cur.fetchall()}
        if existing and not replace:
            raise RuntimeError('Database already contains tables. Use check/queries/analysis, or setup --replace to reload this project in its dedicated database.')
        if existing:
            cur.execute('DROP VIEW IF EXISTS auctions_dedup')
            cur.execute('SET FOREIGN_KEY_CHECKS=0')
            for _,t in inputs():cur.execute('DROP TABLE IF EXISTS '+quote(t))
            for t in ['cpi','venue_mapping','team_home_venues']:cur.execute('DROP TABLE IF EXISTS '+quote(t))
            cur.execute('SET FOREIGN_KEY_CHECKS=1')
    for f,t in inputs():load_table(conn,t,frame(f))
    with conn.cursor() as cur:
        cur.execute('CREATE TABLE cpi (`year` INT PRIMARY KEY, inflation DOUBLE, factor_to_2025 DOUBLE)')
        cur.executemany('INSERT INTO cpi VALUES (%s,%s,%s)',[(y,x,x) for y,x in zip(range(2013,2026),FACTORS)])
        cur.execute(VIEW)
        for item in json.loads((ROOT/'mysql/query_manifest.json').read_text()):
            if item['kind'] in ['CREATE','INSERT']:cur.execute((ROOT/'mysql/queries'/item['file']).read_text())
    conn.commit();conn.close()
    print('SETUP PASSED. Original CSV files were not overwritten.')

def checks(c):
    conn=connect(c); report={}
    with conn.cursor() as cur:
        for f,t in inputs():
            cur.execute('SELECT COUNT(*) FROM '+quote(t));n=cur.fetchone()[0]; expected=len(frame(f))
            if n!=expected:raise RuntimeError(f'{t}: expected {expected}, found {n}')
            report[t]=n
        cur.execute('SELECT COUNT(*) FROM deliveries d LEFT JOIN matches m ON m.match_id=d.match_id WHERE m.match_id IS NULL')
        if cur.fetchone()[0]:raise RuntimeError('Orphan deliveries found')
        cur.execute('SELECT COUNT(*),MIN(season),MAX(season) FROM matches');report['matches_summary']=cur.fetchone()
        cur.execute('SELECT COUNT(*) FROM auctions_dedup');report['dedup_rows']=cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM matches WHERE defending_team=chasing_team OR defending_team IS NULL OR chasing_team IS NULL")
        if cur.fetchone()[0]:raise RuntimeError('Chasing/defending team derivation failed')
        cur.execute((ROOT/'look.sql').read_text());report['look_query_rows']=len(cur.fetchall())
    conn.close();OUT.mkdir(exist_ok=True);(OUT/'database_checks.json').write_text(json.dumps(report,indent=2,default=str))
    print('DATABASE CHECKS PASSED:',report['matches_summary'], 'deliveries:',report['deliveries'])

def queries(c):
    OUT.mkdir(exist_ok=True); conn=connect(c); results=[]
    with conn.cursor() as cur:
        for item in json.loads((ROOT/'mysql/query_manifest.json').read_text()):
            if item['kind'] not in ['SELECT','WITH']:continue
            sql=(ROOT/'mysql/queries'/item['file']).read_text()
            cur.execute(sql);rows=cur.fetchall();headers=[d[0] for d in cur.description]
            name=item['export'] or item['file'].replace('.sql','.csv')
            with (OUT/name).open('w',newline='',encoding='utf-8') as f:
                w=csv.writer(f);w.writerow(headers);w.writerows(rows)
            results.append({'query':item['file'],'file':name,'rows':len(rows)})
            print(item['file'],len(rows),'rows ->',name,flush=True)
    conn.close();(OUT/'query_results.json').write_text(json.dumps(results,indent=2))
    print('ALL SELECT QUERIES PASSED. CSVs are in mysql_output.')

def analysis():
    OUT.mkdir(exist_ok=True)
    # Isolated working directory keeps all supplied CSVs intact.
    for f in ROOT.glob('*.csv'):
        if not (OUT/f.name).exists():shutil.copy2(f,OUT/f.name)
    (OUT/'auction roi').mkdir(exist_ok=True)
    for f in (ROOT/'auction roi').glob('*.csv'):
        source=OUT/f.name if (OUT/f.name).exists() else f
        shutil.copy2(source,OUT/'auction roi'/f.name)
    start=Path.cwd()
    try:
        os.chdir(OUT)
        for name in ['framework.ipynb','team roi.ipynb']:
            nb=json.loads((ROOT/name).read_text());namespace={'__name__':'__main__'}
            for i,cell in enumerate(nb['cells']):
                if cell['cell_type']!='code':continue
                source=''.join(cell['source'])
                try:exec(compile(source,f'{name}:cell {i}','exec'),namespace)
                except Exception as e:raise RuntimeError(f'{name}, cell {i}: {e}') from e
            print('NOTEBOOK PASSED:',name,flush=True)
    finally:os.chdir(start)
    print('ANALYSIS PASSED. Recomputed CSVs and workbook are in mysql_output.')

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('command',choices=['setup','check','queries','analysis','run'])
    ap.add_argument('--replace',action='store_true',help='Reload this project\'s tables in the configured dedicated database')
    args=ap.parse_args()
    try:
        if args.command=='analysis':analysis();return
        c=config()
        if args.command in ['setup','run']:setup(c,args.replace)
        if args.command in ['check','run']:checks(c)
        if args.command in ['queries','run']:queries(c)
        if args.command=='run':analysis()
    except Exception as e:
        print('FAILED:',str(e),file=sys.stderr);sys.exit(1)
if __name__=='__main__':main()
