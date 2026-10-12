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
