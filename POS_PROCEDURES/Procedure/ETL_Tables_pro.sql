USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[ETL_Tables_pro]    Script Date: 2/5/2025 11:07:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[ETL_Tables_pro] 
@tid int ,@mode int,@mtabname nvarchar(100) null,@P_ifid int,@P_RUNID int,@LoadType int =1
AS 

declare
@cnt int=0,
@loopcnt int=1,
@sqlstr nvarchar(max),
@finalsql nvarchar(max)='',
@createsql nvarchar(max),
@key nvarchar(max),
@id nvarchar(max),
@DMtname nvarchar(128),
@createmod nvarchar(max),
@Dtab nvarchar(100);


 --If @LoadType=0 
begin  try

	begin transaction
	RAISERROR('Structure Loading starts',10,1) WITH NOWAIT

 

  set @cnt=(select count(1) from ETL_Table_Columns where table_id=@tid);

  set @DMtname= (select DM_table_name from ETL_Tables where table_id=@tid);


--End;
--print @cnt;

while @cnt>=1
begin

--print @loopcnt;

 set @sqlstr=(select DM_Column_Name +' '+case
  when upper(data_type) ='NUMBER' then dbo.f_sample(data_type)
  when upper(data_type) ='VARCHAR2' then dbo.f_sample(data_type) 
  when upper(data_type) ='Long' then dbo.f_sample(data_type) 
  when upper(data_type) ='RAW([1-2000])' then dbo.f_sample(data_type) 
  when upper(data_type) ='REAL' then dbo.f_sample(data_type) 
  when upper(data_type) ='ROWID' then dbo.f_sample(data_type) 
  when upper(data_type) ='UROWID' then dbo.f_sample(data_type) 
  when upper(data_type) ='TIMESTAMP' then dbo.f_sample(data_type) 
  when upper(data_type) ='FLOAT' then dbo.f_sample(data_type) 
  when upper(data_type) ='DATE' then dbo.f_sample(data_type) end +
  case when upper(data_type)<>'DATE' then '('+rtrim(data_length)+')' else '' end + 
 case when len(Default_Value)>0 then ' DEFAULT '+Default_Value else'' end+
 case when nullable='N' then ' NOT NULL' else '' end +',' 
 from ETL_Table_Columns where table_id=@tid and Column_id = @loopcnt)
 
 set @id= 'Runid Numeric(20,0) NULL, Processid Numeric(20,0) NULL, '
 
 set @createmod = ',StatusNo Numeric(10,0) NULL, StatusDesc Nvarchar(20) NULL, OP_Flag Nvarchar (5) NULL, CreateDate DateTime NULL, CreateBy Nvarchar(20) NULL, ModifiedDate DateTime NULL, ModifiedBy Nvarchar(20) NULL,' 

 print'created'
  print @sqlstr;

 set @finalsql=@finalsql+@sqlstr;
 print @finalsql
 set @loopcnt=@loopcnt+1;
 set @cnt=@cnt-1;

end;

if @mode=1 and @LoadType =0 --Auto Mode and InitialLoad
Begin
set @key=(select distinct 'constraint '+ constraint_name + '  PRIMARY KEY ('+constraint_column+')' from ETL_Table_Columns where Table_id=@tid)
print @key

set @finalsql= '(' +@id+ substring(@finalsql,1,len(@finalsql)-1)+' ' +@key+  +@createmod+')';

--set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-1)+@key+')';
--print 'weret';
print @finalsql

set @createsql='create table '+@DMtname + ' '   +@finalsql;

--print @createsql
End


if @mode=0 and @LoadType=0 --Manual Mode and InitialLoad
Begin 
--set @key=(select distinct 'constraint '+ constraint_name + '  PRIMARY KEY ('+constraint_column+')' from ETL_Table_Columns where Table_id=@tid)
--print @key


set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-1)+')';
--print 'weret';
--print @finalsql
IF OBJECT_ID(@mtabname, N'U') IS NOT NULL
begin
set @Dtab ='DROP TABLE ' +@mtabname;
exec sp_executesql @Dtab;
end;


set @createsql='create table '+@mtabname +' '  +@finalsql;

Alter table INITIAL_TEMP add  constraint constraint_name PRIMARY KEY (ARTCINR); --WHY HARDCODE HERE

End

-------


if @LoadType =1 --Incremental Load and Both Modes
Begin 

set @finalsql= '('+substring(@finalsql,1,len(@finalsql)-1)+')';
--print 'weret';
--print @finalsql
IF OBJECT_ID(@mtabname, N'U') IS NOT NULL
begin
set @Dtab ='DROP TABLE ' +@mtabname;
exec sp_executesql @Dtab;
end;

set @createsql='create table '+@mtabname +' '  +@finalsql;


End;

--print @createsql
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
	   @P_ifid,
       @P_RUNID,
       'ETL_Tables_pro',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');

RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch




GO

