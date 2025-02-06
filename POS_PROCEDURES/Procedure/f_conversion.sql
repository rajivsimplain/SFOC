USE [POS]
GO

/****** Object:  UserDefinedFunction [dbo].[f_conversion]    Script Date: 2/5/2025 11:27:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_conversion]
(@oracle_type varchar(50))

RETURNS VARCHAR(50)
AS
  Begin
declare
 @sqlserver_type VARCHAR(50);
 
  
  set @sqlserver_type = (select case
  when @oracle_type='Number' then 'Numeric' 
  when @oracle_type='Varchar2' then 'Nvarchar' 
  when @oracle_type='Date' then 'DateTime'
  when @oracle_type='Long' then 'VARCHAR(MAX)'
  when @oracle_type='RAW([1-2000])' then 'VARBINARY([1-2000])'
  when @oracle_type='REAL' then 'FLOAT'
  when @oracle_type='ROWID' then 'CHAR(18)'
  when @oracle_type='UROWID' then 'CHAR(18)'
  when @oracle_type='TIMESTAMP' then 'DATETIME'
  when @oracle_type='FLOAT' then 'FLOAT' end)

  RETURN @sqlserver_type;    
 END;
GO

