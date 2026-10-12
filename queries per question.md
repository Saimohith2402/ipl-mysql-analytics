# MySQL 8 query collection

Run after `mysql_project.py setup`. Python handles CSV exports; no server OUTFILE privilege is needed.

1. **top run scorers per season**

```sql
SELECT
  `season`,
  `batsman`,
  `runs`,
  `rank`
FROM (
  SELECT
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team` AS `team`,
    SUM(`d`.`runs_batsman`) AS `runs`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(`d`.`runs_batsman`) IS NULL THEN 1 ELSE 0 END DESC, SUM(`d`.`runs_batsman`) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team`
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`;
```


```sql
SELECT
  `season`,
  `batsman`,
  `runs`,
  `rank`
FROM (
  SELECT
    `m`.`season`,
    `d`.`batsman`,
    SUM(`d`.`runs_batsman`) AS `runs`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(`d`.`runs_batsman`) IS NULL THEN 1 ELSE 0 END DESC, SUM(`d`.`runs_batsman`) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`
) AS `t`
WHERE
  `rank` <= 5
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`;
```

* highest runs scored in a season

```sql
SELECT
  `m`.`season`,
  `d`.`batsman`,
  SUM(`d`.`runs_batsman`)
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `d`.`match_id` = `m`.`match_id`
GROUP BY
  `m`.`season`,
  `d`.`batsman`
ORDER BY
  CASE WHEN SUM(`d`.`runs_total`) IS NULL THEN 1 ELSE 0 END DESC, SUM(`d`.`runs_total`) DESC
LIMIT 25;
```

2. highest strike rate batsmen per season 

```sql
WITH `batsman_stats` AS (
  SELECT
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team` AS `team`,
    SUM(`d`.`runs_batsman`) AS `runs`,
    SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
    ROUND(
      (
        SUM(`d`.`runs_batsman`) * 100.0
      ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0),
      1
    ) AS `strike_rate`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team`
  HAVING
    SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) > 200
)
SELECT
  *
FROM (
  SELECT
    *,
    RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `strike_rate` IS NULL THEN 1 ELSE 0 END DESC, `strike_rate` DESC
    ) AS `rank`
  FROM `batsman_stats`
) AS `t`
WHERE
  `rank` <= 3
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`,
  CASE WHEN `rank` IS NULL THEN 1 ELSE 0 END, `rank`;
```



* all batsmen strike rate per season ordered high to low

```sql
SELECT
  `m`.`season`,
  `d`.`batsman`,
  SUM(`d`.`runs_batsman`) AS `runs`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  (
    SUM(`d`.`runs_batsman`) * 100.0
  ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0) AS `strike_rate`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `d`.`match_id` = `m`.`match_id`
GROUP BY
  `m`.`season`,
  `d`.`batsman`
HAVING
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) > 200
ORDER BY
  CASE WHEN (
    SUM(`d`.`runs_batsman`) * 100.0
  ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0) IS NULL THEN 1 ELSE 0 END DESC, (
    SUM(`d`.`runs_batsman`) * 100.0
  ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0) DESC;
```




3. top boundaries

**sixes**
```sql
SELECT
  `season`,
  `batsman`,
  `fours`
FROM (
  SELECT
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team` AS `team`,
    SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) AS `fours`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) IS NULL THEN 1 ELSE 0 END DESC, SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team`
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END DESC, `season` DESC;
```

**fours**
```sql
SELECT
  `season`,
  `batsman`,
  `fours`
FROM (
  SELECT
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team` AS `team`,
    SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) AS `fours`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) IS NULL THEN 1 ELSE 0 END DESC, SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team`
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END DESC, `season` DESC;
```



4. most runs in death overs

```sql
SELECT
  `season`,
  `batsman`,
  `runs_death`,
  `rank`
FROM (
  SELECT
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team` AS `team`,
    SUM(`d`.`runs_batsman`) AS `runs_death`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(`d`.`runs_batsman`) IS NULL THEN 1 ELSE 0 END DESC, SUM(`d`.`runs_batsman`) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  WHERE
    `d`.`over` BETWEEN 16 AND 20
  GROUP BY
    `m`.`season`,
    `d`.`batsman`,
    `d`.`batting_team`
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END DESC, `season` DESC;
```


5. top wickets

```sql
SELECT
  `season`,
  `bowler`,
  `team`,
  `wickets`
