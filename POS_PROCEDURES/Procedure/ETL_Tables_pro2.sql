USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[ETL_Tables_pro2]    Script Date: 2/5/2025 11:09:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[ETL_Tables_pro2] 
@tid varchar(20),@mtabname nvarchar(100),@P_ifid int,
@P_RUNID int
 
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
@Rec_count int;


print 'weret'
--declare MergeLog nvarchar(max);


begin  try

	begin transaction
	RAISERROR('Structure Loading starts',10,1) WITH NOWAIT



  ----- Get constraint columns from ETL Table columns table

 select @gconscol=constraint_column from ETL_Table_Columns where Table_id=@tid; 

 set @sql_xml  = Cast('<root><U>'+  Replace(@gconscol, ',', '</U><U>')  + '</U></root>' AS XML)
     
 SELECT f.x.value('.', 'VARCHAR(MAX)') AS GCNAME INTO #users FROM @sql_xml.nodes('/root/U') f(x)

 SELECT Column_id,DM_Column_Name into #GTemp FROM ETL_Table_Columns WHERE GOLD_Column_Name in (SELECT GCNAME FROM #users) 

 ----- Get constraint columns from ETL staging table

 SELECT ORDINAL_POSITION,COLUMN_NAME into #ETLtemp FROM INFORMATION_SCHEMA.COLUMNS,#Gtemp WHERE TABLE_NAME = @mtabname AND ORDINAL_POSITION=Column_id+9



 set @cnt=(select count(1) from #GTemp);



  --set @DMtname= (select DM_table_name from ETL_Tables where table_id=@tid);

--End;
print @cnt;

while @cnt>=1
begin

--print @loopcnt;

 set @sqlstr=(select 'S.'+DM_Column_Name from #GTemp where Column_id=@loopcnt)+'='+(select 'D.'+column_name from #ETLtemp where ORDINAL_POSITION=@loopcnt+9) +' AND ';

--print @sqlstr;

 set @finalsql=@finalsql+@sqlstr;

 set @loopcnt=@loopcnt+1;
 set @cnt=@cnt-1;

end;
set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-4)+')'
print @finalsql

 SELECT COLUMN_NAME AS GCOL,ORDINAL_POSITION GPOS into #Goldcol
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME ='INCREMENTAL_TEMP'		
        AND COLUMN_NAME NOT LIKE 'CREATE%'

CREATE TABLE #ETLcol(ETLCOL NVARCHAR(100),ETLPOS INT);
		
DECLARE @fetchcol nvarchar(max) = 
 ' INSERT INTO #ETLcol SELECT COLUMN_NAME AS ETLCOL,ORDINAL_POSITION ETLPOS 
         FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME='+''''+@mtabname+''''
	   -- AND COLUMN_NAME NOT LIKE 'CREATE%'

--declare @ETLcol TABLE (ETLCOL NVARCHAR(100),ETLPOS INT); 

EXEC sp_executesql @fetchcol 


set @merge_sql=
'declare @MergeLog TABLE (MergeAction varchar(50)); 
CREATE TABLE #LOG (MergeAction VARCHAR(100),CNT varchar(10));

MERGE '+@mtabname+' AS D
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

--)TAB ;
--insert into Logs select @tid,@mtabname,(select MergeAction from #LOG group by MergeAction) as comment,getdate(),'s',getdate(),'s';




print @merge_sql

exec sp_executesql @merge_sql ;



--SELECT @@ROWCOUNT;*/
 delete from INCREMENTAL_TEMP

COMMIT TRANSACTION
 RAISERROR('END TRY',10,1) WITH NOWAIT
end try

begin catch

print 'qwert'
 --RAISERROR('ST CATCH',10,1) WITH NOWAIT

    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;
	DECLARE @ERRLINE varchar(100);

	SELECT   
        @ErrorMessage  = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),
		@ERRLINE	   =ERROR_LINE(),  
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
	   @P_ifid,
       @P_RUNID,
       'ETL_Tables_pro2',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');

RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch






GO

