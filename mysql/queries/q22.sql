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
