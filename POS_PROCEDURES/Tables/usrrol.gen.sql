USE [POS]
GO

/****** Object:  Table [dbo].[USRROL]    Script Date: 2/5/2025 10:57:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[USRROL](
	[urusrid] [numeric](18, 0) NOT NULL,
	[urrolid] [varchar](30) NOT NULL,
	[urcreby] [varchar](50) NOT NULL,
	[urcredt] [date] NULL,
	[urmodby] [varchar](50) NOT NULL,
	[urmoddt] [date] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[USRROL] ADD  DEFAULT (getdate()) FOR [urcredt]
GO

ALTER TABLE [dbo].[USRROL] ADD  DEFAULT (getdate()) FOR [urmoddt]
GO

