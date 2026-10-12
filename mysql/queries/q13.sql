WITH `chasing` AS (
  SELECT
    `chasing_team` AS `team`,
    COUNT(*) AS `times_chased`,
    SUM(CASE WHEN `chasing_team` = `winner` THEN 1 ELSE 0 END) AS `chasing_wins`
  FROM `matches`
  GROUP BY
    `chasing_team`
), `defending` AS (
  SELECT
    `defending_team` AS `team`,
    COUNT(*) AS `times_defended`,
    SUM(CASE WHEN `defending_team` = `winner` THEN 1 ELSE 0 END) AS `defending_wins`
  FROM `matches`
  GROUP BY
    `defending_team`
)
SELECT
  `c`.`team`,
  `c`.`times_chased`,
  `c`.`chasing_wins`,
  ROUND(100.0 * `c`.`chasing_wins` / NULLIF(`c`.`times_chased`, 0), 2) AS `chasing_win_pct`,
  `d`.`times_defended`,
  `d`.`defending_wins`,
  ROUND(100.0 * `d`.`defending_wins` / NULLIF(`d`.`times_defended`, 0), 2) AS `defending_win_pct`
FROM `chasing` AS `c`
JOIN `defending` AS `d`
  ON `c`.`team` = `d`.`team`
ORDER BY
  CASE WHEN ROUND(100.0 * `c`.`chasing_wins` / NULLIF(`c`.`times_chased`, 0), 2) IS NULL THEN 1 ELSE 0 END DESC, ROUND(100.0 * `c`.`chasing_wins` / NULLIF(`c`.`times_chased`, 0), 2) DESC;
