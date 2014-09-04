
/*

	Declare @sdate datetime, @edate datetime, @sdateprevm datetime
	set @sdate = '4-1-2014'
	set @sdateprevm = '4-1-2014'


*/


/*
	select 
        brk.pk_brk_broker

			--<!--- WGG 10/04/2013 end of most recen team select --->
		--<cfif cid EQ 7>
		,(SELECT TOP 1 team.name FROM BRK_broker__TEA_team__JOIN tj 
			INNER join TEA_team team on team.pk_tea_team = tj.k_tea_team
			WHERE tj.start_date = (select max(start_date)
			from BRK_broker__TEA_team__JOIN teamb
			where teamb.k_brk_broker = tj.k_brk_broker
			and teamb.start_date <= '4-1-2014'
			)
			and tj.k_brk_broker = brk.pk_brk_broker) as team
		--</cfif>
		
        ,brk.name as Rep_Name
        ,brk.broker_id
		,bt.name as broker_type
        ,ag.broker_id as agency_id
		,ag.name as agency_name

		,(
		select count(distinct k_mem_member_master) from mem_membership_window
		where cid = 7 --<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- acive enrollments --->
		and start_date <= '4-1-2014'
		and ( end_date is null or end_date >= '4-1-2014')
		and ( end_date is null or end_date >= '4-1-2014')
		and ( start_date <> end_date or end_date is null)
		and k_brk_broker = brk.pk_brk_broker
		) as enrolled
		
		,(
		select count(distinct k_mem_member_master) from mem_membership_window
		where cid = 7 --<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- disenrolled previous month --->
		and month(end_date) = month('4-1-2014')
		and year(end_date) = year('4-1-2014')
		and start_date < '4-1-2014'
		and start_date <> end_date
		and k_brk_broker = brk.pk_brk_broker
		--<!--- break up by agency ---->

		) as disenrolled
		
		,(
		select count(distinct k_mem_member_master) from mem_membership_window
		where cid = 7-- <cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- rapid dis this month --->
		and month(end_date) = month('4-1-2014')
		and year(end_date) = year('4-1-2014')
		and (datediff(m, start_date, end_date) <= 3)
--		and start_date >= @sdate and start_date <= @edate /* WGG this is truly commented out in the code */
--<cfif rde_exception_setting>
		and not exists(SELECT	pk_mem_membership_window_rde
						from	mem_membership_window_rde
						WHERE	mem_membership_window_rde.k_mem_membership_window = pk_mem_membership_window
								and [is_valid_exception]=1)
--</cfif>
--<cfif jan_rapid_dis_exception_setting>
		and not (month(start_date) >= 10 and month(end_date) <= 2)
--</cfif>
  		and k_brk_broker = brk.pk_brk_broker
		--<!--- break up by agency ---->
		--#preservesinglequotes(agency_sub_count)#
		) as rapiddis
		
		,(
		select count(distinct k_mem_member_master) from mem_membership_window
		where cid = 7 --<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- cancel dis this month --->
		and month(end_date) = month('01-01-2000')
		and year(end_date) = year('01-01-2000')
		and start_date = end_date
  		and k_brk_broker = brk.pk_brk_broker

		--<!--- don't include merged records --->
		and not exists(SELECT	pk_MEM_membership_window_merge
						from	MEM_membership_window_merge
						WHERE	MEM_membership_window_merge.pk_mem_membership_window__t1 = pk_mem_membership_window
								and merge_status = 3)
		--<!--- break up by agency ---->
		--#preservesinglequotes(agency_sub_count)#
		) as cancel
		
		--<!-----KYLE 10/28/2013 - EVOLVESPM-2804 - Add a column named Active value per row should be Active or Termed---->
		--<!---Active or not based on @sdate---->
		, (
		SELECT 'Active' = 
		CASE
			WHEN EXISTS( SELECT * 
					 FROM  brk_broker__BRK_entity_contract_JOIN bc
					 WHERE 1=1 --bc.start_date <= '01-01-2000'
					 AND ( bc.end_date IS NULL OR bc.end_date >= '01-01-2000')
					 AND ( bc.start_date <> bc.end_date OR bc.end_date IS NULL)
					 AND bc.k_brk_broker = brk.pk_brk_broker)
			THEN 'Active'
			ELSE 'Termed'
		END
		) AS Active
		--<!-----KYLE 10/28/2013 - EVOLVESPM-2804 - NEW ADD Rep Term Date <end date of most recent contract which was termed>---->
		--<!--- Term date (end_date of latest contract)--->
		,(
		SELECT TOP 1 end_date
		FROM brk_broker__BRK_entity_contract_JOIN bc
		WHERE bc.cid = 7--<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		AND k_brk_broker = brk.pk_brk_broker
		ORDER BY start_date DESC
		) AS Term
		--<!-----END KYLE 10/28/2013 - EVOLVESPM-2804---->
		
	from brk_broker brk
	INNER JOIN Brk_broker_type_history bth ON bth.k_BRK_broker = brk.pk_brk_broker
	LEFT JOIN Brk_broker_type bt ON bt.pk_brk_broker_type = bth.k_brk_broker_type
