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
