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
