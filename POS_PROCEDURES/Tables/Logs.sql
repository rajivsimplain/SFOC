USE [POS]
GO

/****** Object:  Table [dbo].[Logs]    Script Date: 2/5/2025 10:20:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Logs](
	[Table_id] [int] NULL,
	[Table_Name] [varchar](100) NULL,
	[Comment] [nvarchar](1000) NULL,
	[CREATED_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](100) NULL,
	[MODIFIED_DATE] [datetime] NULL,
	[MODIFIED_BY] [varchar](100) NULL
) ON [PRIMARY]
GO

