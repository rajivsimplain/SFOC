USE [POS]
GO

/****** Object:  Table [dbo].[XLSCOL]    Script Date: 2/5/2025 10:58:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[XLSCOL](
	[xcoid] [numeric](5, 0) NULL,
	[xcoxprid] [numeric](3, 0) NULL,
	[xcosrccol] [numeric](3, 0) NULL,
	[xcodstcol] [varchar](100) NULL,
	[xcotype] [numeric](3, 0) NULL,
	[xcosize] [numeric](20, 0) NULL,
	[xcoerrmsg] [varchar](100) NULL,
	[xcocreby] [varchar](20) NULL,
	[xcocredt] [date] NULL,
	[xcoupdby] [varchar](20) NULL,
	[xcoupddt] [date] NULL,
	[xcoctlcol] [numeric](18, 0) NULL,
	[xcoupcol] [numeric](18, 0) NULL,
	[xcocollab] [varchar](100) NULL,
	[xconvlcol] [numeric](1, 0) NULL,
	[xcosheetcindx] [numeric](18, 0) NULL,
	[xcocolcomment] [varchar](50) NULL
) ON [PRIMARY]
GO

