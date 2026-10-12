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
