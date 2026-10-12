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
