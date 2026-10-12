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
), `normalized` AS (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    `runs` / NULLIF(MAX(`runs`) OVER (PARTITION BY `season`), 0) + `wickets` / NULLIF(MAX(`wickets`) OVER (PARTITION BY `season`), 0) AS `allrounder_score`
  FROM `combined`
)
SELECT
  *
FROM (
  SELECT
    `season`,
    `player`,
    `runs`,
    `wickets`,
    `allrounder_score`,
    RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC
    ) AS `rnk`
  FROM `normalized`
  ORDER BY
    CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`,
    CASE WHEN RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC
    ) IS NULL THEN 1 ELSE 0 END, RANK() OVER (
      PARTITION BY `season`
      ORDER BY CASE WHEN `allrounder_score` IS NULL THEN 1 ELSE 0 END DESC, `allrounder_score` DESC
    )
) AS `t`
WHERE
  `runs` > 0 AND `wickets` > 0 AND `rnk` = 1;
