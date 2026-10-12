-- Reference schema. Use mysql_project.py setup to create AND load all tables.
CREATE DATABASE IF NOT EXISTS ipl_mysql CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
USE ipl_mysql;

CREATE TABLE `matches` (
  `match_id` BIGINT NOT NULL,
  `season` BIGINT NULL,
  `date` DATE NULL,
  `venue` VARCHAR(512) NULL,
  `team1` VARCHAR(512) NULL,
  `team2` VARCHAR(512) NULL,
  `toss_winner` VARCHAR(512) NULL,
  `toss_decision` VARCHAR(512) NULL,
  `winner` VARCHAR(512) NULL,
  `result` VARCHAR(512) NULL,
  `margin` VARCHAR(512) NULL,
  PRIMARY KEY (`match_id`),
  `defending_team` VARCHAR(512) GENERATED ALWAYS AS (CASE WHEN toss_decision='bat' THEN toss_winner WHEN toss_winner=team1 THEN team2 ELSE team1 END) STORED,
  `chasing_team` VARCHAR(512) GENERATED ALWAYS AS (CASE WHEN toss_decision='field' THEN toss_winner WHEN toss_winner=team1 THEN team2 ELSE team1 END) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `deliveries` (
  `match_id` BIGINT NOT NULL,
  `inning` BIGINT NOT NULL,
  `over` BIGINT NOT NULL,
  `ball` BIGINT NOT NULL,
  `batting_team` VARCHAR(512) NULL,
  `batsman` VARCHAR(512) NULL,
  `bowler` VARCHAR(512) NULL,
  `runs_batsman` BIGINT NULL,
  `runs_extras` BIGINT NULL,
  `runs_total` BIGINT NULL,
  `inning_runs` BIGINT NULL,
  `extras_type` VARCHAR(512) NULL,
  `wicket_kind` VARCHAR(512) NULL,
  `player_out` VARCHAR(512) NULL,
  `inning_wickets` BIGINT NULL,
  PRIMARY KEY (`match_id`,`inning`,`over`,`ball`),
  FOREIGN KEY (`match_id`) REFERENCES `matches` (`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `auctions_final` (
  `id` BIGINT NOT NULL,
  `name` VARCHAR(512) NULL,
  `country` VARCHAR(512) NULL,
  `age` DOUBLE NULL,
  `height` DOUBLE NULL,
  `role` VARCHAR(512) NULL,
  `bat_style` VARCHAR(512) NULL,
  `bowl_style` VARCHAR(512) NULL,
  `t20_no` BIGINT NULL,
  `t20_runs` BIGINT NULL,
  `t20_avg` DOUBLE NULL,
  `t20_sr` DOUBLE NULL,
  `t20_50` BIGINT NULL,
  `t20_4s` BIGINT NULL,
  `t20_6s` BIGINT NULL,
  `ipl_no` BIGINT NULL,
  `ipl_runs` BIGINT NULL,
  `ipl_avg` DOUBLE NULL,
  `ipl_sr` DOUBLE NULL,
  `ipl_50` BIGINT NULL,
  `ipl_4s` BIGINT NULL,
  `ipl_6s` BIGINT NULL,
  `t20_wkts` BIGINT NULL,
  `t20_bowl_econ` DOUBLE NULL,
  `t20_bowl_avg` DOUBLE NULL,
  `t20_bowl_sr` DOUBLE NULL,
  `ipl_wkts` BIGINT NULL,
  `ipl_bowl_econ` DOUBLE NULL,
  `ipl_bowl_avg` DOUBLE NULL,
  `ipl_bowl_sr` DOUBLE NULL,
  `team` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `price` BIGINT NULL,
  PRIMARY KEY (`id`),
  INDEX `player_year` (`name`(100),`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `auction_data` (
  `name` VARCHAR(512) NULL,
  `country` VARCHAR(512) NULL,
  `age` DOUBLE NULL,
  `height` DOUBLE NULL,
  `role` VARCHAR(512) NULL,
  `bat_style` VARCHAR(512) NULL,
  `bowl_style` VARCHAR(512) NULL,
  `t20_no` BIGINT NULL,
  `t20_runs` BIGINT NULL,
  `t20_avg` DOUBLE NULL,
  `t20_sr` DOUBLE NULL,
  `t20_50` BIGINT NULL,
  `t20_4s` BIGINT NULL,
  `t20_6s` BIGINT NULL,
  `ipl_no` BIGINT NULL,
  `ipl_runs` BIGINT NULL,
  `ipl_avg` DOUBLE NULL,
  `ipl_sr` DOUBLE NULL,
  `ipl_50` BIGINT NULL,
  `ipl_4s` BIGINT NULL,
  `ipl_6s` BIGINT NULL,
  `t20_wkts` BIGINT NULL,
  `t20_bowl_econ` DOUBLE NULL,
  `t20_bowl_avg` DOUBLE NULL,
  `t20_bowl_sr` DOUBLE NULL,
  `ipl_wkts` BIGINT NULL,
  `ipl_bowl_econ` DOUBLE NULL,
  `ipl_bowl_avg` DOUBLE NULL,
  `ipl_bowl_sr` DOUBLE NULL,
  `team` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `auction_data_cleaned` (
  `name` VARCHAR(512) NULL,
  `country` VARCHAR(512) NULL,
  `age` DOUBLE NULL,
  `height` DOUBLE NULL,
  `role` VARCHAR(512) NULL,
  `bat_style` VARCHAR(512) NULL,
  `bowl_style` VARCHAR(512) NULL,
  `t20_no` BIGINT NULL,
  `t20_runs` BIGINT NULL,
  `t20_avg` DOUBLE NULL,
  `t20_sr` DOUBLE NULL,
  `t20_50` BIGINT NULL,
  `t20_4s` BIGINT NULL,
  `t20_6s` BIGINT NULL,
  `ipl_no` BIGINT NULL,
  `ipl_runs` BIGINT NULL,
  `ipl_avg` DOUBLE NULL,
  `ipl_sr` DOUBLE NULL,
  `ipl_50` BIGINT NULL,
  `ipl_4s` BIGINT NULL,
  `ipl_6s` BIGINT NULL,
  `t20_wkts` BIGINT NULL,
  `t20_bowl_econ` DOUBLE NULL,
  `t20_bowl_avg` DOUBLE NULL,
  `t20_bowl_sr` DOUBLE NULL,
  `ipl_wkts` BIGINT NULL,
  `ipl_bowl_econ` DOUBLE NULL,
  `ipl_bowl_avg` DOUBLE NULL,
  `ipl_bowl_sr` DOUBLE NULL,
  `team` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `auction_data_to_verify` (
  `name` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `price` VARCHAR(512) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `auction_name_to_deliveries` (
  `name` VARCHAR(512) NULL,
  `matched_name` VARCHAR(512) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_death_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_death_with_roi_z` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_master` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_pct` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `adj_price` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_mid_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_mid_with_roi_z` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_pp_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bat_pp_with_roi_z` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batsman_roi_death` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batsman_roi_middle` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batsman_roi_powerplay` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batting_death_copy` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batting_death` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batting_middle_copy` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batting_middle` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batting_powerplay_copy` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batting_powerplay` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_death_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_death_with_roi_z` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_master` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_pct` DOUBLE NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `adj_price` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_mid_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_mid_with_roi_z` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_pp_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowl_pp_with_roi_z` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL,
  `ROI_z` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowler_roi_death` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowler_roi_death_inner_join` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowler_roi_middle` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowler_roi_powerplay` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL,
  `wickets_z` DOUBLE NULL,
  `economy_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `boundary_pct_conceded_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL,
  `name` VARCHAR(512) NULL,
  `year` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowling_death_copy` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowling_death` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowling_middle_copy` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowling_middle` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowling_powerplay_copy` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowling_powerplay` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `balls` BIGINT NULL,
  `economy` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `boundaries_conceded` BIGINT NULL,
  `boundary_pct_conceded` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `combined_master` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `phase` VARCHAR(512) NULL,
  `adj_price` DOUBLE NULL,
  `ROI_z` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `final_standings` (
  `Team` VARCHAR(512) NULL,
  `2013` BIGINT NULL,
  `2014` BIGINT NULL,
  `2015` BIGINT NULL,
  `2016` BIGINT NULL,
  `2017` BIGINT NULL,
  `2018` BIGINT NULL,
  `2019` BIGINT NULL,
  `2020` BIGINT NULL,
  `2021` BIGINT NULL,
  `2022` BIGINT NULL,
  `2023` BIGINT NULL,
  `2024` BIGINT NULL,
  `2025` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `fr_final_with_standings` (
  `team` VARCHAR(512) NULL,
  `season` BIGINT NULL,
  `avg_roi` DOUBLE NULL,
  `total_adj_spend` DOUBLE NULL,
  `player_count` BIGINT NULL,
  `matches` BIGINT NULL,
  `wins` BIGINT NULL,
  `win_pct` DOUBLE NULL,
  `final_standing` BIGINT NULL,
  `made_playoffs` BIGINT NULL,
  `spend_per_player` DOUBLE NULL,
  `final_roi` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `franchise_overall_roi` (
  `season` BIGINT NULL,
  `team` VARCHAR(512) NULL,
  `batting_ROI` DOUBLE NULL,
  `bowling_ROI` DOUBLE NULL,
  `overall_ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `franchise_phasewise_and_overall_roi` (
  `season` BIGINT NULL,
  `team` VARCHAR(512) NULL,
  `ROI_bat_pp` DOUBLE NULL,
  `ROI_bat_mid` DOUBLE NULL,
  `ROI_bat_death` DOUBLE NULL,
  `ROI_bowl_pp` DOUBLE NULL,
  `ROI_bowl_mid` DOUBLE NULL,
  `ROI_bowl_death` DOUBLE NULL,
  `batting_ROI` DOUBLE NULL,
  `bowling_ROI` DOUBLE NULL,
  `overall_ROI` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `franchise_roi_summary` (
  `team` VARCHAR(512) NULL,
  `season` BIGINT NULL,
  `avg_roi` DOUBLE NULL,
  `total_adj_spend` DOUBLE NULL,
  `player_count` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `matches_played_by_team` (
  `season` BIGINT NULL,
  `team` VARCHAR(512) NULL,
  `matches` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `matches_won_by_team` (
  `season` BIGINT NULL,
  `team` VARCHAR(512) NULL,
  `wins` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `name_mapping` (
  `name` VARCHAR(512) NULL,
  `delivery_name` VARCHAR(512) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `name_mapping_2` (
  `name` VARCHAR(512) NULL,
  `delivery_name` VARCHAR(512) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `temp` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `team` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `balls` BIGINT NULL,
  `strike_rate` DOUBLE NULL,
  `fours` BIGINT NULL,
  `sixes` BIGINT NULL,
  `boundary_pct` DOUBLE NULL,
  `dot_balls` BIGINT NULL,
  `dot_pct` DOUBLE NULL,
  `runs_z` DOUBLE NULL,
  `strike_rate_z` DOUBLE NULL,
  `boundary_pct_z` DOUBLE NULL,
  `dot_pct_z` DOUBLE NULL,
  `impact_score` DOUBLE NULL,
  `impact_score_pos` DOUBLE NULL,
  `phase` VARCHAR(512) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `temp2` (
  `id` BIGINT NULL,
  `name` VARCHAR(512) NULL,
  `country` VARCHAR(512) NULL,
  `age` DOUBLE NULL,
  `height` DOUBLE NULL,
  `role` VARCHAR(512) NULL,
  `bat_style` VARCHAR(512) NULL,
  `bowl_style` VARCHAR(512) NULL,
  `t20_no` BIGINT NULL,
  `t20_runs` BIGINT NULL,
  `t20_avg` DOUBLE NULL,
  `t20_sr` DOUBLE NULL,
  `t20_50` BIGINT NULL,
  `t20_4s` BIGINT NULL,
  `t20_6s` BIGINT NULL,
  `ipl_no` BIGINT NULL,
  `ipl_runs` BIGINT NULL,
  `ipl_avg` DOUBLE NULL,
  `ipl_sr` DOUBLE NULL,
  `ipl_50` BIGINT NULL,
  `ipl_4s` BIGINT NULL,
  `ipl_6s` BIGINT NULL,
  `t20_wkts` BIGINT NULL,
  `t20_bowl_econ` DOUBLE NULL,
  `t20_bowl_avg` DOUBLE NULL,
  `t20_bowl_sr` DOUBLE NULL,
  `ipl_wkts` BIGINT NULL,
  `ipl_bowl_econ` DOUBLE NULL,
  `ipl_bowl_avg` DOUBLE NULL,
  `ipl_bowl_sr` DOUBLE NULL,
  `team` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `price` BIGINT NULL,
  `inflation` DOUBLE NULL,
  `adj_price` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `allrounders_price` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `wickets` BIGINT NULL,
  `allrounder_score` DOUBLE NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `allrounders_roi_inflation` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `wickets` BIGINT NULL,
  `allrounder_score` DOUBLE NULL,
  `adj_price` DOUBLE NULL,
  `price_per_allrounder_score_adj` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `allrounders_roi_shifted` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `wickets` BIGINT NULL,
  `allrounder_score` DOUBLE NULL,
  `price` BIGINT NULL,
  `price_per_allrounder_score` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batsmen_price` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batsmen_roi` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `price` BIGINT NULL,
  `price_per_run` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `batsmen_roi_inflation` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `runs` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `price_per_run_adj` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowlers_price` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowlers_price_clean` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowlers_roi` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `price` BIGINT NULL,
  `price_per_wicket` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `bowlers_roi_inflation` (
  `season` BIGINT NULL,
  `player` VARCHAR(512) NULL,
  `wickets` BIGINT NULL,
  `adj_price` DOUBLE NULL,
  `price_per_wicket_adj` DOUBLE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `auction_source_data` (
  `name` VARCHAR(512) NULL,
  `country` VARCHAR(512) NULL,
  `age` DOUBLE NULL,
  `height` DOUBLE NULL,
  `role` VARCHAR(512) NULL,
  `bat_style` VARCHAR(512) NULL,
  `bowl_style` VARCHAR(512) NULL,
  `t20_no` BIGINT NULL,
  `t20_runs` BIGINT NULL,
  `t20_avg` DOUBLE NULL,
  `t20_sr` DOUBLE NULL,
  `t20_50` BIGINT NULL,
  `t20_4s` BIGINT NULL,
  `t20_6s` BIGINT NULL,
  `ipl_no` BIGINT NULL,
  `ipl_runs` BIGINT NULL,
  `ipl_avg` DOUBLE NULL,
  `ipl_sr` DOUBLE NULL,
  `ipl_50` BIGINT NULL,
  `ipl_4s` BIGINT NULL,
  `ipl_6s` BIGINT NULL,
  `t20_wkts` BIGINT NULL,
  `t20_bowl_econ` DOUBLE NULL,
  `t20_bowl_avg` DOUBLE NULL,
  `t20_bowl_sr` DOUBLE NULL,
  `ipl_wkts` BIGINT NULL,
  `ipl_bowl_econ` DOUBLE NULL,
  `ipl_bowl_avg` DOUBLE NULL,
  `ipl_bowl_sr` DOUBLE NULL,
  `team` VARCHAR(512) NULL,
  `year` BIGINT NULL,
  `price` BIGINT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE cpi (`year` INT PRIMARY KEY, inflation DOUBLE, factor_to_2025 DOUBLE);

CREATE VIEW auctions_dedup AS SELECT * FROM
(SELECT a.*, ROW_NUMBER() OVER (PARTITION BY name,year ORDER BY id DESC) AS dedup_row FROM auctions_final a) t
WHERE dedup_row=1;