FROM (
  SELECT
    `m`.`season`,
    `d`.`bowler`,
    CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END AS `team`,
    SUM(
      CASE
        WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
        THEN 1
        ELSE 0
      END
    ) AS `wickets`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(
        CASE
          WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
          THEN 1
          ELSE 0
        END
      ) IS NULL THEN 1 ELSE 0 END DESC, SUM(
        CASE
          WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
          THEN 1
          ELSE 0
        END
      ) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`bowler`,
    CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`;
```

6. top wickets in death overs

```sql
SELECT
  `season`,
  `bowler`,
  `team`,
  `wickets`
FROM (
  SELECT
    `m`.`season`,
    `d`.`bowler`,
    CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END AS `team`,
    SUM(
      CASE
        WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
        THEN 1
        ELSE 0
      END
    ) AS `wickets`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(
        CASE
          WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
          THEN 1
          ELSE 0
        END
      ) IS NULL THEN 1 ELSE 0 END DESC, SUM(
        CASE
          WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
          THEN 1
          ELSE 0
        END
      ) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  WHERE
    `d`.`over` BETWEEN 16 AND 20
  GROUP BY
    `m`.`season`,
    `d`.`bowler`,
    CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`;
```


7. top all rounder

**normalising**

```sql
WITH `batting` AS (
  SELECT
    `m`.`season`,
    `d`.`batsman` AS `player`,
    SUM(`d`.`runs_batsman`) AS `runs`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`
), `bowling` AS (
  SELECT
    `m`.`season`,
    `d`.`bowler` AS `player`,
    SUM(
      CASE
        WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
        THEN 1
        ELSE 0
      END
    ) AS `wickets`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`bowler`
), `combined` AS (
  SELECT
    `b`.`season`,
    `b`.`player`,
    COALESCE(`b`.`runs`, 0) AS `runs`,
    COALESCE(`w`.`wickets`, 0) AS `wickets`
  FROM `batting` AS `b`
  LEFT JOIN `bowling` AS `w`
    ON `b`.`player` = `w`.`player` AND `b`.`season` = `w`.`season`
  UNION ALL
  SELECT
    `w`.`season`,
    `w`.`player`,
    0 AS `runs`,
    COALESCE(`w`.`wickets`, 0) AS `wickets`
  FROM `bowling` AS `w`
  LEFT JOIN `batting` AS `b`
    ON `b`.`player` = `w`.`player` AND `b`.`season` = `w`.`season`
  WHERE
    `b`.`player` IS NULL
), `normalized` AS (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    `runs` / NULLIF(MAX(`runs`) OVER (PARTITION BY `season`), 0) + `wickets` / NULLIF(MAX(`wickets`) OVER (PARTITION BY `season`), 0) AS `allrounder_score`
  FROM `combined`
)
SELECT
  *
FROM (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    `allrounder_score`,
    RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC
    ) AS `rnk`
  FROM `normalized`
  ORDER BY
    CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`,
    CASE WHEN RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC
    ) IS NULL THEN 1 ELSE 0 END, RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC
    )
) AS `t`
WHERE
  `runs` > 0 AND `wickets` > 0 AND `rnk` = 1;
