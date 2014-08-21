UPDATE btj SET btj.end_date='8-10-2014', btj.k_usr_operator=565, btj.time_stamp='2014-08-21 10:50:55.550' FROM BRK_broker__TEA_team__JOIN btj INNER JOIN brk_broker b on  btj.k_brk_broker = b.pk_brk_broker INNER JOIN tea_team t on t.pk_tea_team = btj.k_tea_team INNER JOIN tea_team_role r on r.pk_tea_team_role = btj.k_tea_team_role WHERE b.cid = 7 AND b.broker_id = '26666' 


INSERT INTO BRK_broker__TEA_team__JOIN
	(cid
      ,K_brk_broker
      ,K_TEA_team
      ,start_date
      ,time_stamp
      ,K_USR_operator
      ,k_tea_team_role)
VALUES (7,b.pk_brk_broker,398,'08-11-2014', '2014-08-21 10:50:55.550', 565, 4)
FROM BRK_broker__TEA_team__JOIN btj
	INNER JOIN brk_broker b on b.pk_brk_broker = btj.k_brk_broker