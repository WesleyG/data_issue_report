<cfquery name="q_update_comment" datasource="#application.sys_ds#">
	UPDATE TAG_data_issues
	SET TAG_data_issues.K_USR_operator = #session.login.K_USR_operator#
		,TAG_data_issues.time_stamp = GETDATE()
	WHERE TAG_data_issues.pk_TAG_data_issues = #ID#
</cfquery>

<cfset TheText = REReplaceNoCase( commentID, "\n", "<br/>", "all" )>
<cfoutput>#TheText#</cfoutput><br>

<cfquery name="sel_hca_user" datasource="#application.sys_ds#">
	SELECT LEFT(login_id,3) as login_name, login_id as comment_name
	FROM USR_operator
	where pk_USR_operator = #session.login.K_USR_operator#
</cfquery>


<cfif sel_hca_user.login_name EQ 'hca'>
	<cfset u_type = 1>
<cfelse>
	<cfset u_type = 0>
</cfif>
	
		
<cfquery name="q_sel_type" datasource="#application.sys_ds#">
	INSERT INTO tag_issue_comment
	  (k_TAG_data_issues
      ,comment
      ,k_USR_operator
      ,time_stamp
	  ,user_type
	  ,k_USR_operator_name)
    VALUES
      (#id#
      ,'#TheText#'
      ,#session.login.K_USR_operator#
      ,GETDATE()
	  ,#u_type#
	  ,'#sel_hca_user.comment_name#'
      )
</cfquery>

<cfquery name="q_update_status" datasource="#application.sys_ds#">
	UPDATE TAG_data_issues
	SET TAG_data_issues.k_tag_issue_status_id = #sID#
		,TAG_data_issues.K_USR_operator = #session.login.K_USR_operator#
		,TAG_data_issues.time_stamp = GETDATE()
	WHERE TAG_data_issues.pk_TAG_data_issues = #ID#
</cfquery>





