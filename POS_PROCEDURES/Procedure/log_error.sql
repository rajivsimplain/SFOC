USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[LOG_ERROR]    Script Date: 2/5/2025 11:17:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LOG_ERROR]

@P_ifid              INT,
@P_PROG_Name           varchar(100)  ,
@P_Error_msg         varchar(100)  ,
@P_RUNID             INT 

AS
BEGIN

declare @loc_IFEID int;


SET @loc_IFEID =  NEXT VALUE FOR Seq_IFEID;

   insert into IFERROR
      (IFEID,
	  IFEIFID,
       IFERUNID,
       IFEPRGNAME,
       IFEERRORDATE,
       IFEERRORMSG,
       IFECREATEDATE,
       IFEMODIFYDATE,
       IFECREATEBY)
    values
      (@loc_IFEID,
	  @P_ifid,
       @P_RUNID,
       @P_PROG_NAME,
       CURRENT_TIMESTAMP,
       @P_ERROR_MSG,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');


END

GO

