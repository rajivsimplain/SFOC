USE [POS]
GO

/****** Object:  Table [dbo].[XLSPRO]    Script Date: 2/5/2025 10:58:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[XLSPRO](
	[xprid] [numeric](3, 0) NULL,
	[xprname] [varchar](100) NULL,
	[xprpath] [varchar](100) NULL,
	[xprvalsvc] [varchar](200) NULL,
	[xprcreby] [varchar](20) NULL,
	[xprcredt] [date] NULL,
	[xprupdby] [varchar](20) NULL,
	[xprupddt] [date] NULL,
	[xprtable] [varchar](30) NULL,
	[xprhdrlns] [numeric](18, 0) NULL,
	[xprredirt] [varchar](200) NULL,
	[xprsubvalpkg] [varchar](30) NULL
) ON [PRIMARY]
GO

