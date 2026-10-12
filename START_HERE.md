# IPL project — MySQL setup (Windows)

The original datasets, analysis, dashboard designs, JSON match files, and reports are retained. The PostgreSQL queries have been converted to MySQL. Python loads the CSVs and exports query results, so you do not need PostgreSQL, server-side CSV paths, or MySQL FILE privileges.

## 1. Install and check the software

- Install Oracle MySQL Community Server **8.0 or 8.4**, and MySQL Workbench. Workbench alone is not the database server. MariaDB / XAMPP and MySQL 5.7 are not supported by this runner.
- Remember your MySQL root password. Check that your MySQL service is running in Windows Services.
- Install Python **3.12**. Check in PowerShell: `python --version`.
- For dashboards, install Power BI Desktop.

In Workbench, connect to your local server and run:

```sql
SELECT VERSION();
```

It should report 8.0.x or 8.4.x. The project uses MySQL 8 window functions and CTEs.

## 2. Extract and open the project folder

Extract the ZIP completely. Do not run Python from inside the ZIP. Open the extracted `ipl-main` folder in File Explorer, click the address bar, type `powershell`, and press Enter. Check that `mysql_project.py`, `matches.csv`, and `START_HERE.md` are visible:

```powershell
Get-ChildItem
```

## 3. Install Python packages

Run these commands in that PowerShell window:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
Copy-Item mysql_config.example.json mysql_config.json
notepad mysql_config.json
```

In the configuration, leave host as `127.0.0.1`, use your server's port (normally `3306`), and your MySQL username (normally `root`). Leave password empty to get a hidden password prompt. Save and close Notepad. The default database is `ipl_mysql`; use a new, dedicated database name if it already exists.

Example:

```json
{
  "host": "127.0.0.1",
  "port": 3306,
  "user": "root",
  "password": "",
  "database": "ipl_mysql"
}
```

You can enter the password in this file, but do not share a configuration containing your password. Prompt entry is safer and avoids escaping special characters in JSON.

## 4. Create the database and import the data

```powershell
.\.venv\Scripts\python.exe mysql_project.py setup
```

Enter your MySQL password when prompted (typing will be hidden). Wait for `SETUP PASSED`. The runner creates and loads 63 CSV-backed tables, the CPI factors table, the auction deduplication view, and the venue lookup tables. No manual Workbench import is needed. `mysql/schema.sql` is a reference schema, not a second required import step.

If interrupted, use a fresh dedicated database name, or reload only this project's tables with:

```powershell
.\.venv\Scripts\python.exe mysql_project.py setup --replace
```

`--replace` deletes and rebuilds this project's tables in the configured database. Do not use it in a database holding other work.

## 5. Verify the import

```powershell
.\.venv\Scripts\python.exe mysql_project.py check
```

Wait for `DATABASE CHECKS PASSED`. This compares all 63 imported table row counts with the supplied CSVs, checks delivery-to-match relationships, checks chasing/defending teams, and runs `look.sql`. It writes `mysql_output/database_checks.json`.

In Workbench, refresh the Schemas panel and run:

```sql
USE ipl_mysql;
SELECT COUNT(*) AS matches FROM matches;
SELECT COUNT(*) AS deliveries FROM deliveries;
SELECT MIN(season) AS first_season, MAX(season) AS last_season FROM matches;
SELECT * FROM auctions_dedup LIMIT 5;
```

See `VALIDATION.md` for the tested counts. If you changed the configured database name, change `USE` accordingly.

## 6. Run the SQL analysis

```powershell
.\.venv\Scripts\python.exe mysql_project.py queries
```

Wait for `ALL SELECT QUERIES PASSED`. The converted queries are in `mysql/queries/` and `queries per question.md`. Results are written to `mysql_output`; the original root CSVs are preserved. Some original queries are exploratory alternatives; the later phase export replaces the earlier export with the same filename, matching the original sequence.

The original team-name UPDATE queries are retained in the collection. They are optional and are not run automatically: they merge some historical franchises into modern franchises, which changes the meaning of team-level analysis. Run those only if you want the original project's historical consolidation, then rerun `queries` and `analysis`.

## 7. Run the Python analysis

```powershell
.\.venv\Scripts\python.exe mysql_project.py analysis
```

Wait for both `NOTEBOOK PASSED` messages and `ANALYSIS PASSED`. This runs the original notebooks in order and writes results into `mysql_output`, including the phase ROI files, player and franchise summary files, and `season_team_breakdown.xlsx`. Run `queries` first to use the MySQL-generated inputs. All required input CSVs are also supplied.

To view or interact with the notebooks:

```powershell
.\.venv\Scripts\python.exe -m notebook
```

Open `framework.ipynb` or `team roi.ipynb`. For the complete safe output workflow, use the runner above; manually executing notebooks can overwrite CSVs in your current folder.

On a new database you can do everything in one command:

```powershell
.\.venv\Scripts\python.exe mysql_project.py run
```

For an existing database, use `check`, `queries`, and `analysis` separately.

## 8. Check the original Power BI dashboards

Open `ipl project dashboard 2.pbix` and `ipl auction roi.pbix` in Power BI Desktop. Their bytes, visuals, and design are unchanged. Confirm that the charts render and that filters work.

To refresh with newly generated data, select **Transform data** and inspect each query's **Source** step. For file-based sources, change the old author's CSV/folder paths to this project's `mysql_output` folder (or the root folder for unchanged source data). Keep column names and the existing transformations. Use the corresponding `auction roi` subfolder where the source expects it. Then select **Close & Apply** and **Refresh**.

If a query actually uses a PostgreSQL source, replace that Source step through **Get data > MySQL database**, select `127.0.0.1:3306` and `ipl_mysql`, and preserve the existing table, columns, and transformation steps. Follow Power BI's connector prompt if it requires a MySQL provider. The PBIX models use a proprietary compressed format; they have not been rewritten or refreshed here. Their source configuration and refresh must be verified in Power BI Desktop on Windows.

## Troubleshooting

| Error | What to check |
| --- | --- |
| `python` not recognized | Python installation / PATH; reopen PowerShell. |
| Cannot connect / error 2003 | MySQL service running, host and port match Workbench. |
| Access denied / error 1045 | Username and password; test the same credentials in Workbench. |
| Database contains tables | Use a new dedicated database or the reload command above. |
| Missing packages | Run pip with `.\.venv\Scripts\python.exe`, then run the runner with the same interpreter. |
| CSV not found | Extract the complete ZIP; keep the included folder structure. |
| Power BI refresh path error | Update each Source step to your extracted folder. |
| MySQL version rejected | Use Oracle MySQL 8.0 / 8.4, not MariaDB or XAMPP. |

If a step fails, stop at that step and share the full error or a screenshot, without your password.
