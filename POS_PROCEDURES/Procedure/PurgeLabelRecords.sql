USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[PurgeLabelRecords]    Script Date: 2/5/2025 11:20:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  create PROCEDURE [dbo].[PurgeLabelRecords]
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @ParamDays INT

    -- Get the number of days from the parameter table
    SELECT @ParamDays = configno
    FROM lblconfig 
    WHERE configid = 1; 
    -- Calculate the date 30 days ago
    DECLARE @ThirtyDaysAgo DATE
    SET @ThirtyDaysAgo =  DATEADD(day, -@ParamDays, GETDATE())

    -- Delete records older than 30 days
    DELETE FROM stg_label
    WHERE CreatedDate < @ThirtyDaysAgo
END
GO

