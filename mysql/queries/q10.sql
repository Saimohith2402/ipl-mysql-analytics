SELECT
  `season`,
  `bowler`,
  `team`,
  `wickets`
FROM (
  SELECT
    `m`.`season`,
    `d`.`bowler`,
    CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END AS `team`,
    SUM(
      CASE
        WHEN `d`.`wicket_kind` IN ('bowled', 'caught', 'caught and bowled', 'lbw', 'stumped')
        THEN 1
        ELSE 0
      END
    ) AS `wickets`,
    RANK() OVER (
      PARTITION BY `m`.`season`
      ORDER BY CASE WHEN SUM(
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
      ) DESC
    ) AS `rank`
  FROM `matches` AS `m`
  JOIN `deliveries` AS `d`
    ON `d`.`match_id` = `m`.`match_id`
  WHERE
    `d`.`over` BETWEEN 16 AND 20
  GROUP BY
    `m`.`season`,
    `d`.`bowler`,
    CASE WHEN `d`.`batting_team` = `m`.`team1` THEN `m`.`team2` ELSE `m`.`team1` END
) AS `t`
WHERE
  `rank` = 1
ORDER BY
  CASE WHEN `season` IS NULL THEN 1 ELSE 0 END, `season`;