```


**standardised**

```sql
WITH `batting` AS (
  SELECT
    `m`.`season`,
    `d`.`batsman` AS `player`,
    SUM(`d`.`runs_batsman`) AS `runs`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`
), `bowling` AS (
  SELECT
    `m`.`season`,
    `d`.`bowler` AS `player`,
    SUM(
      CASE
        WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
        THEN 1
        ELSE 0
      END
    ) AS `wickets`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`bowler`
), `combined` AS (
  SELECT
    `b`.`season`,
    `b`.`player`,
    COALESCE(`b`.`runs`, 0) AS `runs`,
    COALESCE(`w`.`wickets`, 0) AS `wickets`
  FROM `batting` AS `b`
  LEFT JOIN `bowling` AS `w`
    ON `b`.`player` = `w`.`player` AND `b`.`season` = `w`.`season`
  UNION ALL
  SELECT
    `w`.`season`,
    `w`.`player`,
    0 AS `runs`,
    COALESCE(`w`.`wickets`, 0) AS `wickets`
  FROM `bowling` AS `w`
  LEFT JOIN `batting` AS `b`
    ON `b`.`player` = `w`.`player` AND `b`.`season` = `w`.`season`
  WHERE
    `b`.`player` IS NULL
), `standardized` AS (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    (
      `runs` - AVG(`runs`) OVER (PARTITION BY `season`)
    ) /* z-scores for runs and wickets */ / NULLIF(STDDEV_POP(`runs`) OVER (PARTITION BY `season`), 0) AS `runs_z`,
    (
      `wickets` - AVG(`wickets`) OVER (PARTITION BY `season`)
    ) / NULLIF(STDDEV_POP(`wickets`) OVER (PARTITION BY `season`), 0) AS `wickets_z`
  FROM `combined`
)
SELECT
  *
FROM (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    (
      `runs_z` + `wickets_z`
    ) AS `allrounder_score`,
    RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN (
        `runs_z` + `wickets_z`
      ) IS NULL THEN 1 ELSE 0 END DESC, (
        `runs_z` + `wickets_z`
      ) DESC
    ) AS `rnk`
  FROM `standardized`
) AS `t`
WHERE
  `runs` > 0 AND `wickets` > 0 AND `rnk` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`;
```



10. **Chasing vs Defending:** Which teams are stronger when batting first vs chasing?


```sql
WITH `chasing` AS (
  SELECT
    `chasing_team` AS `team`,
    COUNT(*) AS `times_chased`,
    SUM(CASE WHEN `chasing_team` = `winner` THEN 1 ELSE 0 END) AS `chasing_wins`
  FROM `matches`
  GROUP BY
    `chasing_team`
), `defending` AS (
  SELECT
    `defending_team` AS `team`,
    COUNT(*) AS `times_defended`,
    SUM(CASE WHEN `defending_team` = `winner` THEN 1 ELSE 0 END) AS `defending_wins`
  FROM `matches`
  GROUP BY
    `defending_team`
)
SELECT
  `c`.`team`,
  `c`.`times_chased`,
  `c`.`chasing_wins`,
  ROUND(100.0 * `c`.`chasing_wins` / NULLIF(`c`.`times_chased`, 0), 2) AS `chasing_win_pct`,
  `d`.`times_defended`,
  `d`.`defending_wins`,
  ROUND(100.0 * `d`.`defending_wins` / NULLIF(`d`.`times_defended`, 0), 2) AS `defending_win_pct`
FROM `chasing` AS `c`
JOIN `defending` AS `d`
  ON `c`.`team` = `d`.`team`
ORDER BY
  CASE WHEN ROUND(100.0 * `c`.`chasing_wins` / NULLIF(`c`.`times_chased`, 0), 2) IS NULL THEN 1 ELSE 0 END DESC, ROUND(100.0 * `c`.`chasing_wins` / NULLIF(`c`.`times_chased`, 0), 2) DESC;
```




11. **Home Advantage:** Do teams win more at their home grounds? (needs venue matching)


```sql
CREATE TABLE IF NOT EXISTS `venue_mapping` (
  `raw_name` TEXT,
  `canonical_name` TEXT
);
```

```sql
INSERT INTO `venue_mapping` (
  `raw_name`,
  `canonical_name`
)
VALUES
  ('MA Chidambaram Stadium', 'MA Chidambaram Stadium'),
  ('MA Chidambaram Stadium, Chepauk, Chennai', 'MA Chidambaram Stadium'),
  ('MA Chidambaram Stadium, Chepauk', 'MA Chidambaram Stadium'),
  ('Wankhede Stadium', 'Wankhede Stadium'),
  ('Wankhede Stadium, Mumbai', 'Wankhede Stadium'),
  ('Brabourne Stadium', 'Wankhede Stadium'),
  ('Brabourne Stadium, Mumbai', 'Wankhede Stadium'),
  ('Dr DY Patil Sports Academy, Mumbai', 'Wankhede Stadium'),
  ('Eden Gardens', 'Eden Gardens'),
  ('Eden Gardens, Kolkata', 'Eden Gardens'),
  ('M Chinnaswamy Stadium', 'M Chinnaswamy Stadium'),
  ('M Chinnaswamy Stadium, Bengaluru', 'M Chinnaswamy Stadium'),
  ('Rajiv Gandhi International Stadium', 'Rajiv Gandhi International Stadium'),
  (
    'Rajiv Gandhi International Stadium, Uppal',
    'Rajiv Gandhi International Stadium'
  ),
  (
    'Rajiv Gandhi International Stadium, Uppal, Hyderabad',
    'Rajiv Gandhi International Stadium'
  ),
  ('Arun Jaitley Stadium', 'Arun Jaitley Stadium'),
  ('Arun Jaitley Stadium, Delhi', 'Arun Jaitley Stadium'),
  ('Feroz Shah Kotla', 'Arun Jaitley Stadium'),
  (
    'Punjab Cricket Association Stadium, Mohali',
    'Punjab Cricket Association IS Bindra Stadium'
  ),
  (
    'Punjab Cricket Association IS Bindra Stadium',
    'Punjab Cricket Association IS Bindra Stadium'
  ),
  (
    'Punjab Cricket Association IS Bindra Stadium, Mohali, Chandigarh',
    'Punjab Cricket Association IS Bindra Stadium'
  ),
  (
    'Maharaja Yadavindra Singh International Cricket Stadium, New Chandigarh',
    'Maharaja Yadavindra Singh International Cricket Stadium'
  ),
  (
    'Maharaja Yadavindra Singh International Cricket Stadium, Mullanpur',
    'Maharaja Yadavindra Singh International Cricket Stadium'
  ),
  ('Sawai Mansingh Stadium', 'Sawai Mansingh Stadium'),
  ('Sawai Mansingh Stadium, Jaipur', 'Sawai Mansingh Stadium'),
  ('Narendra Modi Stadium', 'Narendra Modi Stadium'),
  ('Narendra Modi Stadium, Ahmedabad', 'Narendra Modi Stadium'),
  ('Sardar Patel Stadium, Motera', 'Narendra Modi Stadium'),
  (
    'Bharat Ratna Shri Atal Bihari Vajpayee Ekana Cricket Stadium, Lucknow',
    'BRSABV Ekana Cricket Stadium'
  );
```

```sql
CREATE TABLE IF NOT EXISTS `team_home_venues` (
  `team` TEXT,
  `venue` TEXT
);
```

```sql
INSERT INTO `team_home_venues` (
  `team`,
  `venue`
)
VALUES
  ('Chennai Super Kings', 'MA Chidambaram Stadium'),
  ('Mumbai Indians', 'Wankhede Stadium'),
  ('Kolkata Knight Riders', 'Eden Gardens'),
  ('Royal Challengers Bangalore', 'M Chinnaswamy Stadium'),
  ('Royal Challengers Bengaluru', 'M Chinnaswamy Stadium'), /* rename variant */
  ('Sunrisers Hyderabad', 'Rajiv Gandhi International Stadium'),
  ('Delhi Capitals', 'Arun Jaitley Stadium'),
  ('Delhi Daredevils', 'Arun Jaitley Stadium'),
  ('Punjab Kings', 'Punjab Cricket Association IS Bindra Stadium'),
  ('Kings XI Punjab', 'Punjab Cricket Association IS Bindra Stadium'),
  ('Rajasthan Royals', 'Sawai Mansingh Stadium'),
  ('Gujarat Titans', 'Narendra Modi Stadium'),
  ('Lucknow Super Giants', 'BRSABV Ekana Cricket Stadium');
```

```sql
INSERT INTO `team_home_venues` (
  `team`,
  `venue`
)
VALUES
  ('Punjab Kings', 'Maharaja Yadavindra Singh International Cricket Stadium');
```

```sql
WITH `cleaned_matches` AS (
  SELECT
    `m`.`match_id`,
    `m`.`season`,
    `v`.`canonical_name` AS `venue`,
    `m`.`team1`,
    `m`.`team2`,
    `m`.`winner`
  FROM `matches` AS `m`
  JOIN `venue_mapping` AS `v`
    ON `m`.`venue` = `v`.`raw_name`
), `home_games` AS (
  SELECT
    `cm`.*,
    `th`.`team` AS `home_team`
  FROM `cleaned_matches` AS `cm`
  JOIN `team_home_venues` AS `th`
    ON `cm`.`venue` = `th`.`venue`
    AND (
      `cm`.`team1` = `th`.`team` OR `cm`.`team2` = `th`.`team`
    )
)
SELECT
  `home_team`,
  COUNT(*) AS `home_games`,
  SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) AS `home_wins`,
  ROUND(100.0 * SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) / COUNT(*), 2) AS `home_win_pct`
