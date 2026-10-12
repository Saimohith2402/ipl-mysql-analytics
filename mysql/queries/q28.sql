UPDATE `deliveries` SET `batting_team` = CASE
  WHEN `batting_team` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `batting_team` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `batting_team` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `batting_team` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `batting_team` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `batting_team` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `batting_team` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `batting_team`
END;
