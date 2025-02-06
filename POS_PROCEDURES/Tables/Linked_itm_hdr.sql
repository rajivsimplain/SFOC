USE [POS]
GO

/****** Object:  Table [dbo].[LINKED_ITM_HDR]    Script Date: 2/5/2025 10:19:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LINKED_ITM_HDR](
	[HdrID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](50) NULL,
	[CategoryID] [numeric](4, 0) NULL,
	[Evtcode] [varchar](10) NULL,
	[FromDate] [date] NULL,
	[ThruDate] [date] NULL,
	[CouponType] [char](1) NULL,
	[CouponValue] [numeric](15, 5) NULL,
	[ItemsPerCpn] [int] NULL,
	[Scaleable] [varchar](5) NULL,
	[LimitPerTran] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[ModifiedDt] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NULL,
 CONSTRAINT [LNKHdrid_PK] PRIMARY KEY CLUSTERED 
(
	[HdrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