FROM `home_games`
GROUP BY
  `home_team`
ORDER BY
  CASE WHEN ROUND(100.0 * SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) / COUNT(*), 2) IS NULL THEN 1 ELSE 0 END DESC, ROUND(100.0 * SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) / COUNT(*), 2) DESC;
```




## with auction data

### batsman roi adjusted for inflation

```sql
SELECT
  `m`.`season`,
  `d`.`batsman` AS `player`,
  SUM(`d`.`runs_batsman`) AS `runs`,
  MAX(`a`.`price` * `f`.`factor_to_2025`) AS `adj_price`,
  ROUND(MAX(`a`.`price` * `f`.`factor_to_2025`) / NULLIF(SUM(`d`.`runs_batsman`), 0), 2) AS `price_per_run_adj`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
JOIN `auctions_dedup` AS `a`
  ON `a`.`name` = `d`.`batsman` AND `a`.`year` = `m`.`season`
JOIN `cpi` AS `f`
  ON `f`.`year` = `a`.`year`
GROUP BY
  `m`.`season`,
  `d`.`batsman`
HAVING
  SUM(`d`.`runs_batsman`) >= 150
ORDER BY
  CASE WHEN `m`.`season` IS NULL THEN 1 ELSE 0 END, `m`.`season`,
  CASE WHEN SUM(`d`.`runs_batsman`) IS NULL THEN 1 ELSE 0 END DESC, SUM(`d`.`runs_batsman`) DESC;
