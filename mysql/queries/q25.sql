UPDATE `matches` SET `toss_winner` = CASE
  WHEN `toss_winner` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `toss_winner` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `toss_winner` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `toss_winner` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `toss_winner` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `toss_winner` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `toss_winner` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `toss_winner`
END;
