USE [POS]
GO

/****** Object:  Table [dbo].[ETL_POSDEPT]    Script Date: 2/5/2025 10:27:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ETL_POSDEPT](
	[POSDEPT] [int] NULL,
	[POSDEPTNM] [varchar](200) NULL,
	[SUBDEPT] [int] NULL,
	[SUBDEPTNM] [varchar](200) NULL
) ON [PRIMARY]
GO