```

CSV export: `batsmen_roi_inflation.csv` (written by `mysql_project.py queries`).


### bowler roi adjusted for inflation

```sql
SELECT
  `m`.`season`,
  `d`.`bowler` AS `player`,
  SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
      THEN 1
      ELSE 0
    END
  ) AS `wickets`,
  MAX(`a`.`price` * `f`.`inflation`) AS `adj_price`,
  ROUND(
    MAX(`a`.`price` * `f`.`inflation`) / NULLIF(
      SUM(
        CASE
          WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
          THEN 1
          ELSE 0
        END
      ),
      0
    ),
    2
  ) AS `price_per_wicket_adj`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
JOIN `auctions_dedup` AS `a`
  ON `a`.`name` = `d`.`bowler` AND `a`.`year` = `m`.`season`
JOIN `cpi` AS `f`
  ON `f`.`year` = `a`.`year`
GROUP BY
  `m`.`season`,
  `d`.`bowler`
HAVING
  SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
      THEN 1
      ELSE 0
    END
  ) >= 10
ORDER BY
  CASE WHEN `m`.`season` IS NULL THEN 1 ELSE 0 END, `m`.`season`,
  CASE WHEN SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
      THEN 1
      ELSE 0
    END
  ) IS NULL THEN 1 ELSE 0 END DESC, SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
      THEN 1
      ELSE 0
    END
  ) DESC;
