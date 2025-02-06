USE [POS]
GO

/****** Object:  Table [dbo].[QRTZ_SCHEDULER_STATE]    Script Date: 2/5/2025 10:49:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[QRTZ_SCHEDULER_STATE](
	[SCHED_NAME] [varchar](120) NOT NULL,
	[INSTANCE_NAME] [varchar](200) NOT NULL,
	[LAST_CHECKIN_TIME] [bigint] NOT NULL,
	[CHECKIN_INTERVAL] [bigint] NOT NULL,
 CONSTRAINT [PK_QRTZ_SCHEDULER_STATE] PRIMARY KEY CLUSTERED 
(
	[SCHED_NAME] ASC,
	[INSTANCE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

