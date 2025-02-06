USE [POS]
GO

/****** Object:  Table [dbo].[STG_LABEL_UPLOAD]    Script Date: 2/5/2025 10:53:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[STG_LABEL_UPLOAD](
	[xlssessionid] [varchar](20) NULL,
	[xlserr] [varchar](10) NULL,
	[xlserrdesc] [varchar](100) NULL,
	[SKU] [varchar](13) NULL,
	[upc] [varchar](15) NULL,
	[Category] [varchar](10) NULL,
	[SubCategory] [varchar](10) NULL,
	[Store#] [varchar](10) NULL,
	[Vendor] [varchar](10) NULL,
	[LabelEffectiveDate] [varchar](20) NULL,
	[PriceEffectiveDate] [varchar](20) NULL,
	[CreatedDate] [varchar](20) NULL,
	[CreatedBy] [varchar](20) NULL,
	[ModifiedDate] [varchar](20) NULL,
	[ModifiedBy] [varchar](20) NULL,
	[STATUSNO] [varchar](1) NULL
) ON [PRIMARY]
GO

