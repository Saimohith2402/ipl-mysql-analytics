# Migration validation

Validated on Oracle MySQL Community Server **8.0.44**, Python 3.12.

- Loaded all 63 CSV-backed tables; every row count matches the original input CSV.
- Matches: **847**; deliveries: **201,832**; auctions_final: **1,067**.
- Match data covers **2013–2025**. The original README discusses a wider historical scope; the actual supplied root match CSV has this range.
- No orphan delivery match IDs; composite delivery keys are unique.
- Derived chasing and defending teams pass consistency checks.
- `look.sql` executes and returns 1,009 rows.
- All **24 SELECT / WITH queries** execute and export CSVs.
- All **6 optional UPDATE queries** execute; tested inside a transaction and rolled back.
- Both notebooks execute to completion with the exported inputs; ROI CSVs and `season_team_breakdown.xlsx` are generated.
- Original CSVs, match JSONs, HTML report, and both PBIX files are byte-for-byte unchanged from the uploaded ZIP.

## Changes made

Converted PostgreSQL casts, FILTER aggregates, full joins, quoting, and psql CSV export commands into MySQL-compatible SQL and Python CSV exports. Added a schema / loader, configuration example, requirements, and verification runner. The original query collection is preserved as a converted MySQL collection, with separate executable SQL files.

The original queries reference `auctions_dedup` and `cpi` without providing their setup. The loader supplies the notebook's CPI factors and a deterministic dedup view: one auction row per player/year, selecting the highest `id`. The legacy UPDATE's missing `auctions` table reference was aligned to the supplied `auctions_final` table.

The notebook edits remove the original author's absolute paths, correct an invalid package-install cell, and initialize the missing matched-name field using the supplied mapping. Stored outputs were cleared so rerunning shows current results. The JSON-to-CSV helper now uses its own directory. Analysis calculations and dashboard designs were preserved.

`mysql_output` contains example outputs from the tested run. Your commands regenerate them. CSV-backed SQL tables initially contain the supplied snapshots; running Python analysis creates new files, rather than silently replacing those database tables.

## Local verification still required

Power BI Desktop is not available here. Dashboard rendering, Source path edits, connector configuration (if used), and Refresh must be checked on Windows using step 8 in START_HERE.md. PBIX files remain unchanged, including any embedded source configuration. This package does not claim a locally verified Power BI refresh.