```

CSV export: `bowlers_roi_inflation.csv` (written by `mysql_project.py queries`).


### all rounder roi adjusted for inflation

```sql
WITH `batting` AS (
  SELECT
    `m`.`season`,
    `d`.`batsman` AS `player`,
    SUM(`d`.`runs_batsman`) AS `runs`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`batsman`
), `bowling` AS (
  SELECT
    `m`.`season`,
    `d`.`bowler` AS `player`,
    SUM(
      CASE
        WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
        THEN 1
        ELSE 0
      END
    ) AS `wickets`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  GROUP BY
    `m`.`season`,
    `d`.`bowler`
), `combined` AS (
  SELECT
    `b`.`season`,
    `b`.`player`,
    COALESCE(`b`.`runs`, 0) AS `runs`,
    COALESCE(`w`.`wickets`, 0) AS `wickets`
  FROM `batting` AS `b`
  LEFT JOIN `bowling` AS `w`
    ON `b`.`player` = `w`.`player` AND `b`.`season` = `w`.`season`
  UNION ALL
  SELECT
    `w`.`season`,
    `w`.`player`,
    0 AS `runs`,
    COALESCE(`w`.`wickets`, 0) AS `wickets`
  FROM `bowling` AS `w`
  LEFT JOIN `batting` AS `b`
    ON `b`.`player` = `w`.`player` AND `b`.`season` = `w`.`season`
  WHERE
    `b`.`player` IS NULL
), `standardized` AS (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    (
      `runs` - AVG(`runs`) OVER (PARTITION BY `season`)
    ) / NULLIF(STDDEV_POP(`runs`) OVER (PARTITION BY `season`), 0) AS `runs_z`,
    (
      `wickets` - AVG(`wickets`) OVER (PARTITION BY `season`)
    ) / NULLIF(STDDEV_POP(`wickets`) OVER (PARTITION BY `season`), 0) AS `wickets_z`
  FROM `combined`
), `shifted` AS (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    (
      `runs_z` + `wickets_z`
    ) AS `raw_score`
  FROM `standardized`
), `normalized` AS (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    `raw_score` - MIN(`raw_score`) OVER (PARTITION BY `season`) AS `allrounder_score`
  FROM `shifted`
), `with_price` AS (
  SELECT
    `n`.*,
    (
      `a`.`price` * `f`.`inflation`
    ) AS `adj_price`
  FROM `normalized` AS `n`
  JOIN `auctions_dedup` AS `a`
    ON `a`.`name` = `n`.`player` AND `a`.`year` = `n`.`season`
  JOIN `cpi` AS `f`
    ON `f`.`year` = `a`.`year`
  WHERE
    `runs` > 0 AND `wickets` > 0
)
SELECT
  `season`,
  `player`,
  `runs`,
  `wickets`,
  `allrounder_score`,
  `adj_price`,
  ROUND(`adj_price` / NULLIF(`allrounder_score`, 0), 2) AS `price_per_allrounder_score_adj`
FROM `with_price`
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`,
  CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC;
```

CSV export: `allrounders_roi_inflation.csv` (written by `mysql_project.py queries`).



name change

```sql
UPDATE `matches` SET `team1` = CASE
  WHEN `team1` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `team1` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `team1` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `team1` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `team1` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `team1` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `team1` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `team1`
END;
```

```sql
UPDATE `matches` SET `team2` = CASE
  WHEN `team2` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `team2` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `team2` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `team2` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `team2` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `team2` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `team2` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `team2`
END;
```

```sql
UPDATE `matches` SET `toss_winner` = CASE
  WHEN `toss_winner` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `toss_winner` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `toss_winner` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `toss_winner` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `toss_winner` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `toss_winner` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `toss_winner` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `toss_winner`
END;
```

```sql
UPDATE `matches` SET `winner` = CASE
  WHEN `winner` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `winner` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `winner` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `winner` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `winner` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `winner` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `winner` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `winner`
END;
```

