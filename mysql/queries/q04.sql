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
