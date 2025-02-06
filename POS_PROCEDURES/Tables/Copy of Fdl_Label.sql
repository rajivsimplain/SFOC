USE [POS]
GO

/****** Object:  Table [dbo].[FDL_LABEL]    Script Date: 2/5/2025 10:14:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FDL_LABEL](
	[RUNID] [numeric](20, 0) NULL,
	[EFFDATE] [date] NOT NULL,
	[STORNUM] [numeric](4, 0) NOT NULL,
	[APPLYDT] [date] NOT NULL,
	[UPC] [numeric](15, 0) NULL,
	[EFFTHRU] [date] NULL,
	[DOCNUM] [numeric](3, 0) NULL,
	[PROCESS_TYPE] [varchar](1) NULL,
	[FORM_NO] [varchar](10) NULL,
	[TAGS_PAGE] [numeric](2, 0) NULL,
	[VENDNUM] [numeric](9, 0) NULL,
	[VENDPRODNUM] [varchar](15) NULL,
	[LBLDESC] [varchar](40) NULL,
	[CASEPACK] [numeric](4, 0) NULL,
	[FREEFORMSZ] [varchar](15) NULL,
	[DEPT] [numeric](4, 0) NULL,
	[DEPTCD] [varchar](1) NULL,
	[PRCMULT] [numeric](3, 0) NULL,
	[PRICE] [numeric](7, 2) NULL,
	[CPM] [varchar](12) NULL,
	[REGPRCMULT] [numeric](3, 0) NULL,
	[REGPRICE] [numeric](7, 2) NULL,
	[MULT_UPC] [varchar](1) NULL,
	[AISLE] [varchar](16) NULL,
	[SAVINGS] [numeric](7, 2) NULL,
	[SAVEMSG] [varchar](5) NULL,
	[GROUPNUM] [nvarchar](4) NULL,
	[CATEGORYNUM] [nvarchar](4) NULL,
	[BATCH] [numeric](3, 0) NULL,
	[BRANDDESC] [varchar](30) NULL,
	[BRANDSZ] [varchar](16) NULL,
	[UNITPRICE] [numeric](7, 2) NULL,
	[SHORTDESC] [varchar](20) NULL,
	[EA] [varchar](2) NULL,
	[LIMIT] [numeric](2, 0) NULL,
	[LIMITDESC] [varchar](10) NULL,
	[EAP] [varchar](1) NULL,
	[MIXMDESC] [varchar](9) NULL,
	[UPCBAR] [numeric](13, 0) NULL,
	[ADVMSG] [varchar](12) NULL,
	[UPRICEMSG] [varchar](11) NULL,
	[EVENTCD] [varchar](4) NULL,
	[ORDERMVMT] [numeric](1, 0) NULL,
	[SPECDESC1] [varchar](30) NULL,
	[SPECDESC2] [varchar](30) NULL,
	[SPECDESC3] [varchar](20) NULL,
	[MUSTBUY] [varchar](20) NULL,
	[SPECDESC4] [varchar](30) NULL,
	[REGLBL] [varchar](1) NULL,
	[LOEN] [varchar](1) NULL,
	[SKU] [varchar](13) NULL,
	[QTYPRICE] [numeric](4, 2) NULL,
	[PCFLAG] [varchar](1) NULL,
	[PRCTYP] [varchar](4) NULL,
	[RPTCODE] [varchar](1) NULL,
	[VENDNM] [varchar](30) NULL,
	[COLORDESC] [varchar](30) NULL,
	[PROEFFFROM] [date] NULL,
	[GLUTENFREEFLG] [varchar](1) NULL,
	[CALORIE] [varchar](20) NULL,
	[SAVINGS1] [numeric](7, 2) NULL,
	[UNITPRICE1] [numeric](7, 2) NULL,
	[MUSTBUY1] [varchar](20) NULL
) ON [PRIMARY]
GO