```sql
UPDATE `auctions_final` SET `team` = CASE
  WHEN `team` = 'punjab-kings'
  THEN 'Punjab Kings'
  WHEN `team` = 'kolkata-knight-riders'
  THEN 'Kolkata Knight Riders'
  WHEN `team` = 'sunrisers-hyderabad'
  THEN 'Sunrisers Hyderabad'
  WHEN `team` = 'gujarat-titans'
  THEN 'Gujarat Titans'
  WHEN `team` = 'rajasthan-royals'
  THEN 'Rajasthan Royals'
  WHEN `team` = 'lucknow-super-giants'
  THEN 'Lucknow Super Giants'
  WHEN `team` = 'mumbai-indians'
  THEN 'Mumbai Indians'
  WHEN `team` = 'royal-challengers-bengaluru'
  THEN 'Royal Challengers Bengaluru'
  WHEN `team` = 'delhi-capitals'
  THEN 'Delhi Capitals'
  WHEN `team` = 'chennai-super-kings'
  THEN 'Chennai Super Kings'
  ELSE `team`
END;
```


```sql
UPDATE `deliveries` SET `batting_team` = CASE
  WHEN `batting_team` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `batting_team` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `batting_team` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `batting_team` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `batting_team` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `batting_team` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `batting_team` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `batting_team`
END;
```

```sql
SELECT
  `m`.`season`,
  `d`.`batsman` AS `player`,
  `d`.`batting_team` AS `team`,
  SUM(`d`.`runs_batsman`) AS `runs`,
  SUM(CASE WHEN NOT `d`.`extras_type` IN ('wides', 'noballs') THEN 1 ELSE 0 END) AS `balls`,
  ROUND(
    (
      SUM(`d`.`runs_batsman`) * 100.0
    ) / NULLIF(SUM(CASE WHEN NOT `d`.`extras_type` IN ('wides', 'noballs') THEN 1 ELSE 0 END), 0),
    2
  ) AS `strike_rate`,
  SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) AS `fours`,
  SUM(CASE WHEN `d`.`runs_batsman` = 6 THEN 1 ELSE 0 END) AS `sixes`,
  ROUND(
    (
      SUM(CASE WHEN `d`.`runs_batsman` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN NOT `d`.`extras_type` IN ('wides', 'noballs') THEN 1 ELSE 0 END), 0)
    ) * 100,
    2
  ) AS `boundary_pct`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)
    ) * 100,
    2
  ) AS `dot_pct`,
  COUNT(DISTINCT `d`.`player_out`) AS `dismissals`,
  ROUND(SUM(`d`.`runs_batsman`) / NULLIF(COUNT(DISTINCT `d`.`player_out`), 0), 2) AS `batting_avg`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 1 AND 6
GROUP BY
  `m`.`season`,
  `d`.`batsman`,
  `d`.`batting_team`;
```

CSV export: `batting_powerplay.csv` (written by `mysql_project.py queries`).



ho wi got batting_powerplay, bowling_death and all

```sql
SELECT
  `m`.`season`,
  `d`.`batsman` AS `player`,
  `d`.`batting_team` AS `team`,
  SUM(`d`.`runs_batsman`) AS `runs`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  ROUND(
    (
      (
        SUM(`d`.`runs_batsman`) * 100.0
      ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
    ),
    2
  ) AS `strike_rate`,
  SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) AS `fours`,
  SUM(CASE WHEN `d`.`runs_batsman` = 6 THEN 1 ELSE 0 END) AS `sixes`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_batsman` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `boundary_pct`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `dot_pct`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 1 AND 6
GROUP BY
  `m`.`season`,
  `d`.`batsman`,
  `d`.`batting_team`;
```

CSV export: `batting_powerplay.csv` (written by `mysql_project.py queries`).
```sql
SELECT
  `m`.`season`,
  `d`.`batsman` AS `player`,
  `d`.`batting_team` AS `team`,
  SUM(`d`.`runs_batsman`) AS `runs`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  ROUND(
    (
      (
        SUM(`d`.`runs_batsman`) * 100.0
      ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
    ),
    2
  ) AS `strike_rate`,
  SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) AS `fours`,
  SUM(CASE WHEN `d`.`runs_batsman` = 6 THEN 1 ELSE 0 END) AS `sixes`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_batsman` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `boundary_pct`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `dot_pct`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 7 AND 15
GROUP BY
  `m`.`season`,
  `d`.`batsman`,
  `d`.`batting_team`;
```

