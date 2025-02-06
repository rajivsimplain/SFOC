USE [POS]
GO

/****** Object:  Table [dbo].[USRGEN]    Script Date: 2/5/2025 10:57:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[USRGEN](
	[usrid] [numeric](20, 0) NULL,
	[usrlogin] [varchar](50) NULL,
	[usrpwd] [varchar](60) NULL,
	[usrname] [varchar](50) NULL,
	[usrconame] [varchar](50) NULL,
	[usrmgrid] [numeric](20, 0) NULL,
	[usradrid] [numeric](20, 0) NULL,
	[usrworkph] [varchar](20) NULL,
	[usrcellph] [varchar](20) NULL,
	[usrhomeph] [varchar](20) NULL,
	[usremail] [varchar](50) NULL,
	[usremailcfm] [numeric](20, 0) NULL,
	[usremailcfmcd] [varchar](20) NULL,
	[usrphoto] [numeric](20, 0) NULL,
	[usrphotoext] [varchar](20) NULL,
	[usrstate] [varchar](20) NULL,
	[usrenabled] [numeric](20, 0) NULL,
	[usrchgnotify] [numeric](20, 0) NULL,
	[usrchgpwd] [numeric](20, 0) NULL,
	[usrexpdt] [date] NULL,
	[usrcreby] [varchar](20) NULL,
	[usrcredt] [date] NULL,
	[usrupdby] [varchar](20) NULL,
	[usrupddt] [date] NULL,
	[usrlang] [varchar](5) NULL,
	[usrtmppwd] [varchar](60) NULL,
	[usratmpt] [numeric](20, 0) NULL,
	[usrismail] [numeric](20, 0) NULL,
	[usrpwdexp] [date] NULL,
	[usrfirstname] [varchar](45) NULL,
	[usrlastname] [varchar](45) NULL,
	[usrmiddlename] [varchar](45) NULL,
	[usrponumber] [varchar](15) NULL,
	[usrpodate] [date] NULL,
	[usrstatename] [varchar](25) NULL,
	[usremcdgendt] [date] NULL,
	[usrauthcdgendt] [date] NULL,
	[usrauthcd] [varchar](20) NULL,
	[usrpwdmdfdt] [date] NULL,
	[usrlalogindt] [date] NULL,
	[usrinvalidauthdt] [date] NULL,
	[usrinvalautcdatmpt] [numeric](18, 0) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[USRGEN] ADD  DEFAULT ('US') FOR [usrlang]
GO

