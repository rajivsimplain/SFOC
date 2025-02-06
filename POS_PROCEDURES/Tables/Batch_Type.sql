USE [POS]
GO

/****** Object:  Table [dbo].[Batch_Type]    Script Date: 2/5/2025 10:30:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Batch_Type](
	[BatchType] [varchar](1) NULL,
	[Applymethod] [varchar](20) NULL,
	[DocNum] [numeric](10, 0) NULL,
	[DocName] [varchar](100) NULL,
	[Applytype] [varchar](3) NULL
) ON [PRIMARY]
GO

