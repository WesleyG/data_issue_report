SELECT 
--distinct mem.member_id,
distinct brk.broker_id, brk.name
FROM mem_membership_window win
	INNER JOIN BRK_training_history bth on bth.k_brk_broker = win.k_brk_broker
	INNER JOIN mem_member_master mem on mem.pk_mem_member_master = win.k_mem_member_master
	INNER JOIN brk_broker brk on brk.pk_brk_broker = win.k_brk_broker
WHERE 1=1
	AND win.start_date < '01-01-2014'
	AND ISNULL(win.end_date, '01-01-2999') >= '01-31-2014'
	AND bth.start_date > '01-15-2014'
	AND bth.Eligibility_Start_Date_on_or_Aftter >= '01-01-2014'
	AND bth.Eligibility_Start_Date_on_or_Aftter <= '12-31-2014'
	AND bth.eligibility_start_date_on_or_before >= '01-01-2014'
	AND bth.eligibility_start_date_on_or_before <= '12-31-2014'
	AND win.cid = 4
	AND win.k_brk_entity_contract_line_item IS NOT NULL

	AND
		/* Window has a transaction in 2014 */	      
			(EXISTS 
				(SELECT k_mem_membership_window 
					FROM brk_Commission_transaction
						INNER JOIN brk_entity_contract_payment_period 
							ON k_brk_entity_contract_payment_period = pk_brk_entity_contract_payment_period
					WHERE k_mem_membership_window = win.pk_mem_membership_window
						AND payment_period >= '01-01-2014'))