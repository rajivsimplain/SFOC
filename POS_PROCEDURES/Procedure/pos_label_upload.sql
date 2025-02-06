USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[Pos_Label_Upload]    Script Date: 2/5/2025 11:18:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Pos_Label_Upload]


AS
BEGIN
DECLARE 
@CNT NVARCHAR(100),
 @I INT=0 ,
 @CN NVARCHAR(100), 
 @ARTCO NVARCHAR(100),
 @STORE nvarchar(100),
 @DOCNUM NVARCHAR(50),
 @OP_FLAG NVARCHAR(50),
 @FOODSTMP NVARCHAR(100),
 @vdrprdid nvarchar(100),
 @NAME NVARCHAR(100),
 @EAP NVARCHAR(50),
 @PRODTYP NVARCHAR(100),
 @PRICE NVARCHAR(50),
 @NOSA NVARCHAR(100),
 @CEXR NVARCHAR(100),
 @UPC NVARCHAR(100),
 @CINR2 NVARCHAR(100),
 @CATGRY NVARCHAR(10),
 @SCATGRY NVARCHAR(10),
 @PVTLBL NVARCHAR(50),
 @PVTLBL2 NVARCHAR(50),
 @DEPT NVARCHAR(10),
 @RX NVARCHAR(100),
 @AGE NVARCHAR(100),
 @SAMPLE NVARCHAR(100),
 @QHP NVARCHAR(100),
 @PRICERQD NVARCHAR(100),
 @QTYRQD NVARCHAR(100),
 @TAX NVARCHAR(100),
 @SCALEABLE NVARCHAR(100),
 @DESCRIPTION NVARCHAR(100),
 @ARCCODE NVARCHAR(100),
 @MULTIUPC NVARCHAR(50),
 @CASEPACK NVARCHAR(50),
 @STRUCT NVARCHAR(100),
 @VDRNUM NVARCHAR(100),
 @STORENUM NVARCHAR(100),
 @VDRNAME NVARCHAR(100),
 @VALUECARD NVARCHAR(100),
 @DEPARTMENT_CODE NVARCHAR(100),
 @ITEM_NAME VARCHAR(18),
 @EA NVARCHAR(100),
 @FREEFORM NVARCHAR(100),
 @RPTCODE NVARCHAR(100),
 @UPCBAR NVARCHAR(50),
 @PROCESSTYPE NVARCHAR(50),
 @MALAMA NVARCHAR(50),
 @FORMNO NVARCHAR(50),
 @LBL NVARCHAR(100),
 @REG NVARCHAR(100),
 @LIMITDESC NVARCHAR(100),
 @DEPTCD NVARCHAR(100),
 @CPM NVARCHAR(100),
 @COLOR NVARCHAR(100),
 @ARTCEXR NVARCHAR(100),
 @ARTTYPP NVARCHAR(100),
 @ARTETAT NVARCHAR(100),
 @ARTCOMP NVARCHAR(100),
 @ARTUSTK NVARCHAR(100),
 @SKU NVARCHAR(50),
 @ARTUFAC NVARCHAR(100),
 @ARTUTIL NVARCHAR(100),
 @WIC NVARCHAR(100),
 @QTYONE NVARCHAR(100),
 @RESTR NVARCHAR(100),
 @ARCN NVARCHAR(100),
 @request_id nvarchar(100),
 @ARCCINR INT,
 @AATCINR INT,
 @ARTDCRE DATE,
 @ARTDMAJ DATE,
  @ART NVARCHAR(100),
 @LOEN NVARCHAR(50),
 @CINR INT,
 @ITEMFLAG CHAR(1),
 @TAB NVARCHAR(100),
 @ERRCNT INT,
 @SESSID INT,
 @VENDOR VARCHAR(10),
 @VENDINT INT,
 @LDATE DATE,
 @PDATE DATE,
 @CINL INT;
 

 begin  try

 
	begin transaction
	RAISERROR('lABEL Loading starts',10,1) WITH NOWAIT
	
	UPDATE A SET SUBMITTED='-2',XLSERR='-1',XLSERRDESC='INVALID SKU' FROM stg_label A
	WHERE NOT EXISTS (SELECT 1 FROM ETL_ARTATTRI WHERE AATCCLA='PRODID' AND AATVALN=A.SKU and CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0)
	AND SUBMITTED='1'

    UPDATE A SET SUBMITTED='-2',XLSERR='1',XLSERRDESC='INVALID VENDOR' FROM stg_label A
	WHERE NOT EXISTS (SELECT 1 FROM ETL_FOUDGENE WHERE FOUCNUF=A.VENDOR AND RUNID=0) AND  SUBMITTED='1'

	SET @ERRCNT=(SELECT COUNT(*) FROM stg_label WHERE SUBMITTED='-2' );--AND XLSSESSIONID=);
	
	RAISERROR('BEFORE TABLE',10,1) WITH NOWAIT

	CREATE TABLE #STG_LABEL_UPLOAD  (RUNID INT,ITEM_IN NUMERIC (18,0),TABLENAME NVARCHAR(50),OP_FLAG NVARCHAR(20),ITEM_EX NUMERIC(18,0),FOODSTMP  INT,PRODTYP INT,NOSA INT,WIC INT,RX INT,SCALEABLE INT,PRICERQD INT,QHP INT,QTYONE INT,QTYRQD INT,RESTR INT,
                                 AGE INT,VALUECARD NVARCHAR(20),TAX INT,DEPT_CODE NVARCHAR(20),ITEM_NAME NVARCHAR(50),UPC NVARCHAR(20),STORE NVARCHAR(20),PRICE NUMERIC(18,0))

								 RAISERROR('starts',10,1) WITH NOWAIT

	DECLARE LABEL_CURSOR CURSOR FOR

	
	    select XLSSESSIONID,SKU,upc,Category,SubCategory,Store,Vendor,LabelEffectiveDate,PriceEffectiveDate from stg_label WHERE SUBMITTED='1' AND ISNULL(@ERRCNT,2)=0;

	--	select * from stg_label_upload

	 
	 OPEN LABEL_CURSOR
		  FETCH NEXT FROM LABEL_CURSOR INTO @SESSID,@SKU,@UPC,@CATGRY,@SCATGRY,@STORE,@VENDOR,@LDate,@PDate;
		  

			WHILE (@@FETCH_STATUS = 0)
			     BEGIN
			     
				set @CINR= (SELECT AATCINR FROM ETL_ARTATTRI WHERE AATCCLA='PRODID' AND AATVALN=@SKU and CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0);
				PRINT @CINR
						  SET @DEPT= (SELECT right('000'+ substring(AATCCLA,6,3),3) FROM ETL_ARTATTRI WHERE AATCINR=@CINR AND AATCCLA LIKE 'DEPT_%'  
						  AND RUNID=0 AND (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN));
						  PRINT @DEPT;
						  
				     /*   with n as(
						select   objcint,objpere 
						from etl_strucrel
						where objcint=@CINR
						and CAST(GETDATE() AS DATE) between objddeb and objdfin
						union all
						select a.objcint,a.objpere
						from etl_strucrel a ,n
						where a.objcint=n.objpere 
						and CAST(GETDATE() AS DATE) between objddeb and objdfin)
						select   @CATGRY=reverse(substring(reverse(sobcext),1,3)) from n,ETL_STRUCOBJ obj
						where sobcint=objpere 
						and sobidniv=4;

						with n  (objcint,objpere)  as(
						select   objcint,objpere 
						from etl_strucrel
						where objcint=@CINR
						and CAST(GETDATE() AS DATE) between objddeb and objdfin
						union all
						select a.objcint,a.objpere
						from etl_strucrel a ,n
						where a.objcint=n.objpere 
						and CAST(GETDATE() AS DATE) between objddeb and objdfin)
						select  @SCATGRY= reverse(substring(reverse(sobcext),1,3)) from n,ETL_STRUCOBJ obj
						where sobcint=objpere 
						and sobidniv=3 ; */


						SET @EA=(SELECT 'EA' FROM ETL_ARTATTRI WHERE AATCCLA='UNITS' AND AATCINR=@CINR and  (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0)); --JUST AS OF NOW
						SET @EAP=(SELECT '.' FROM ETL_ARTATTRI WHERE AATCCLA='UNITS' AND AATCINR=@CINR and  (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0)); --JUST AS OF NOW

				         SET @FREEFORM =(SELECT DISTINCT AATVALN FROM ETL_ARTATTRI WHERE AATCCLA LIKE '%FREEFORM%' AND AATCINR=@CINR AND RUNID=0 AND (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN));

						 PRINT @FREEFORM
						SET @RPTCODE= (SELECT CASE WHEN AATCATT='1' THEN 'A' WHEN AATCATT='2' THEN 'B' WHEN AATCATT='3' THEN 'C' WHEN AATCATT='4' THEN 'O' WHEN AATCATT='5' THEN 'T' ELSE '0' END 
						              FROM ETL_ARTATTRI WHERE AATCCLA = 'RPTCODE' AND AATCINR=@CINR AND RUNID=0 AND (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN));

									  print @rptcode
						SET @LBL =(SELECT DISTINCT TSOBDESC FROM ETL_TRA_STRUCOBJ WHERE TSOBCINT=@CINR AND RUNID=0 AND LANGUE='US');

						print @lbl

                       SET @REG =(SELECT DISTINCT CASE WHEN @UPC IS NOT NULL  THEN '1' ELSE '0' END );


					   SET @PRICE=(SELECT AATVALNUM FROM ETL_ARTATTRI WHERE AATCCLA='PREPRICE' AND AATCINR=@CINR AND RUNID=0 AND  
					   CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN);

					   --SET	@SKU=(SELECT DISTINCT AATVALN FROM ETL_ARTATTRI WHERE AATCCLA ='PRODID' AND AATCATT='PRODID' AND AATCINR=@CINR AND RUNID=0 AND (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN));


					 -- SET @LIMITDESC= (SELECT 'DISC' FROM #STG_LABEL_UPLOAD WHERE  OP_FLAG='D');

					  SET @VENDINT=(select FOUCFIN from ETL_FOUDGENE WHERE FOUCNUF=@VENDOR AND RUNID=0);
					 
					 SET @VDRNUM =@VENDOR ;--(SELECT FOUCNUF FROM ETL_FOUDGENE WHERE FOUCFIN=);					  

					 SET @DEPTCD= (SELECT CASE CONVERT(INT,RIGHT(@DEPT,2)) WHEN 1 THEN 'G' WHEN 2 THEN 'P' WHEN 3 THEN 'M' WHEN 4 THEN 'L' WHEN 5 THEN 'D' WHEN 6 THEN 'S'  WHEN 7 THEN 'B' WHEN 8 THEN 'F' WHEN 9 THEN 'N'  WHEN 10 THEN 'G' WHEN 11 THEN 'R' WHEN 13 THEN 'P' WHEN 14 THEN 'S' WHEN 15 THEN 'X'  ELSE '0' END);

					SET @CPM=(SELECT SUBSTRING(AATVALN,1,12) FROM ETL_ARTATTRI WHERE AATCINR=@CINR AND AATCCLA LIKE '%X3DESC%' AND RUNID=0 AND (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0));			
						
						
					SET @COLOR=(SELECT SUBSTRING(AATVALN,1,12) FROM ETL_ARTATTRI WHERE AATCINR=@CINR AND AATCCLA LIKE '%X2DESC%' AND RUNID=0 AND (CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN));	
							   

					SET @STORENUM =(SELECT PosStore FROM GoldPos_Store_map WHERE GoldStore=@STORE);
				  

					--SET @vdrprdid= (select @vdrprdid=aracean FROM ETL_ARTUC where aracinr=@CINR and runid=0 AND ARASITE=@STORE AND ARACFIN=@VENDINT AND CAST(GETDATE()AS DATE) BETWEEN ARADDEB AND ARADFIN);
					 (select @vdrprdid=aracean,@CINL=ARACINL FROM ETL_ARTUC where aracinr=@CINR and runid=0 AND ARASITE=@STORE AND ARACFIN=@VENDINT 
					 AND CAST(GETDATE()AS DATE) BETWEEN ARADDEB AND ARADFIN);


					 

					 PRINT @VDRPRDID
					 PRINT @CINL
					SET @VDRNAME = (SELECT FOULIBL FROM ETL_FOUDGENE WHERE FOUCNUF=@VENDOR AND RUNID=0 ); --FOUCFIN=(select aracfin from ETL_ARTUC WHERE EFACFIN=@VENDOR));


					PRINT @VDRNAME
					SET @CASEPACK=(SELECT ALLCOEFF FROM ETL_ARTULUL WHERE allcinlp=@CINL AND RUNID=0);  --=(SELECT ARACINL FROM ETL_ARTUC WHERE ARACINR=@CINR AND  ARASITE=@STORE AND  ARACFIN=@VENDINT
				              -- AND CAST(GETDATE()AS DATE) BETWEEN ARADDEB AND ARADFIN AND RUNID=0));

					SET @MULTIUPC= (SELECT DISTINCT 'M'   FROM ETL_ARTCOCA WHERE ARCCINR=@CINR AND RUNID=0   AND ARCIETI=0);
				
					SET @LOEN=(SELECT CASE  WHEN AATCATT = 'LOCAL' THEN 'L' WHEN AATCATT = 'ORGANIC' THEN 'O' ELSE 'A' END AS LN FROM ETL_ARTATTRI WHERE AATCINR=@CINR AND RUNID=0 AND AATCCLA='SGN0'  AND CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN);
					PRINT @LOEN
					SET @UPCBAR=(SELECT DISTINCT  CASE WHEN @VDRNUM<>50379 THEN @UPC ELSE '0' END);
				
				PRINT @UPCBAR

					SET @PROCESSTYPE ='M' --(SELECT CASE WHEN @OP_FLAG ='I' THEN 'N' ELSE 'M' END);
		    
				
					SET @MALAMA= (SELECT CASE WHEN SOCCHAIN =13 THEN 'Y' ELSE 'N' END FROM ETL_SITDGENE WHERE SOCSITE =@store and runid=0);
				 
					SET @FORMNO=(SELECT DISTINCT CASE WHEN @MALAMA='Y' THEN 'UDLRG' ELSE 'FDLS' END );				    
				  

					SET @DOCNUM=(SELECT DISTINCT CASE-- WHEN OP_FLAG ='I' THEN '30'  
									WHEN @UPC BETWEEN '20000000000' AND '29999999999' THEN '11' 
									--WHEN OP_FLAG ='U' THEN '40' WHEN OP_FLAG='D' THEN '13' 
									WHEN  'MKTG'=(SELECT AATCATT FROM ETL_ARTATTRI 
									WHERE AATCCLA='PRODTYP' AND AATCINR=@CINR) THEN '90'
				                    WHEN '2' =(SELECT (RIGHT(AATCCLA,1)) FROM ETL_ARTATTRI  WHERE AATCCLA LIKE 'DEPT_02' AND AATCINR=@CINR) THEN '42' ELSE '40' END );
							
					INSERT INTO FDL_LABEL (RUNID ,EFFDATE,STORNUM,APPLYDT,UPC,EFFTHRU,DEPT,CATEGORYNUM,GROUPNUM,UPCBAR,EA,FREEFORMSZ,RPTCODE,LBLDESC,REGLBL,LIMITDESC,DEPTCD,CPM,COLORDESC,ORDERMVMT,SKU,VENDNUM,VENDNM,vendprodnum,CASEPACK,MULT_UPC,EAP,REGPRICE,LOEN,TAGS_PAGE,DOCNUM,PROCESS_TYPE,FORM_NO) 
					VALUES (@SESSID,@LDATE,@STORENUM,@LDATE,@UPC,@PDATE,@DEPT,@CATGRY,@SCATGRY,@UPCBAR,@EA,@FREEFORM,@RPTCODE,@LBL,@REG,@LIMITDESC,@DEPTCD,@CPM,@COLOR,NULL,@SKU,@VDRNUM,@VDRNAME,@vdrprdid,@CASEPACK,@MULTIUPC,@EAP,@PRICE,@LOEN,1,@DOCNUM,@PROCESSTYPE,@FORMNO);

				--	select * from fdl_label

					--FETCH NEXT FROM LABEL_CURSOR INTO  @SESSID,@UPC,@CINR,@CEXR,@DEPT,@STORE,@PRICE,@OP_FLAG;
					  FETCH NEXT FROM LABEL_CURSOR INTO @SESSID,@SKU,@UPC,@CATGRY,@SCATGRY,@STORE,@VENDOR,@LDate,@PDate;

					UPDATE STG_LABEL SET SUBMITTED=2,modifiedby='Uploadprc' WHERE SKU=@SKU;

                    END;
                    CLOSE LABEL_CURSOR;

					DEALLOCATE LABEL_CURSOR;
					
					

				  

				    DROP TABLE #STG_LABEL_UPLOAD
		   


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
	   0,
       0,
       'LABELUPLOAD',
       CURRENT_TIMESTAMP,
       'Error at Line = '+@ERRLINE+'  -  '+SUBSTRING(ERROR_MESSAGE(), 1, 500) ,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'SIMP');

RAISERROR('END CATCH',10,1) WITH NOWAIT
end catch
END
GO

