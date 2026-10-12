UPDATE `matches` SET `team2` = CASE
  WHEN `team2` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `team2` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `team2` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `team2` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `team2` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `team2` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `team2` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `team2`
END;
