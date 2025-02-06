USE [POS]
GO

/****** Object:  Table [dbo].[STG_POS_ITEMS]    Script Date: 2/5/2025 10:53:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[STG_POS_ITEMS](
	[RUNID] [int] NULL,
	[ITEM_IN] [int] NOT NULL,
	[TABLENAME] [varchar](100) NULL,
	[OP_FLAG] [varchar](1) NOT NULL,
	[ITEM_EX] [nvarchar](52) NULL,
	[FOODSTMP] [varchar](1) NULL,
	[PRODTYP] [varchar](4) NULL,
	[NOSA] [nvarchar](32) NULL,
	[WIC] [varchar](1) NULL,
	[RX] [varchar](1) NULL,
	[SCALEABLE] [varchar](1) NULL,
	[PRICERQD] [varchar](1) NULL,
	[QHP] [varchar](1) NULL,
	[QTYONE] [varchar](1) NULL,
	[QTYRQD] [varchar](1) NULL,
	[RESTR] [varchar](1) NULL,
	[AGE] [varchar](1) NULL,
	[VALUECARD] [nvarchar](3) NULL,
	[TAX] [varchar](1) NULL,
	[DEPT_CODE] [nvarchar](13) NULL,
	[ITEM_NAME] [nvarchar](17) NULL,
	[UPC] [nvarchar](14) NULL,
	[STORE] [nvarchar](50) NULL,
	[PRICE] [nvarchar](50) NULL,
	[POINTS] [varchar](5) NULL,
	[SKU] [varchar](80) NULL,
	[REQUEST_ID] [int] NULL,
	[POSITEM] [char](1) NULL,
	[FREEFORM] [varchar](80) NULL,
	[RPTCODE] [varchar](10) NULL,
	[LBLDESC] [varchar](80) NULL,
	[DEPTCD] [varchar](10) NULL,
	[CPM] [varchar](15) NULL,
	[COLOR] [varchar](15) NULL,
	[LOEN] [varchar](10) NULL,
	[VENDOR] [varchar](20) NULL,
	[MULTIUPC] [char](1) NULL,
	[VDRPRODID] [varchar](20) NULL,
	[VDRDESC] [varchar](100) NULL,
	[CASEPACK] [varchar](10) NULL,
	[VENDORIN] [numeric](10, 0) NULL,
	[GOLD_UPC] [varchar](14) NULL,
	[ERRORDESC] [varchar](200) NULL,
	[ITEM_SV] [numeric](10, 0) NULL,
	[PROMOTYPE] [varchar](1) NULL,
	[PRCTYPE] [varchar](10) NULL,
	[EVTCODE] [varchar](10) NULL,
	[LLINKEDUPC] [varchar](18) NULL,
	[LINKEDCODE] [varchar](18) NULL,
	[REGPRICE] [numeric](15, 4) NULL,
	[GPRODTYPE] [varchar](100) NULL,
	[Label_flag] [varchar](5) NULL,
	[DocNum] [numeric](3, 0) NULL,
	[PROEFFDT] [date] NULL,
	[PROENDDT] [date] NULL,
	[REGEFFDT] [date] NULL,
	[REGENDDT] [date] NULL
) ON [PRIMARY]
GO

