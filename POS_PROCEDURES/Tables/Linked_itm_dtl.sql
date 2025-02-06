USE [POS]
GO

/****** Object:  Table [dbo].[LINKED_ITM_DTL]    Script Date: 2/5/2025 10:20:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LINKED_ITM_DTL](
	[DtlID] [int] IDENTITY(1,1) NOT NULL,
	[HdrID] [int] NOT NULL,
	[LnkdItmupc] [varchar](50) NOT NULL,
	[LnkdItmDesc] [varchar](100) NULL,
	[PromoCode] [numeric](10, 0) NULL,
	[LnkdItmVal] [numeric](15, 5) NULL,
	[LnkdItmTyp] [int] NULL,
	[ItemsPerCpn] [int] NULL,
	[PriceMethod] [int] NULL,
	[Scaleable] [varchar](5) NULL,
	[LimitPerTran] [int] NULL,
	[Department] [varchar](10) NULL,
 CONSTRAINT [LNKDtlid_PK] PRIMARY KEY CLUSTERED 
(
	[DtlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

