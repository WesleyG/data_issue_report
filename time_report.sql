SELECT 
	TOP 50 *
FROM ticket_time_tracking
ORDER BY cid, k_ticket

SELECT SUM(time_tracked)
FROM ticket_time_tracking
WHERE 1=1
	AND login_id = 'hca8'
GROUP BY login_id

SELECT SUM(time_tracked), cid
FROM ticket_time_tracking
WHERE 1=1
	AND login_id = 'hca8'
GROUP BY cid


/* report 1 ticket #, date worked, user iD
	WG added hours worked */
SELECT
	 t.k_ticket_number
	,ttt.date_tracked AS Date_Worked
	,ttt.login_id AS User_ID
	,SUM(ttt.time_tracked) AS Hours_worked
	,t.cid
FROM ticket_time_tracking ttt
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
WHERE
	t.pk_ticket = '229'
	AND t.cid = 3
GROUP BY	 t.k_ticket_number
	,ttt.date_tracked
	,ttt.login_id
	,t.cid

/* report 2, work type, date worked, client */
SELECT 
	 wt.work_name
	,ttt.date_tracked AS Date_Worked
	,t.cid
FROM ticket_time_tracking ttt
	INNER JOIN work_type wt on ttt.k_work_type = wt.pk_work_type
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
WHERE t.cid = 3

select * from ticket_time_tracking


/* WG version of report 2 */
SELECT 
	 wt.work_name
	,t.cid
	,sum(ttt.time_tracked) AS Hours_worked
FROM ticket_time_tracking ttt
	INNER JOIN work_type wt on ttt.k_work_type = wt.pk_work_type
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
WHERE t.cid = 3 -- cid variable here
	AND ttt.date_tracked BETWEEN '01-01-2012' AND '12-31-2014' -- date variables here
GROUP BY wt.work_name
	,t.cid


/* report 3 - date worked, client */
SELECT 
	 t.cid
	 ,ttt.date_tracked AS Date_Worked
	,sum(ttt.time_tracked) AS Hours_worked
FROM ticket_time_tracking ttt
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
WHERE t.cid = 3 -- cid variable here
	AND ttt.date_tracked BETWEEN '01-01-2012' AND '12-31-2014' -- date variables here
GROUP BY t.cid
	,ttt.date_tracked
ORDER BY ttt.date_tracked


/* Summary reports
	total hours worked by client */
SELECT 
	 t.cid AS Client
	,sum(ttt.time_tracked) AS Hours_worked
FROM ticket_time_tracking ttt
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
WHERE t.cid = 3 -- cid variable here
	AND ttt.date_tracked BETWEEN '01-01-2012' AND '12-31-2014' -- date variables here
GROUP BY t.cid


/* Summary reports
	total hours by work type */
SELECT 
	 wt.work_name AS Work_type
	,sum(ttt.time_tracked) AS Hours_worked
FROM ticket_time_tracking ttt
	INNER JOIN work_type wt on ttt.k_work_type = wt.pk_work_type
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
WHERE t.cid = 3 -- cid variable here
	AND ttt.date_tracked BETWEEN '01-01-2012' AND '12-31-2014' -- date variables here
GROUP BY wt.work_name

/* Summary reports
	total hours by ticket type */
SELECT 
	 tt.k_ticket_type_name AS Ticket_Type
	,sum(ttt.time_tracked) AS Hours_worked
FROM ticket_time_tracking ttt
	INNER JOIN ticket t ON t.pk_ticket = ttt.k_ticket
	INNER JOIN ticket_type tt on t.k_ticket_type = tt.pk_ticket_type
WHERE t.cid = 3 -- cid variable here
	AND ttt.date_tracked BETWEEN '01-01-2012' AND '12-31-2014' -- date variables here
GROUP BY tt.k_ticket_type_name
