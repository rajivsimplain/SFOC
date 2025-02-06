USE [POS]
GO

/****** Object:  Table [dbo].[XLSPROQUEUE]    Script Date: 2/5/2025 10:59:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[XLSPROQUEUE](
	[xqsessionid] [numeric](10, 0) NULL,
	[xqprid] [numeric](10, 0) NULL,
	[queuetime] [date] NULL,
	[batchstarttime] [date] NULL,
	[batchenddtime] [date] NULL,
	[xfilename] [nvarchar](250) NULL,
	[xoriginalfile] [nvarchar](250) NULL,
	[status] [numeric](10, 0) NULL,
	[curstep] [numeric](10, 0) NULL,
	[curstepstatus] [numeric](10, 0) NULL,
	[errormessage] [nvarchar](250) NULL,
	[createdate] [date] NULL,
	[createdby] [nvarchar](30) NULL,
	[modifieddate] [date] NULL,
	[modifiedby] [nvarchar](30) NULL,
	[totallines] [numeric](10, 0) NULL,
	[totalerrorlines] [numeric](10, 0) NULL
) ON [PRIMARY]
GO