/*<cfif application.cid neq 7>
	<!--- agency tab of broker profile --->
	LEFT JOIN BRK_broker__brk_agency_JOIN j
		on j.K_BRK_broker = brk.PK_BRK_broker
		<!--- get all associated agencies --->
		and (
				@sdate between j.start_date and ISNULL( j.end_date , '12/31/2199' )
			)
	left join BRK_broker ag on ag.PK_BRK_broker = j.K_BRK_agency
<cfelse>
*/
	--<!--- molina, use upline to get agency --->
	LEFT JOIN BRK_broker_entity_relation j
		ON brk.PK_BRK_broker = j.K_BRK_broker
		--<!--- get all associated agencies --->
		and (
				--<!--- start prior to search date --->
				(j.start_date <= '01-01-2000')
				or 
				--<!--- after search date --->
				('01-01-2000' <= j.end_date or j.end_date is null)
			)
		--<!--- upline type has to be FMO --->
		and j.K_BRK_broker_entity_relation_type = (select PK_BRK_broker_entity_relation_type from BRK_broker_entity_relation_type where name = 'FMO')

	left join BRK_broker ag on ag.PK_BRK_broker = j.K_BRK_broker__parent
	

--</cfif>

	where brk.cid = 7-- <cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
	
		and exists (
			select k_mem_member_master from mem_membership_window
			where brk.cid = 7-- <cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
			--<!--- acive enrollments --->
			--and start_date <= '01-01-2000'
			and ( end_date is null or end_date <= '01-01-2000')
			and ( start_date <> end_date or end_date is null)
			and k_brk_broker = brk.pk_brk_broker
		)
		--<!---KYLE 10/28/13 - EVOLVESPM-2804 - Need this where clause to work with new filter for number of enrollments--->
		
		AND (SELECT COUNT(DISTINCT k_mem_member_master) FROM mem_membership_window
		WHERE cid = 7--<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- acive enrollments --->
		--AND start_date <= '01-01-2000'
		AND ( end_date IS NULL OR end_date >= '01-01-2000')

		AND ( start_date <> end_date OR end_date IS NULL)

		--AND k_brk_broker = brk.pk_brk_broker
		
		--<!--- break up by agency ---->
					AND (
				j.K_BRK_broker IS NULL OR
				(j.start_date <= start_date
					AND ( j.end_date IS NULL OR j.end_date >= start_date)
				)
			)	
		) >= 1--<cfqueryparam value="#val(numEnrolled)#" cfsqltype="cf_sql_integer"/>
		--AND ('01-01-2000' >= bth.start_date AND ('01-01-2000' <= bth.end_date or bth.end_date IS NULL))
		--<!--- END KYLE 10/28/13 - EVOLVESPM-2804 --->
	
	--<cfif len(broker_id)>
		and brk.broker_id = '29530'--<cfqueryparam value="#broker_id#" cfsqltype="cf_sql_varchar">
		--<cfset empty_qry = false>
	--</cfif>
/*

	<cfif len(agency_id)>
		and ag.broker_id = <cfqueryparam value="#agency_id#" cfsqltype="cf_sql_varchar">
		<cfset empty_qry = false>
	</cfif>

	<cfif empty_qry>
		and 1=2
	</cfif>
*/	
    order by brk.name
--</cfquery>


