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
