USE [POS]
GO

/****** Object:  Table [dbo].[XLSBAT]    Script Date: 2/5/2025 10:58:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[XLSBAT](
	[xbaid] [numeric](20, 0) NULL,
	[xbaxprid] [numeric](3, 0) NULL,
	[xbasesid] [numeric](20, 0) NULL,
	[xbafile] [nvarchar](100) NULL,
	[xbahash] [nvarchar](100) NULL,
	[xbasts] [numeric](3, 0) NULL,
	[xbatotlns] [numeric](8, 0) NULL,
	[xbavalerrlns] [numeric](8, 0) NULL,
	[xbainterrlns] [numeric](8, 0) NULL,
	[xbacreby] [nvarchar](20) NULL,
	[xbacredt] [date] NULL,
	[xbaupdby] [nvarchar](20) NULL,
	[xbaupddt] [date] NULL
) ON [PRIMARY]
GO