select b.broker_id, *
from mem_membership_window w
	left join mem_member_master m on w.k_mem_member_master = m.pk_mem_member_master
	left join brk_broker b on w.k_brk_broker = b.pk_brk_broker
where m.member_id = 'QMMC00000568229'

/* enrolled */
select m.member_id
	,w.start_date
	,w.end_date 
from mem_membership_window w
	left join mem_member_master m on w.k_mem_member_master = m.pk_mem_member_master
	left Join brk_broker b on w.k_brk_broker = b.pk_brk_broker
where w.cid = 7 --<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
--<!--- acive enrollments --->
and w.start_date <= '6-1-2014'
and ( w.end_date is null or w.end_date >= '6-1-2014')
and ( w.end_date is null or w.end_date >= '6-1-2014')
and ( w.start_date <> w.end_date or w.end_date is null)
and b.broker_id = '29530'
--and m.member_id = 'QMMC00000568229'

/* disenrolled */
	select  m.member_id
		,w.start_date
		,w.end_date 
	from mem_membership_window w
	left join mem_member_master m on w.k_mem_member_master = m.pk_mem_member_master
	left Join brk_broker b on w.k_brk_broker = b.pk_brk_broker
	where w.cid = 7-- <cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- disenrolled previous month --->
		and month(w.end_date) = month('6-1-2014')
		and year(w.end_date) = year('6-1-2014')
		and w.start_date < '6-1-2014'
		and w.start_date <> w.end_date
		and b.broker_id = '29530'


/* rapids */
	
		select m.member_id
			,w.start_date
			,w.end_date 
		from mem_membership_window w
			left join mem_member_master m on w.k_mem_member_master = m.pk_mem_member_master
			left Join brk_broker b on w.k_brk_broker = b.pk_brk_broker
		where w.cid = 7 --<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- rapid dis this month --->
		and month(w.end_date) = month('6-1-2014') --note this is previous month
		and year(w.end_date) = year('6-1-2014') -- note this is previous month
		and (datediff(m, w.start_date, w.end_date) <= 2)
		and w.start_date <> w.end_date -- WGG 9/4/2014 do not return cancellations
--		and start_date >= @sdate and start_date <= @edate
--<cfif rde_exception_setting>
		and not exists(SELECT	pk_mem_membership_window_rde
						from	mem_membership_window_rde
						WHERE	mem_membership_window_rde.k_mem_membership_window = pk_mem_membership_window
								and [is_valid_exception]=1)
--</cfif>
--<cfif jan_rapid_dis_exception_setting>
		and not (month(w.start_date) >= 10 and month(w.end_date) <= 2)
--</cfif>
  		and b.broker_id = '29530'
		--<!--- break up by agency ---->
		--#preservesinglequotes(agency_sub_count)#


*/

/* 

WGG approximately row 151 of list_rapid_dis_churn_team.htm, try pulling this in evovle
with criteria 7/2014 adn rep 29530, blank agency, 1 min number of enrollments and both
check boxes checked

*/
	select * from mem_membership_window
		where cid = 7--<cfqueryparam value="#val(cid)#" cfsqltype="cf_sql_integer"/>
		--<!--- rapid dis this month --->
		and month(end_date) = month('2014-06-01') --@sdateprevm)
		and year(end_date) = year('2014-06-01') --(@sdateprevm)
		and (datediff(m, start_date, end_date) < 3) -- WGG 9/4/2014 this was <= 3 I believe it should be just < or <= 2 --->
		and start_date <> end_date -- WGG 9/4/2014 do not return cancellations
--		and start_date >= @sdate and start_date <= @edate
--<cfif rde_exception_setting>
		and not exists(SELECT	pk_mem_membership_window_rde
						from	mem_membership_window_rde
						WHERE	mem_membership_window_rde.k_mem_membership_window = pk_mem_membership_window
								and [is_valid_exception]=1)
--</cfif>
--<cfif jan_rapid_dis_exception_setting>
		and not (month(start_date) >= 10 and month(end_date) <= 2)
--</cfif>

  		-- and k_brk_broker = brk.pk_brk_broker
			/* the above line is possibly the issue, replaced with the line below */
		and k_brk_broker = '49558' --broker_id = '29530'

		--<!--- break up by agency ---->
		--#preservesinglequotes(agency_sub_count)#



