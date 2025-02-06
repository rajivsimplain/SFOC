USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[ETL_FutureDate_Delete]    Script Date: 2/5/2025 11:07:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[ETL_FutureDate_Delete] 
@tid varchar(20),@mtabname nvarchar(100),@Runid nvarchar(20),@Processid nvarchar(100),@col varchar(50)
 
AS


DECLARE @MergeLog TABLE (MergeAction varchar(50)); 

DECLARE
@cnt int=0,
@loopcnt int=1,
@sqlstr nvarchar(max),
@finalsql nvarchar(max)='',
@createsql nvarchar(max),
@key nvarchar(max),
@DMtname nvarchar(128),
@Dtab nvarchar(100),
@gconscol nvarchar(max),
@sql_xml XML,
@merge_sql nvarchar(max),
@update NVARCHAR(MAX),
@Deleteqry NVARCHAR(MAX),
@Insertqry nvarchar(max),
@outqry nvarchar(100),
@cuser varchar(20)='Simp',
@merge2 nvarchar(max),
@Rec_count int,
@etltab nvarchar(max),
@updflag nvarchar(max);





begin  try

	begin transaction
	RAISERROR('Incremental Load Delete starts',10,1) WITH NOWAIT


 select @gconscol=constraint_column from ETL_Table_Columns where Table_id=@tid; 

 set @sql_xml  = Cast('<root><U>'+  Replace(@gconscol, ',', '</U><U>')  + '</U></root>' AS XML)
     
 SELECT f.x.value('.', 'VARCHAR(MAX)') AS GCNAME INTO #users FROM @sql_xml.nodes('/root/U') f(x)

 SELECT Column_id,DM_Column_Name into #GTemp FROM ETL_Table_Columns WHERE GOLD_Column_Name in (SELECT GCNAME FROM #users) 

 SELECT ORDINAL_POSITION,COLUMN_NAME into #ETLtemp FROM INFORMATION_SCHEMA.COLUMNS,#Gtemp WHERE TABLE_NAME = @mtabname AND ORDINAL_POSITION=Column_id+9

 
 DECLARE c_getPK CURSOR FOR
 SELECT column_id from #GTemp order by Column_id;

OPEN c_getPK;
FETCH NEXT FROM c_getPK into @loopcnt;

PRINT ' fetch: '+ CAST(@@FETCH_STATUS AS NVARCHAR(5))

WHILE (@@FETCH_STATUS = 0)
   BEGIN
   
 set @sqlstr=(select 'S.'+DM_Column_Name from #GTemp where Column_id=@loopcnt)+'='+(select 'D.'+column_name from #ETLtemp where ORDINAL_POSITION=@loopcnt+9) +' AND ';

 set @finalsql=@finalsql+@sqlstr;
 
 FETCH NEXT FROM c_getPK into @loopcnt;
 END
CLOSE c_getPK
DEALLOCATE c_getPK;


set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-4)+')'
--print @finalsql

--Compare and delete the future date record from ETL table which is deleted in GOLD

set @etltab ='select *,1 delflag into #temp from '+@mtabname +' where '+@col +'>convert(date,getdate())
--print @etltab;
--exec sp_executesql @etltab 

UPDATE D SET delflag=0 FROM #temp D where exists(select 1 from INCREMENTAL_TEMP3 S WHERE '+@finalsql+')
--print @updflag;

--exec sp_executesql @updflag 

--SELECT * FROM #TEMP  WHERE TAPCFIN=1170 AND TAPDDEB>=CONVERT(DATE,GETDATE())
SELECT * INTO '+@mtabname+'_DEL FROM #temp where delflag=1
DELETE D FROM '+@mtabname+' D where exists (select 1 from #temp S WHERE delflag=1 and  '+@finalsql+')

drop table #temp';

--print @etltab;
exec sp_executesql @etltab 


/*
set @merge_sql=
'declare @MergeLog TABLE (MergeAction varchar(50)); 
 CREATE TABLE #LOG (MergeAction VARCHAR(100),CNT varchar(10));

MERGE '+@etltab+' AS D
USING INCREMENTAL_TEMP2 AS S 
ON'+@finalsql+'

WHEN NOT MATCHED BY SOURCE THEN  
DELETE

OUTPUT $action AS MergeAction INTO @MergeLog;

SELECT MergeAction, Cnt=count(*)
FROM   @MergeLog
GROUP BY MergeAction

INSERT INTO #LOG SELECT MergeAction, Cnt=count(*)
FROM   @MergeLog
GROUP BY MergeAction 

insert into Logs select  '''+@tid+''','''+@mtabname+''' ,(CONCAT(MergeAction,'' - '')+CONCAT(cnt ,'' Records'')) as comment,
	getdate(),'''+@cuser+''',getdate(),'''+@cuser+''' from #LOG'




print @merge_sql

exec sp_executesql @merge_sql ; --uncomment after

*/


COMMIT TRANSACTION
 RAISERROR('END TRY',10,1) WITH NOWAIT
end try

begin catch


    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;
	DECLARE @ERRLINE varchar(100);

	SELECT   
        @ErrorMessage  = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),
		@ERRLINE	   = ERROR_LINE(),  
        @ErrorState    = ERROR_STATE();  


ROLLBACK TRANSACTION
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
	   @Processid,
       @Runid,
       'ETL_Incremental Load_Delete',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');

RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch







GO

