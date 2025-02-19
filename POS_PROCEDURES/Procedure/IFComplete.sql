USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[IFComplete]    Script Date: 2/5/2025 11:15:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IFComplete]

@P_ifid              INT,
@P_STATUS           INT OUT ,
@P_RUNID             INT  

AS
BEGIN
declare @IFSTATUS_SUCCESS int;
set @IFSTATUS_SUCCESS = 1;

 /* UPDATE THE IFRUNSTATUS TABLE WITH STATUS - SUCCESS */

    UPDATE IFRUNSTATUS
       SET IFRENDTIME         = CURRENT_TIMESTAMP,
           IFRSTATUS          = @IFSTATUS_SUCCESS,
           IFRUPDATEDATE      = CURRENT_TIMESTAMP,
           IFRLASTPERIODSTART = IFRCURRPERIODSTART,
           IFRLASTPERIODEND   = IFRCURRPERIODEND,
           IFRCURRPERIODSTART = null,
           IFRCURRPERIODEND   = null,
           IFRSTATUSDESC =  'SUCCESS'
     WHERE IFRIFID = @P_IFID
       AND IFRRUNID = @P_RUNID;

	 set  @P_STATUS =1;

END

GO

