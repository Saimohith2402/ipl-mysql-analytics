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
