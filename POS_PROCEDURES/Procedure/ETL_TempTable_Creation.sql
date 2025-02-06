USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[ETL_TempTable_Creation]    Script Date: 2/5/2025 11:09:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[ETL_TempTable_Creation] 
@tid int ,@mode int,@mtabname nvarchar(100) null,@LoadType int =1,@P_ifid int,
@P_Runid int
AS 

declare
@cnt int=0,
@loopcnt int=1,
@sqlstr nvarchar(max),
@finalsql nvarchar(max)='',
@createsql nvarchar(max),
@key nvarchar(max),
@DMtname nvarchar(128),
@Dtab nvarchar(100);


begin  try

	begin transaction
	RAISERROR('Temptable Creation starts',10,1) WITH NOWAIT

  set @cnt=(select count(1) from ETL_Table_Columns where table_id=@tid);

  set @DMtname= (select DM_table_name from ETL_Tables where table_id=@tid);

while @cnt>=1
begin

 set @sqlstr=(select DM_Column_Name +' '+case
  when upper(data_type) ='NUMBER' then dbo.f_conversion(data_type)
  when upper(data_type) ='VARCHAR2' then dbo.f_conversion(data_type) 
  when upper(data_type) ='Long' then dbo.f_conversion(data_type) 
  when upper(data_type) ='RAW([1-2000])' then dbo.f_conversion(data_type) 
  when upper(data_type) ='REAL' then dbo.f_conversion(data_type) 
  when upper(data_type) ='ROWID' then dbo.f_conversion(data_type) 
  when upper(data_type) ='UROWID' then dbo.f_conversion(data_type) 
  when upper(data_type) ='TIMESTAMP' then dbo.f_conversion(data_type) 
  when upper(data_type) ='FLOAT' then dbo.f_conversion(data_type) 
  when upper(data_type) ='DATE' then dbo.f_conversion(data_type) end +
  case when upper(data_type)<>'DATE' then '('+rtrim(data_length)+')' else '' end + 
 case when len(Default_Value)>0 then ' DEFAULT '+Default_Value else'' end+
 case when nullable='N' then ' NOT NULL' else '' end +',' 
 from ETL_Table_Columns where table_id=@tid and Column_id = @loopcnt)

 set @finalsql=@finalsql+@sqlstr;
 set @loopcnt=@loopcnt+1;
 set @cnt=@cnt-1;

end;

if @mode=1 and @LoadType =0 --Auto Mode and InitialLoad
Begin
set @key=(select distinct 'constraint '+ constraint_name + '  PRIMARY KEY ('+constraint_column+')' from ETL_Table_Columns where Table_id=@tid)

set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-1)+@key+')';

set @createsql='create table '+@DMtname +' '  +@finalsql;
End

if @mode=0 and @LoadType=0 --Manual Mode and InitialLoad
Begin 

set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-1)+')';

IF OBJECT_ID(@mtabname, N'U') IS NOT NULL
begin
set @Dtab ='DROP TABLE ' +@mtabname;
exec sp_executesql @Dtab;
end;
set @createsql='create table dbo.'+@mtabname +' '  +@finalsql;

End
-------

if @LoadType =1 --Incremental Load and Both Modes
Begin 

set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-1)+')';

IF OBJECT_ID(@mtabname, N'U') IS NOT NULL
begin
set @Dtab ='DROP TABLE ' +@mtabname;
exec sp_executesql @Dtab;
end;

set @createsql='create table dbo.'+@mtabname +' '  +@finalsql;

End;

exec sp_executesql @createsql;

update ETL_Tables set  Initialize_Flag='Y' where Table_id=@tid;


COMMIT TRANSACTION
 RAISERROR('END TRY',10,1) WITH NOWAIT
end try

begin catch

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
       'ETL_TEMPTABLE_CREATION',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');

RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch







GO

