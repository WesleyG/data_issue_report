INSERT INTO BRK_broker__TEA_team__JOIN (cid,k_brk_broker,K_TEA_team,start_date,time_stamp,K_USR_operator,k_tea_team_role) SELECT 7, b.pk_brk_broker, 460, '08-11-2014', '2014-08-22 10:50:55.550', 565, 4 FROM brk_broker b WHERE b.broker_id = '26666'


/* data issues added some alter table statements */

USE [hca_broker_prod_soundpath]
GO

ALTER TABLE TAG_data_issues
ADD 
	--k_usr_operator int
	--k_tea_team int
	--time_stamp datetime
	team_period_start datetime
GO

USE [hca_broker_prod_soundpath]
GO

ALTER TABLE TAG_issue_status
ADD 
	issue_status_id int
GO

/*
/* note if you try to do this from hca9 there will be an issue as the db name is both on hca9 and hca6 */
USE [hca_broker_prod_soundpath]
GO

/****** Object:  Table [dbo].[tag_issue_comment]    Script Date: 8/26/2014 2:58:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tag_issue_comment](
	[pk_issue_comment] [int] IDENTITY(1,1) NOT NULL,
	[k_TAG_data_issues] [int] NULL,
	[comment] [varchar](max) NULL,
	[k_USR_operator] [int] NULL,
	[time_stamp] [datetime] NULL,
	[user_type] [int] NULL,
	[k_USR_operator_name] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
*/