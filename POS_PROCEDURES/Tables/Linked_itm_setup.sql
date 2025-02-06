USE [POS]
GO

/****** Object:  Table [dbo].[LINKED_ITM_SETUP]    Script Date: 2/5/2025 10:20:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LINKED_ITM_SETUP](
	[Id] [numeric](8, 0) NOT NULL,
	[cardfrom] [numeric](8, 0) NULL,
	[cardthru] [numeric](8, 0) NULL,
	[cardoffset] [numeric](9, 0) NULL,
	[gencardfrom] [numeric](8, 0) NULL,
	[gencardthru] [numeric](8, 0) NULL,
	[paperfrom] [numeric](8, 0) NULL,
	[paperthru] [numeric](8, 0) NULL,
	[genpaperfrom] [numeric](8, 0) NULL,
	[genpaperthru] [numeric](8, 0) NULL,
	[promoposdesc] [nvarchar](30) NULL
) ON [PRIMARY]
GO

