USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[ETL_Tables_pro1]    Script Date: 2/5/2025 11:09:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[ETL_Tables_pro1] 
@tid varchar(20),@mtabname nvarchar(100),@Runid nvarchar(20),@Processid nvarchar(100)
AS

--This procedure to INCREMENTAL LOAD
--1)Pick the primarykey column from the ETL source table and same column from incremental_temp then make condt like a=a and b=b
--2)Based on the comparision decide the insert/update records . Then update/insert the records to ETL stg table .
--  If update then update Runid also , so the table will lokk a like Gold table
--3) This is for bth auto/manual mode

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
@merge_sqlnew NVARCHAR(MAX),
@update NVARCHAR(MAX),
@Insertqry nvarchar(max),
@Insertqry1 nvarchar(max),
@outqry nvarchar(100),
@cuser varchar(20)='Simp',
@merge2 nvarchar(max),
@created nvarchar(max),
@op_flag nvarchar(5)='I',
@op_flag1 nvarchar(5)='U',
@statusno VARCHAR(20)= '1',
@statusdesc varchar(20)='Loaded',
@createb varchar(20)='Simplain',
--@modifyd varchar(20)='Simplain',
@modifyb varchar(20)='Simplain',
@Rec_count int;


--declare MergeLog nvarchar(max);

begin  try

	begin transaction
	RAISERROR('Incremental Load starts',10,1) WITH NOWAIT

 
  ----- Get constraint columns from ETL Table columns table

 SET @gconscol= (SELECT DISTINCT constraint_column from ETL_Table_Columns where Table_id= @tid); 
 PRINT @gconscol

 set @sql_xml  = (SELECT Cast('<root><U>'+  Replace(@gconscol, ',', '</U><U>')  + '</U></root>' AS XML))
																																				
 SELECT f.x.value('.', 'VARCHAR(MAX)') AS GCNAME INTO #users FROM @sql_xml.nodes('/root/U') f(x)

 --SELECT * FROM #users

 CREATE TABLE #GTemp
(
[ID] [INT] IDENTITY(1,1) NOT NULL,
[Column_id] INT,
[DM_Column_Name] NVARCHAR(4000)
)

 insert into #GTemp select Column_id,DM_Column_Name FROM ETL_Table_Columns WHERE GOLD_Column_Name in (SELECT GCNAME FROM #users) 

 SELECT * FROM #GTemp

 --PRINT #GTemp

 ----- Get constraint columns from ETL staging table

 SELECT ORDINAL_POSITION,COLUMN_NAME into #ETLtemp FROM INFORMATION_SCHEMA.COLUMNS,#Gtemp WHERE TABLE_NAME = @mtabname AND ORDINAL_POSITION=Column_id+9

SELECT * FROM #ETLtemp
 set @cnt=(select count(1) from #GTemp);

  --set @DMtname= (select DM_table_name from ETL_Tables where table_id=@tid);

--End;
PRINT 'ATTRI COUNT';
--print @cnt;

while @cnt>0
begin

print @loopcnt;
 select @loopcnt=column_id from #GTemp where ID=@cnt;


--@loopcnt+2 in stage table we have runid, processid, statusno, statusdesc, createddate, createdby, modifieddate and modifiedby so +8
 set @sqlstr=(select 'S.'+DM_Column_Name from #GTemp where Column_id=@loopcnt)+'='+(select 'D.'+column_name from #ETLtemp where ORDINAL_POSITION=@loopcnt+9) +' AND ';

 PRINT @SQLSTR

-- print 'qwertt'
select @sqlstr;

 set @finalsql=@finalsql+@sqlstr;

 --select 'fin';
 --select @finalsql;

 --set @loopcnt=@loopcnt+1;
 set @cnt=@cnt-1;

end;
--select 'final';
--select  @finalsql;
set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-4)+')'

print 'ssss';

select @finalsql
 

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

--select * FROM #ETLcol

EXEC sp_executesql @fetchcol  


--select * FROM #ETLcol


SET @update = 'UPDATE SET Runid = ' +@Runid+ ', OP_Flag = ''' +@op_flag1+''',  ModifiedDate = getdate() ,'+
          STUFF((SELECT ',D.'+ETLCOL +  ' = S.' + GCOL
        FROM #GOLDcol ,#ETLcol
        WHERE ETLPOS=GPOS+9
        FOR XML PATH('')),1,1,'')
			          
print  @update

print 'update'	

SET @Insertqry = 'INSERT ('+ STUFF((SELECT  ', '+ETLCOL FROM #ETLcol --ORDER BY ETLPOS
       -- WHERE ETLPOS=GPOS
        FOR XML PATH('')),1,1,'')+' ) VALUES (' +@Runid+ ',' +@Processid+ ','''  +@statusno+''','''  +@statusdesc+ ''',''' +@op_flag+ ''''+ ',getdate(),'''  +@createb+ ''' ,getdate(), ''' +@modifyb+ ' '','  +STUFF((SELECT  ','  +GCOL
		FROM #GOLDcol  ORDER BY GPOS 
       -- WHERE ETLPOS=GPOS
        FOR XML PATH('')), 1,1, '')+   ')'
		--,'''  +@createb+ ''' ,
		--SELECT @Insertqry



print @Insertqry 
print 'insert'	


--exec sp_executesql @Insertqry;
SET @merge_sql =''

select @merge_sql=@merge_sql+
'declare @MergeLog TABLE (MergeAction varchar(50)); 
CREATE TABLE #LOG (MergeAction VARCHAR(100),CNT varchar(10));

MERGE '+@mtabname+' AS D
USING INCREMENTAL_TEMP AS S 
ON'+@finalsql+'
--When records are matched, update the records if there is any change
WHEN MATCHED 
THEN  '+@update+  '
--When no records are matched, insert the incoming records from source table to target table
WHEN NOT MATCHED BY TARGET 
THEN  '+@Insertqry +'

OUTPUT $action AS MergeAction INTO @MergeLog;

SELECT MergeAction, Cnt=count(*)
FROM   @MergeLog
GROUP BY MergeAction 

INSERT INTO #LOG SELECT MergeAction, Cnt=count(*)
FROM   @MergeLog
GROUP BY MergeAction 
insert into Logs select  '''+@tid+''','''+@mtabname+''' ,(CONCAT(MergeAction,'' - '')+CONCAT(cnt ,'' Records'')) as comment,
	getdate(),'''+@cuser+''',getdate(),'''+@cuser+''' from #LOG'

	print 'after merge';
--insert into Logs select @tid,@mtabname,(select MergeAction from #LOG group by MergeAction) as comment,getdate(),'s',getdate(),'s';

exec sp_executesql @merge_sql ;

--SELECT @@ROWCOUNT;

--delete from INCREMENTAL_TEMP

COMMIT TRANSACTION
 RAISERROR('END TRY',10,1) WITH NOWAIT
end try


begin catch

RAISERROR('ST CATCH',10,1) WITH NOWAIT

    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;
	DECLARE @ERRLINE varchar(100);

	SELECT   
        @ErrorMessage  = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),
		@ERRLINE=ERROR_LINE(),  
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
       'ETL_Tables_pro1',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');

RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch










GO

