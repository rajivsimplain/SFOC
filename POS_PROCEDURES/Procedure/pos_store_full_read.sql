USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[Pos_Store_Full_Read]    Script Date: 2/5/2025 11:20:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	 CREATE procedure [dbo].[Pos_Store_Full_Read]
	 AS
	begin 
	
	declare 
	
	@CNT INT,
	@SITE varchar(10);

		DECLARE NEW_STORE CURSOR FOR			
					select distinct store_id from pos_store_session where session_type='AUDIT';

					--Purge <7 days older entries
					delete a from pos_store_audit_job_sweeper a ;--where convert(date,created_at)<=convert(date,getdate()-7) ;
					
						 OPEN NEW_STORE
							 FETCH NEXT FROM NEW_STORE INTO @SITE--,@TAB                      
						WHILE (@@FETCH_STATUS = 0)
						BEGIN

					     SET @CNT=isnull((select count(*) from pos_store_audit_job_sweeper),1);

						TRUNCATE TABLE POS_STORE_AUDIT;			

						INSERT into pos_store_audit_job_sweeper select @CNT+1 ,getdate(),null,null,'READ',NULL,'pending',@SITE
											
						  FETCH NEXT FROM NEW_STORE INTO @SITE;--,@TAB;
			               END;

						CLOSE NEW_STORE;
						DEALLOCATE NEW_STORE;
	
	end

GO

