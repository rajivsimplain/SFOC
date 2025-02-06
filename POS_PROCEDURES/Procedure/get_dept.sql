USE [POS]
GO

/****** Object:  UserDefinedFunction [dbo].[get_dept]    Script Date: 2/5/2025 11:27:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[get_dept]
(@item_in varchar(50),@opflag int=0 )

RETURNS VARCHAR(100)
AS
  Begin
declare
 @result VARCHAR(100);
 
 IF @opflag=1
 BEGIN
 --get deptname 
  WITH Dname as(
							select   objcint,objpere 
							from etl_strucrel--,#ARTUV
							where objcint = @item_in
							and CAST(GETDATE() AS DATE) between objddeb and objdfin
							union all
							select a.objcint,a.objpere
							from etl_strucrel a ,Dname
							where a.objcint=Dname.objpere 
							and CAST(GETDATE() AS DATE) between objddeb and objdfin )
							(select  @result = TSOBDESC from Dname,ETL_TRA_STRUCOBJ,ETL_STRUCOBJ 
	where Tsobcint=objpere 
	AND SOBCINT=OBJCINT
	--and sobcint=8909748
	and sobidniv=3) 
	END

	
 IF @opflag=2
 BEGIN
 --get deptname 
  WITH Cname as(
							select   objcint,objpere 
							from etl_strucrel
							where objcint =@item_in
							and CAST(GETDATE() AS DATE) between objddeb and objdfin
							union all
							select a.objcint,a.objpere
							from etl_strucrel a ,Cname
							where a.objcint=Cname.objpere 
							and CAST(GETDATE() AS DATE) between objddeb and objdfin )

							(select   @result = reverse(substring(reverse(sobcext),1,3)) from Cname,ETL_TRA_STRUCOBJ,ETL_STRUCOBJ 
	where Tsobcint=objpere 
	AND SOBCINT=OBJCINT
	--and sobcint=8909748
	and sobidniv=4)
	END


	
 IF @opflag=3
 BEGIN
 --get deptname 
  WITH Cname as(
							select   objcint,objpere 
							from etl_strucrel--,#ARTUV
							where objcint = @item_in
							and CAST(GETDATE() AS DATE) between objddeb and objdfin
							union all
							select a.objcint,a.objpere
							from etl_strucrel a ,Cname
							where a.objcint=Cname.objpere 
							and CAST(GETDATE() AS DATE) between objddeb and objdfin )
							(select  @result = TSOBDESC from Cname,ETL_TRA_STRUCOBJ,ETL_STRUCOBJ 
	where Tsobcint=objpere 
	AND SOBCINT=OBJCINT
	--and sobcint=8909748
	and sobidniv=4) 

	END
  RETURN @result;    
 END;
GO

