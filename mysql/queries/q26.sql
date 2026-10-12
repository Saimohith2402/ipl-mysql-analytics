UPDATE `matches` SET `winner` = CASE
  WHEN `winner` = 'Gujarat Lions'
  THEN 'Gujarat Titans'
  WHEN `winner` = 'Rising Pune Supergiants'
  THEN 'Lucknow Super Giants'
  WHEN `winner` = 'Rising Pune Supergiant'
  THEN 'Lucknow Super Giants'
  WHEN `winner` = 'Pune Warriors'
  THEN 'Lucknow Super Giants'
  WHEN `winner` = 'Royal Challengers Bangalore'
  THEN 'Royal Challengers Bengaluru'
  WHEN `winner` = 'Kings XI Punjab'
  THEN 'Punjab Kings'
  WHEN `winner` = 'Delhi Daredevils'
  THEN 'Delhi Capitals'
  ELSE `winner`
END;
