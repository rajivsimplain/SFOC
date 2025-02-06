USE [POS]
GO

/****** Object:  Table [dbo].[XLSERRDTL]    Script Date: 2/5/2025 10:58:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[XLSERRDTL](
	[xlserrid] [numeric](18, 0) NULL,
	[xlsproid] [numeric](18, 0) NULL,
	[xlserrcode] [numeric](18, 0) NULL,
	[xlserrname] [varchar](200) NULL,
	[createddt] [date] NULL,
	[createdby] [varchar](20) NULL,
	[updateddt] [date] NULL,
	[updatedby] [varchar](20) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[XLSERRDTL] ADD  DEFAULT (getdate()) FOR [createddt]
GO

ALTER TABLE [dbo].[XLSERRDTL] ADD  DEFAULT (getdate()) FOR [updateddt]
GO

