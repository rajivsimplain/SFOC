USE [POS]
GO

/****** Object:  Table [dbo].[ETL_Param]    Script Date: 2/5/2025 10:11:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ETL_Param](
	[PARAM_NAME] [varchar](100) NOT NULL,
	[PARAM_VALUE] [varchar](10) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL
) ON [PRIMARY]
GO

