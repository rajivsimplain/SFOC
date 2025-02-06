USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[IFInitialize]    Script Date: 2/5/2025 11:16:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Priya Baskaran
-- Create date: 03/04/2023
-- Description:	IF Batch Initialise
-- =============================================
CREATE PROCEDURE [dbo].[IFInitialize]

@P_ifid              INT,
@P_STATUS           INT OUT ,
@P_RUNID            INT OUT ,
--@P_LAST_PERIOD_START DATE OUT ,
@P_LAST_PERIOD_END   VARCHAR(20) OUT --,
--@P_CURR_PERIOD_START DATE OUT ,
--@P_CURR_PERIOD_END   DATE OUT 

AS
BEGIN

DECLARE  @V_LAST_PERIOD_START DATETIME;
 DECLARE  @V_LAST_PERIOD_END   DATETIME;
 DECLARE   @V_CURR_PERIOD_START DATETIME;
   DECLARE @V_CURR_PERIOD_END   DATETIME;
 DECLARE   @V_RUNID             int;
 declare @loc_count int;

    DECLARE  @RUNNING_INSTANCES INT;
	SET @RUNNING_INSTANCES =0;
	 -- Initailize IF interface
   DECLARE @IFSTATUS_INITIAL  int ;
   DECLARE @IFSTATUS_SUCCESS  int ;
   DECLARE @IFSTATUS_ERROR  int;

   SET @IFSTATUS_INITIAL =0 ;
   SET  @IFSTATUS_SUCCESS  =1 ;
   SET @IFSTATUS_ERROR =2 ;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

	  /* INITIALIZE RUN STATUS RECORD INTO IFRUNSTATUS TABLE
    - CHECK IF PREVIOUS INSTANCE IS RUNNING
    - MOVE THE PREVIOUS RECORD TO HISTORY
    - INITIALIZE THE RECORD INTO IFRUNTSTATUS
    - USE THIS VERSION IF YOU NEED LAST PERIOD AND CURRENT PERIOD DATES*/

	SET @loc_count=0;

	SET @RUNNING_INSTANCES = (

    SELECT COUNT(*)
     
      FROM IFCONFIG, IFRUNSTATUS
     WHERE IFCIFID = @P_IFID
       AND IFCCFGNAME = 'MULTIRUN'
       AND IFCCFGVALUES = 'NO'
       AND IFRIFID = IFCIFID
       AND IFRSTATUS = @IFSTATUS_INITIAL);

    IF (@RUNNING_INSTANCES > 0) 
	begin
      select @P_STATUS = 2; --  INSTANCE IS RUNNING
	  end
    ELSE

      BEGIN
	  BEGIN TRY
        SELECT 
           @V_LAST_PERIOD_START= IFRLASTPERIODSTART,
               @V_LAST_PERIOD_END =IFRLASTPERIODEND,
               @V_CURR_PERIOD_START=dateadd(SECOND, (1 / (24 * 60 * 60)),IFRLASTPERIODEND),
               @V_CURR_PERIOD_END = GETDATE()
			    --@V_CURR_PERIOD_END = format(GETDATE(),'MM-dd-yyyy HH:mm:ss')
          FROM IFRUNSTATUS
         WHERE IFRIFID = @P_IFID;
		 set @loc_count = 1;
		 END TRY
   
	BEGIN CATCH
	set @loc_count = 1;
	    SET @V_LAST_PERIOD_START = CURRENT_TIMESTAMP;
        SET @V_LAST_PERIOD_END   = CURRENT_TIMESTAMP;
        SET  @V_CURR_PERIOD_START = CURRENT_TIMESTAMP;
        SET  @V_CURR_PERIOD_END   = CURRENT_TIMESTAMP;
 --     --  WHEN OTHERS THEN
 --      --  SET @P_STATUS = 3; -- ERRORED

 --        -- LOG_ERROR(NULL,
 --              --     'PKIFMGMT.IFINITIALIZE',
 --             --      SQLCODE || SQLERRM || ' - ' || 'IFID -' || P_IFID ||
 --              --     ' STATUS-' || P_STATUS || ' LAST_PERIOD_START - ' ||
 --               --    V_LAST_PERIOD_START || ' LAST_PERIOD_END - ' ||
 --               --   V_LAST_PERIOD_END || ' CURR_PERIOD_START - ' ||
 --                --   V_CURR_PERIOD_START || ' CURR_PERIOD_END - ' ||
 --                --   V_CURR_PERIOD_END);




   END CATCH

	--COMMIT TRANSACTION

	IF (@loc_count=0)
	begin
	  SET @V_LAST_PERIOD_START = CURRENT_TIMESTAMP ;
         SET @V_LAST_PERIOD_END   = CURRENT_TIMESTAMP;
       SET  @V_CURR_PERIOD_START = CURRENT_TIMESTAMP;
      SET  @V_CURR_PERIOD_END   = CURRENT_TIMESTAMP;
	  end
	END

	BEGIN TRANSACTION

	BEGIN TRY

      INSERT INTO IFRUNHISTORY
        (IFHRRUNID,
         IFHIFID,
         IFHSTARTTIME,
         IFHENDTIME,
         IFHSTATUS,
         IFHCURRPERIODSTART,
         IFHCURRPERIODEND,
         IFHLASTPERIODSTART,
         IFHLASTPERIODEND,
         IFHCREATEDATE,
         IFHUPDATEDATE,
         IFHCREATEDBY,
         IFHUPDATEDBY)
        SELECT IFRRUNID,
               IFRIFID,
               IFRSTARTTIME,
               IFRENDTIME,
               IFRSTATUS,
               IFRCURRPERIODSTART,
               IFRCURRPERIODEND,
               IFRLASTPERIODSTART,
               IFRLASTPERIODEND,
               IFRCREATEDATE,
               IFRUPDATEDATE,
               IFRCREATEDBY,
               IFRUPDATEDBY
          FROM IFRUNSTATUS
         WHERE IFRIFID =@P_IFID;

      DELETE FROM IFRUNSTATUS WHERE IFRIFID = @P_IFID;
	 

	  SET @V_RUNID =  NEXT VALUE FOR SEQ_IFRUNID;
	--SET @V_RUNID=1002;

      INSERT INTO IFRUNSTATUS
        (IFRRUNID,
         IFRIFID,
         IFRSTARTTIME,
         IFRENDTIME,
         IFRSTATUS,
         IFRCURRPERIODSTART,
         IFRCURRPERIODEND,
         IFRLASTPERIODSTART,
         IFRLASTPERIODEND,
         IFRCREATEDATE,
         IFRUPDATEDATE,
         IFRCREATEDBY,
         IFRUPDATEDBY,
         IFRSTATUSDESC)

      VALUES
        (@V_RUNID,
         @P_ifid, -- 300
         CURRENT_TIMESTAMP, --SYSDATE
         NULL,
         @IFSTATUS_INITIAL, -- 0 -INITIALIZING
         @V_CURR_PERIOD_START, -- SYSDATE
         @V_CURR_PERIOD_END,
         @V_LAST_PERIOD_START,
         @V_LAST_PERIOD_END,
         CURRENT_TIMESTAMP, -- CURRENT SYSDATE
         CURRENT_TIMESTAMP, --
        CONCAT( 'IF' , @P_IFID),
        CONCAT( 'IF' , @P_IFID),
         'INITIATED');
		 COMMIT TRANSACTION;

	SET  @P_STATUS            = 1; -- INITIATED SUCCESSFULLY
    SET @P_RUNID             = @V_RUNID;
 -- SET    @P_LAST_PERIOD_START = @V_LAST_PERIOD_START;
    --SET   @P_LAST_PERIOD_END   = @V_LAST_PERIOD_END;
	SET   @P_LAST_PERIOD_END   = format(@V_LAST_PERIOD_END,'MM-dd-yyyy HH:mm:ss'); --24hr format
	
  -- SET   @P_CURR_PERIOD_START = @V_CURR_PERIOD_START;
  -- SET   @P_CURR_PERIOD_END   = @V_CURR_PERIOD_END;

   END TRY

   BEGIN CATCH
   set @P_STATUS =3;

  exec LOG_ERROR @P_ifid=@P_ifid,
                  @P_PROG_Name=  'IFINITIALIZE',
                  @P_Error_msg= ERROR_MESSAGE,
				  @P_RUNID=@v_runid;

					ROLLBACK TRANSACTION

   END CATCH
   

 
  --  END 

END
GO

