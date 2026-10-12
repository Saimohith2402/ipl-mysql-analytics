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
