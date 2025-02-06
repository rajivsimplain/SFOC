USE [POS]
GO

/****** Object:  Table [dbo].[ETL_Table_Columns]    Script Date: 2/5/2025 10:12:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ETL_Table_Columns](
	[Table_id] [int] NULL,
	[Column_id] [int] NULL,
	[GOLD_Column_Name] [nvarchar](128) NULL,
	[DM_Column_Name] [nvarchar](128) NULL,
	[Data_Type] [nvarchar](128) NULL,
	[Data_Length] [nvarchar](10) NULL,
	[Default_Value] [nvarchar](max) NULL,
	[Nullable] [nchar](1) NULL,
	[constraint_name] [nvarchar](128) NULL,
	[constraint_column] [nvarchar](4000) NULL,
	[Comment] [nvarchar](1000) NULL,
	[Effective_Date] [date] NULL,
	[Expiration_Date] [date] NULL,
	[Initialize_Flag] [char](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

