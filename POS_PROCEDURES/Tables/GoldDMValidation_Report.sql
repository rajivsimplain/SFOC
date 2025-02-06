USE [POS]
GO

/****** Object:  Table [dbo].[GoldDMValidation_Report]    Script Date: 2/5/2025 10:16:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GoldDMValidation_Report](
	[ReportDate] [date] NULL,
	[Table_id] [int] NULL,
	[GoldTabName] [varchar](100) NULL,
	[DMTabName] [varchar](100) NULL,
	[GoldRecCount] [int] NULL,
	[DMRecCount] [int] NULL,
	[CountMatched] [char](1) NULL
) ON [PRIMARY]
GO

