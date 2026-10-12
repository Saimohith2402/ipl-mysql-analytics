WITH `cleaned_matches` AS (
  SELECT
    `m`.`match_id`,
    `m`.`season`,
    `v`.`canonical_name` AS `venue`,
    `m`.`team1`,
    `m`.`team2`,
    `m`.`winner`
  FROM `matches` AS `m`
  JOIN `venue_mapping` AS `v`
    ON `m`.`venue` = `v`.`raw_name`
), `home_games` AS (
  SELECT
    `cm`.*,
    `th`.`team` AS `home_team`
  FROM `cleaned_matches` AS `cm`
  JOIN `team_home_venues` AS `th`
    ON `cm`.`venue` = `th`.`venue`
    AND (
      `cm`.`team1` = `th`.`team` OR `cm`.`team2` = `th`.`team`
    )
)
SELECT
  `home_team`,
  COUNT(*) AS `home_games`,
  SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) AS `home_wins`,
  ROUND(100.0 * SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) / COUNT(*), 2) AS `home_win_pct`
FROM `home_games`
GROUP BY
  `home_team`
ORDER BY
  CASE WHEN ROUND(100.0 * SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) / COUNT(*), 2) IS NULL THEN 1 ELSE 0 END DESC, ROUND(100.0 * SUM(CASE WHEN `winner` = `home_team` THEN 1 ELSE 0 END) / COUNT(*), 2) DESC;
