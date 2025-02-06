USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[ETL_TableCreation]    Script Date: 2/5/2025 11:07:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[ETL_TableCreation] 
@tid int ,@mode int,@Count bigint, @P_ifid int, @P_RUNID int, @mtabname nvarchar(100) null,@DMtableName nvarchar(max), @LoadType int=1
AS 
declare
@cnt int=0,
@loopcnt int=1,
@sqlstr nvarchar(max),
@finalsql nvarchar(max)='',
@createsql nvarchar(max),
@cmd nvarchar(4000)='',
@key nvarchar(max),
@id nvarchar(max),
@createmod nvarchar(max),
@DMtname nvarchar(128),
@cnt2 nvarchar(100),
@maxcount nvarchar(100),
@new nvarchar(128),
@Gtname nvarchar(100),
@Dtab nvarchar(100);
begin  try
	begin transaction
	RAISERROR('Structure Loading starts',10,1) WITH NOWAIT
	  
	   begin
	   
	   set @Gtname= (select GOLD_table_name from ETL_Tables where table_id=@tid);	
	 
	   begin
	   set @cnt=(select count(1) from ETL_Table_Columns where table_id=@tid);	 
	   set @DMtname= (select DM_table_name from ETL_Tables where table_id=@tid);					
			
		 while @cnt>=1
	     begin		
		   --select * from ETL_Table_Columns where Table_id=10;
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
			--case when len(Default_Value)>0 then ' DEFAULT '+Default_Value else'' end+
			case when nullable='N' then ' NOT NULL' else '' end +',' 
			 from ETL_Table_Columns where table_id=@tid and Column_id = @loopcnt)            		
			set @id= 'Runid Numeric(20,0) NOT NULL, Processid Numeric(20,0) NULL, ' 
			set @createmod = 'StatusNo Numeric(10,0) NULL, StatusDesc Nvarchar(20) NULL, OP_Flag Nvarchar (5) NULL, CreateDate DateTime NULL, CreateBy Nvarchar(20) NULL, ModifiedDate DateTime NULL, ModifiedBy Nvarchar(20) NULL,' 
			set @finalsql=@finalsql+@sqlstr;
			set @loopcnt=@loopcnt+1;
			set @cnt=@cnt-1;
			end
			end
			

		--	print ' check'
		
IF @mode=1       --Auto Mode
          IF OBJECT_ID(@DMtableName, N'U') IS  NULL
		  begin
		 
		   if @mode=1 and @LoadType =0 --Auto Mode and InitialLoad
			Begin
			
			set @key=(select distinct 'constraint '+ constraint_name + '  PRIMARY KEY (RUNID,'+constraint_column+')' from ETL_Table_Columns where Table_id=@tid)
			IF @KEY IS NOT NULL 			
			set @finalsql= '(' +@id+  +@createmod+  substring(@finalsql,1,len(@finalsql)-1)+ ',' +@key+  ')';		
			ELSE
			set @finalsql= '(' +@id+  +@createmod+  substring(@finalsql,1,len(@finalsql)-1)+ ')';

			set @createsql='create table dbo.'+@DMtname +  +@finalsql;
			exec sp_executesql @createsql;
			end					
			end
			
	else
	 begin
	        set @cmd = 'select @Count = count(*) from ' +@DMtableName
			execute sp_ExecuteSQL @cmd, N'@Count bigint output', @Count = @Count OUTPUT
			SELECT @Count			
			if @Count != 0
			begin			
			insert into Logs values(@tid,@DMtableName,'Initial Load Already done',getdate(),'Simp',getdate(),'Simp')	
		end
		end
	
IF @mode=0	 -- Manual Mode	
		IF OBJECT_ID(@DMtableName, N'U') IS NOT NULL 
	  begin			    
            if @mode=0 and @LoadType=0 --Manual Mode and InitialLoad
	        Begin			
			set @key=(select distinct 'constraint '+ constraint_name + '  PRIMARY KEY (RUNID,'+constraint_column+')' from ETL_Table_Columns where Table_id=@tid)			
				IF @KEY IS NOT NULL 			
			set @finalsql= '(' +@id+  +@createmod+  substring(@finalsql,1,len(@finalsql)-1)+ ',' +@key+  ')';		
			ELSE
			set @finalsql= '(' +@id+  +@createmod+  substring(@finalsql,1,len(@finalsql)-1)+ ')';
		
			IF OBJECT_ID(@mtabname, N'U') IS NOT NULL
			begin
			set @Dtab ='DROP TABLE ' +@mtabname;
			exec sp_executesql @Dtab;
		    end;
			begin
			set @createsql='create table  '+@mtabname +' '  +@finalsql;
			execute sp_ExecuteSQL @createsql
			
			--Alter table INITIAL_TEMP add  constraint constraint_name PRIMARY KEY (ARTCINR);
			
		    set @cmd = 'select @Count = count(*) from ' +@DMtableName
		    execute sp_ExecuteSQL @cmd, N'@Count bigint output', @Count = @Count OUTPUT
		    SELECT @Count		    
	        if @Count != 0
			begin			
		      insert into Logs values(@tid,@DMtableName,'Initial Load Already done',getdate(),'Simp',getdate(),'Simp');
			end
	 end
	 end
	 	END
		end
			--update ETL_Tables set  Initialized='Y' where Table_id=@tid;											--CHANGED
			--update ETL_Table_Columns set  Initialized='Y' where Table_id=@tid;									--CHANGED
	 	
COMMIT TRANSACTION
 RAISERROR('END TRY',10,1) WITH NOWAIT
end try
begin catch
--print 'qwert'
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
       'ETL_TableCreation',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');
RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch

  
GO

