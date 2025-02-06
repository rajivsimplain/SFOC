USE [POS]
GO

/****** Object:  Table [dbo].[ETL_POSDEPTSTORE]    Script Date: 2/5/2025 10:28:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ETL_POSDEPTSTORE](
	[stornum] [numeric](4, 0) NULL,
	[subdeptfrom] [nvarchar](8) NULL,
	[subdeptnmfrom] [nvarchar](30) NULL,
	[subdeptmappedto] [nvarchar](8) NULL,
	[subdeptnmmappedto] [nvarchar](30) NULL
) ON [PRIMARY]
GO

