<cfset trueClientID = #true_cid#>
<cfif trueClientID eq 3>
  <cfquery name="get_true_cid" datasource="#application.ticket_ds#">
    SELECT k_clnt_client
    FROM ticket
    WHERE pk_ticket = #ID#
  </cfquery>
  <cfset trueClientID = #get_true_cid.k_clnt_client#>
</cfif>

<cfquery name="get_login" datasource="#application.sys_ds#">
  SELECT login_id
  FROM usr_operator
  WHERE pk_usr_operator = #session.login.k_usr_operator#
</cfquery>

<cfquery name="update_time_tracking" datasource="#application.ticket_ds#">
  UPDATE ttt
  SET
     time_tracked = #hrs#
    ,comment = '#commentID#'
    ,cid = #trueClientID#
    ,k_work_type = #worktype#
    ,date_tracked = '#dateTrked#'
  FROM ticket_time_tracking ttt
  WHERE pk_ticket_time_tracking = <cfqueryparam value="#val(id)#" cfsqltype="cf_sql_integer"/>
</cfquery>