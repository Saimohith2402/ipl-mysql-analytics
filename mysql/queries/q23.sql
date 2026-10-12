UPDATE `matches` SET `team1` = CASE
  WHEN `team1` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `team1` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `team1` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `team1` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `team1` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `team1` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `team1` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `team1`
END;
