USE [POS]
GO

/****** Object:  Table [dbo].[ETL_Tables]    Script Date: 2/5/2025 10:12:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ETL_Tables](
	[Table_id] [int] NULL,
	[GOLD_Table_name] [nvarchar](128) NULL,
	[DM_table_name] [nvarchar](128) NULL,
	[effective_date] [date] NULL,
	[expiration_date] [date] NULL,
	[Initialize_Flag] [char](1) NULL,
	[ETL_START] [datetime] NULL,
	[ETL_END] [datetime] NULL
) ON [PRIMARY]
GO