CSV export: `batting_middle.csv` (written by `mysql_project.py queries`).
```sql
SELECT
  `m`.`season`,
  `d`.`batsman` AS `player`,
  `d`.`batting_team` AS `team`,
  SUM(`d`.`runs_batsman`) AS `runs`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  ROUND(
    (
      (
        SUM(`d`.`runs_batsman`) * 100.0
      ) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
    ),
    2
  ) AS `strike_rate`,
  SUM(CASE WHEN `d`.`runs_batsman` = 4 THEN 1 ELSE 0 END) AS `fours`,
  SUM(CASE WHEN `d`.`runs_batsman` = 6 THEN 1 ELSE 0 END) AS `sixes`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_batsman` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `boundary_pct`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `dot_pct`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 16 AND 20
GROUP BY
  `m`.`season`,
  `d`.`batsman`,
  `d`.`batting_team`;
```

CSV export: `batting_death.csv` (written by `mysql_project.py queries`).
```sql
SELECT
  `m`.`season`,
  `d`.`bowler` AS `player`,
  CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END AS `team`,
  SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'lbw', 'stumped', 'caught and bowled')
      THEN 1
      ELSE 0
    END
  ) AS `wickets`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  ROUND(
    (
      (
        SUM(`d`.`runs_total`) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 6
    ),
    2
  ) AS `economy`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `dot_pct`,
  SUM(CASE WHEN `d`.`runs_total` IN (4, 6) THEN 1 ELSE 0 END) AS `boundaries_conceded`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `boundary_pct_conceded`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 1 AND 6
GROUP BY
  `m`.`season`,
  `d`.`bowler`,
  `team`;
```

CSV export: `bowling_powerplay.csv` (written by `mysql_project.py queries`).
```sql
SELECT
  `m`.`season`,
  `d`.`bowler` AS `player`,
  CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END AS `team`,
  SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'lbw', 'stumped', 'caught and bowled')
      THEN 1
      ELSE 0
    END
  ) AS `wickets`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  ROUND(
    (
      (
        SUM(`d`.`runs_total`) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 6
    ),
    2
  ) AS `economy`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `dot_pct`,
  SUM(CASE WHEN `d`.`runs_total` IN (4, 6) THEN 1 ELSE 0 END) AS `boundaries_conceded`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `boundary_pct_conceded`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 7 AND 15
GROUP BY
  `m`.`season`,
  `d`.`bowler`,
  `team`;
```

CSV export: `bowling_middle.csv` (written by `mysql_project.py queries`).
```sql
SELECT
  `m`.`season`,
  `d`.`bowler` AS `player`,
  CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END AS `team`,
  SUM(
    CASE
      WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'lbw', 'stumped', 'caught and bowled')
      THEN 1
      ELSE 0
    END
  ) AS `wickets`,
  SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END) AS `balls`,
  ROUND(
    (
      (
        SUM(`d`.`runs_total`) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 6
    ),
    2
  ) AS `economy`,
  SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) AS `dot_balls`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` = 0 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `dot_pct`,
  SUM(CASE WHEN `d`.`runs_total` IN (4, 6) THEN 1 ELSE 0 END) AS `boundaries_conceded`,
  ROUND(
    (
      (
        SUM(CASE WHEN `d`.`runs_total` IN (4, 6) THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN `d`.`extras_type` IN ('noballs', 'wides') THEN 0 ELSE 1 END), 0)
      ) * 100
    ),
    2
  ) AS `boundary_pct_conceded`
FROM `matches` AS `m`
JOIN `deliveries` AS `d`
  ON `m`.`match_id` = `d`.`match_id`
WHERE
  `d`.`over` BETWEEN 16 AND 20
GROUP BY
  `m`.`season`,
  `d`.`bowler`,
  `team`;
```

CSV export: `bowling_death.csv` (written by `mysql_project.py queries`).