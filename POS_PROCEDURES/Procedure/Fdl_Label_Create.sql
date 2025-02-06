USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[Fdl_Label_Create]    Script Date: 2/5/2025 11:10:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Fdl_Label_Create]
@RUNID INT,
@PROCEESID INT,
@effdt date


AS

DECLARE 
@CNT NVARCHAR(100),
 @I INT=0 ,
 @CN NVARCHAR(100),
 @ATTCN NVARCHAR(100),

 @GOLDSTORE NVARCHAR(50),
 @ARTCO NVARCHAR(100),
 @STORE nvarchar(100),
 @DOCNUM NVARCHAR(50),
 @OP_FLAG NVARCHAR(50),
 @FOODSTMP NVARCHAR(100),
 @vdrprdid nvarchar(100),
 @REQCOUNT NVARCHAR(100),
 @EAP NVARCHAR(50),
 @PRODTYP NVARCHAR(100),
 @PRICE NVARCHAR(50),
 @NOSA NVARCHAR(100),
 @CEXR NVARCHAR(100),
 @UPC NVARCHAR(100),
 @ITEM_IN NVARCHAR(100),
 @ITEM_SV NVARCHAR(100),
 @CATGRY NVARCHAR(10),
 @SCATGRY NVARCHAR(10),
 @PVTLBL NVARCHAR(50),
 @PVTLBL2 NVARCHAR(50),
 @DEPT NVARCHAR(10),
 @RX NVARCHAR(100),
 @lblsize nvarchar(50),
 @sgnsize nvarchar(50),
 @form nvarchar(50),
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
 @VDRIN numeric(10),
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
 @ARTUFAC NVARCHAR(100),
 @ARTUTIL NVARCHAR(100),
 @WIC NVARCHAR(100),
 @QTYONE NVARCHAR(100),
 @SKU NVARCHAR(100),
 @RESTR NVARCHAR(100),
 @ARCN NVARCHAR(100),
 @request_id nvarchar(100),
 @ARCCINR INT,
 @AATCINR INT,
 @ARTDCRE DATE,
 @ARTDMAJ DATE,
 @INPUT_CURSOR NVARCHAR(100),
 @ART NVARCHAR(100),
 @LOEN NVARCHAR(50),
 --@ITEM_IN INT,
 @ITEMFLAG CHAR(1),
 @TAB NVARCHAR(100),
 @RECCNT INT,
 @VENDOR VARCHAR(10),
 @ARVCLIBL INT,
 @GUPC NVARCHAR(14),
 @PRODTYPE NVARCHAR(15),
 @PRCTYPE NVARCHAR(15),
 @GPRODTYPE NVARCHAR(15),
 @EVTCODE NVARCHAR(15),
 @PROMOTYPE NVARCHAR(15),
 @REGPRICE NUMERIC(15,4),
 @GOLDUPC VARCHAR(14),
 @RAVIMULTI int,
 @PAVIMULTI INT,
 @REFFFROM DATE,
 @REFFTHRU DATE,
 @PEFFFROM DATE,
 @PEFFTHRU DATE,
 @DOWSTART INT,
			@LEADTIME INT,
			@SCHEDCD VARCHAR(30),
			@EVENTCODE VARCHAR(30),
			@X3DESC VARCHAR(100),
			@X2DESC VARCHAR(100),
			@X1DESC VARCHAR(100),
			@DDATE DATE,
			@DCODE VARCHAR(2),
				@uom varchar(5),

   @C_AUTH         VARCHAR(1) = '1', -- Price change reason code
   @C_LABEL        VARCHAR(1) = '2', -- Force a label
   @C_PRICE        VARCHAR(1) = '3',
   @C_OFF          VARCHAR(1) = '4',
   @C_REQUEST      VARCHAR(1) = '5',
   @C_FLAG         VARCHAR(1) = '6',
   @C_UPC          VARCHAR(1) = '7',

   @C_AUTOAPPLY  VARCHAR(1) = 'A',
   @C_MANUAL     VARCHAR(1) = 'M',
   @C_ADVANCE    VARCHAR(1) = 'V',
   @C_NEWITEM    VARCHAR(1) = 'N',
   @C_OFFPROMO   VARCHAR(1) = 'O',

   @C_DELETE  VARCHAR(1) = 'D', -- Operation codes (note sort order)
   @C_INSERT  VARCHAR(1) = 'I', -- No longer used
   @C_UPDATE  VARCHAR(1) = 'U';

  -- @l LABEL_TYPE;   --USER DEFINED TABLE AS FDL_LABEL


 
 
BEGIN

	--BEGIN TRANSACTION 

	--BEGIN TRY

	

	RAISERROR('Initial Load Starts....',10,1) WITH NOWAIT

	            SELECT --@DOWSTART=PARVAN1 ,@LEADTIME=PARVAN4,@SCHEDCD=TPARLIBC ,@EVENTCODE=TPARLIBL
	            PARVAN1 DOWSTART,PARVAN4 LEADTIME,PARVAC1 OFFLEADTIME,TPARLIBC SCHEDCD,TPARLIBL EVENTCODE
				INTO #SCHDTAB
				FROM ETL_PARPOSTES A,ETL_TRA_PARPOSTES  B WHERE  A.PARTABL=B.TPARTABL AND A.PARCMAG=B.TPARCMAG AND B.LANGUE='US'
				AND PARTABL=9500 AND A.PARCMAG=0 AND A.PARPOST=B.TPARPOST  ;--AND TPARLIBL=ISNULL(@EVTCODE,'ADMK')

				--SELECT * FROM #SCHDTAB

	DECLARE @TODAY DATE =CONVERT(DATE,GETDATE()),
			@TOMORROW date =convert(date,getdate()+1);
	
	--SELECT * FROM #REGPRICE

       

        

				/*	  SELECT UPC,ITEM_IN,ITEM_SV,ITEM_EX,DEPT_CODE,STORE,PRICE,OP_FLAG,SKU,FREEFORM,RPTCODE,DEPTCD,LBLDESC,CPM,COLOR,LOEN,VENDOR,VENDORIN,
					  VDRPRODID,VDRDESC,GOLD_UPC,PROMOTYPE,PRCTYPE,EVTCODE,REGPRICE,GPRODTYPE,GOLD_UPC
					  FROM stg_pos_items_010825 WHERE OP_FLAG !='D' AND 
					  RUNID=@RUNID AND UPC IS NOT NULL AND STORE IS NOT NULL AND VENDOR IS NOT NULL AND PRICE > .09 ;*/

					--  AND STORE IN (SELECT GoldStore FROM GoldPos_Store_map) ;
					  

				--	 DECLARE STO_CUR CURSOR FOR
					-- SELECT GoldStore,PosStore FROM GoldPos_Store_map;

					  	RAISERROR('Label processing Starts',10,1) WITH NOWAIT
						--OPEN STO_CUR
					--	FETCH NEXT FROM STO_CUR INTO @GOLDSTORE,@STORE;

					/*FETCH NEXT FROM LAB_CURSOR INTO @UPC,@ITEM_IN,@ITEM_SV,@CEXR,@DEPT,@GOLDSTORE,@PRICE,@OP_FLAG,@SKU,@FREEFORM,@RPTCODE,@DEPTCD,
					@LBL,@CPM,@COLOR,@LOEN,@VENDOR,@VDRIN,@VDRPRDID,@VDRNAME,@GUPC,@PROMOTYPE,@PRCTYPE,@EVTCODE,@REGPRICE,@GPRODTYPE,@GOLDUPC*/

					 --  RAISERROR('Label AFTER FETCH',10,1) WITH NOWAIT
					  
                 --     WHILE @@FETCH_STATUS =0
                    --    BEGIN

	 --DECLARE LAB_CURSOR CURSOR FOR 

		SELECT * INTO TMP_FDL_LABEL FROM (

		  SELECT  
 			@TODAY APPLYDT   ,            
            @C_UPDATE AS OPERATION
           ,@C_NEWITEM AS applytyp
               ,@C_AUTH as reasoncd
			   ,  ITEM_IN,
				 UPC,
				 storenum,
				 item_sv,
				  price,
				 PEFFFROM,
				PEFFTHRU,
		 PAVIMULTI,
		EVENTCoDe,			  
		 PRCTYPE,
		ARVCLIBL ,
		DCODE,
		DDATE,
		VDRIN,
		VDRPRDID,ARACINL
		FROM dbo.GET_PRICE(CONVERT(DATE,GETDATE())) T
		WHERE EXISTS(SELECT 1 FROM stg_pos_items_010825 V WHERE V.ITEM_IN=T.ITEM_IN AND V.STORE=T.STORENUM AND V.VENDORIN=VDRIN AND V.OP_FLAG='I' AND RUNID=@RUNID) 

		UNION ALL
		
		  SELECT     --UPDATE OPEARTION
 			@TODAY APPLYDT   ,            
               @C_UPDATE AS OPERATION
               ,@C_NEWITEM AS applytyp
               ,@C_AUTH as reasoncd
			   ,  ITEM_IN,
				 UPC,
				 storenum,
				 item_sv,
				  price,
				 PEFFFROM,
				PEFFTHRU,
		 PAVIMULTI,
		 EVENTCoDe,			  
		 PRCTYPE,
		 ARVCLIBL ,
		 DCODE,
		 DDATE,
		 VDRIN,
		 VDRPRDID,ARACINL
		FROM GET_PRICE(CONVERT(DATE,GETDATE())) T
		WHERE EXISTS
		(SELECT 1 FROM stg_pos_items_010825 V WHERE V.ITEM_IN=T.ITEM_IN AND V.STORE=T.STORENUM AND V.VENDORIN=VDRIN AND CHARINDEX('T',V.OP_FLAG,1)>0 AND RUNID=@RUNID) --temp. X then update U
		
		UNION ALL

		 SELECT distinct	
				 PEFFFROM APPLYDT,
		          @C_UPDATE AS operation
				  ,'M' AS applytyp
				 ,@C_PRICE AS reasoncd
				 ,  ITEM_IN,			
				 UPC,
				 storenum,
				 item_sv,
				  price,
				 PEFFFROM,
				PEFFTHRU,
		 PAVIMULTI,
		 EVENTCoDe,			  
		 PRCTYPE,
		 ARVCLIBL ,
		 DCODE,
		 DDATE,
		 VDRIN,
		 VDRPRDID,ARACINL
		FROM GET_PRICE(CONVERT(DATE,GETDATE())) T
		WHERE EXISTS
		(SELECT 1 FROM stg_pos_items_010825 V WHERE V.ITEM_IN=T.ITEM_IN AND V.STORE=T.STORENUM AND V.VENDORIN=VDRIN AND CHARINDEX('X',V.OP_FLAG,1)>0 AND RUNID=@RUNID) --temp. X then update U
	
		/* JOIN #SCHDTAB S ON S.EVENTCODE=T.EVENTCODE
		 WHERE PEFFFROM  BETWEEN @TODAY AND @TODAY+9
		 AND   (PEFFFROM - ISNULL(S.LEADTIME,0))= @TODAY      */

			/*	UNION ALL

      	 SELECT distinct	
			 PEFFTHRU+1 APPLYDT,
		          @C_UPDATE AS operation
               ,CASE WHEN PATATT='REG' THEN @C_MANUAL ELSE @C_OFFPROMO END AS APPLYTYP
               ,CASE WHEN PATATT='REG' THEN @C_PRICE ELSE @C_OFF END AS reasoncd,
			    ITEM_IN,
				 UPC,
				 storenum,
				 item_sv,
				  price,
				 PEFFFROM,
				PEFFTHRU,
		 PAVIMULTI,
		EVENTCoDe,			  
		 PRCTYPE,
		ARVCLIBL ,
		DCODE,
		DDATE,
		VDRIN,
		VDRPRDID
		FROM GET_PRICE(CONVERT(DATE,GETDATE())) S			
		JOIN #SCHDTAB T ON T.EVENTCODE=S.EVENTCODE
		WHERE 
	     PEFFTHRU BETWEEN @TODAY AND @TODAY+9       
		 AND   PEFFTHRU-ISNULL(OFFLEADTIME, 1) + 1=@TODAY */
		 ) AS TAB
		
 

					
SELECT * INTO #TAB
FROM   

   (SELECT AATCINR,AATCCLA,AATCATT
    FROM ETL_ARTATTRI A INNER  JOIN TMP_FDL_LABEL B  ON A.AATCINR=B.ITEM_IN 
	 AND (APPLYDT) BETWEEN A.AATDDEB AND A.AATDFIN 
				 AND (AATCCLA IN ('PRODTYP','RX','SCALE','PRICERQD','TAX','POSITEM','RPTCODE','LINK_CD','X1DESC','X2DESC','X3DESC','UOM'))
								 AND a.RUNID=0    
		--	OR ((AATCCLA LIKE 'DEPT%')  OR (AATCCLA LIKE 'SUB_%')))  
    UNION ALL
	SELECT AATCINR,AATCCLA, AATVALN AS AATCATT
    FROM ETL_ARTATTRI A INNER  JOIN TMP_FDL_LABEL B  ON A.AATCINR=B.ITEM_IN  
	 AND (APPLYDT) BETWEEN A.AATDDEB AND A.AATDFIN  AND A.RUNID=0
				 AND AATCCLA in ('PRODID','FREEFORM')) T	

PIVOT(
    max(aatcatt) 
    FOR AATCCLA IN 
        ([PRODTYP],[RX],[SCALE],[PRICERQD],[TAX],[POSITEM],[RPTCODE],[LINK_CD],[PRODID],[X1DESC],[X2DESC],[X3DESC],[FREEFORM],[UOM])
        ) AS pivot_table;


		
 RAISERROR('Get POS Dept....',10,1) WITH NOWAIT
 
 select AATCINR,AATCCLA,SUBDEPT,AATCATT INTO #DEPT
 FROM
   (SELECT AATCINR,AATCCLA, substring(AATCATT,CHARINDEX('_',AATCATT)+1,len(AATCATT)) as SUBDEPT ,AATCATT 
    FROM ETL_ARTATTRI A INNER  JOIN TMP_FDL_LABEL B  ON A.AATCINR=B.ITEM_IN 
	 AND CAST(GETDATE() AS DATE) BETWEEN A.AATDDEB AND A.AATDFIN 
	AND (AATCCLA LIKE 'DEPT%')  AND A.RUNID=0 ) T;

	

	SELECT AATCINR,MIN(AATCCLA) AATCCLA,MIN(AATCATT) AATCATT ,MIN(AATVALNUM) AATVALNUM INTO #LBLSGN FROM
	 (SELECT AATCINR,AATCCLA,AATCATT,AATVALNUM
    FROM ETL_ARTATTRI A INNER  JOIN TMP_FDL_LABEL B  ON A.AATCINR=B.ITEM_IN 
	 AND CAST(APPLYDT AS DATE) BETWEEN A.AATDDEB AND A.AATDFIN 
	AND (AATCCLA LIKE 'LBL%' OR AATCCLA LIKE 'SGN%')  AND A.RUNID=0) T
	GROUP BY AATCINR,AATCCLA;


	SELECT * INTO #SITATTRI FROM ETL_SITATTRI WHERE SATCLA='SIGNAGE' AND RUNID=0;

	 
	    DECLARE @APPLYDT DATE,
		@REASONCD VARCHAR(1),
		@APPLYTYP VARCHAR(1),
		@SIGNVALUE VARCHAR(1),
		@LBLTYPE VARCHAR(1),
		@SIGNSIZE VARCHAR(1),
		@REGPRICE1 NUMERIC(15,2),
		@group numeric(5),
		@ARACINL NUMERIC(8);


		 DECLARE LAB_CURSOR CURSOR 
		  LOCAL STATIC FORWARD_ONLY READ_ONLY
		 FOR
		 SELECT APPLYDT,OPERATION,APPLYTYP,REASONCD,storenum,ITEM_IN,ITEM_SV,PRICE,PEFFFROM,PEFFTHRU,PAVIMULTI,PRCTYPE,EVENTCODE,UPC,ARVCLIBL,DCODE,
		        DDATE,VDRIN,VDRPRDID,ARACINL FROM TMP_FDL_LABEL
		 WHERE PRICE>0.01 AND OPERATION<>'D' AND EXISTS(SELECT 1 FROM #SITATTRI WHERE SATCLA='SIGNAGE' AND SATSITE=STORENUM) --AND SATATT!='N' 
		-- SELECT GoldStore,PosStore FROM GoldPos_Store_map;
	
		  	RAISERROR('Label processing Starts',10,1) WITH NOWAIT
			OPEN LAB_CURSOR
		--	FETCH NEXT FROM STO_CUR INTO @GOLDSTORE,@STORE;
	
		FETCH NEXT FROM LAB_CURSOR INTO @APPLYDT,@OP_FLAG,@APPLYTYP,@REASONCD,@GOLDSTORE,@ITEM_IN,@ITEM_SV,@PRICE,
		                                @PEFFFROM,@PEFFTHRU,@PAVIMULTI,@PRCTYPE,@EVTCODE,@UPC,@ARVCLIBL,@DCODE,@DDATE,@VDRIN,@VDRPRDID,@ARACINL
	
		
	
					 --  RAISERROR('Label AFTER FETCH',10,1) WITH NOWAIT
					  
                 --     WHILE @@FETCH_STATUS =0


				set @lblsize= (SELECT distinct RIGHT(AATCATT, 1) from #LBLSGN where aatcinr=@ITEM_IN AND AATCCLA LIKE 'LBL%')		
				set @LBLTYPE= (SELECT distinct left(AATCATT, 1) from #LBLSGN where aatcinr=@ITEM_IN AND AATCCLA LIKE 'LBL%')		
				
            
		      set @SIGNSIZE= (SELECT distinct 
			    CASE WHEN left(AATCATT, 1) ='A'  THEN 'A' 
				WHEN left(AATCATT, 1) ='O' THEN 'O'
				WHEN left(AATCATT, 1) ='L' THEN 'L'
                WHEN left(AATCATT, 1) ='P' THEN 'P'
                WHEN left(AATCATT, 1) ='H' THEN 'H'
				WHEN left(AATCATT, 1) ='E' THEN 'E'
				WHEN left(AATCATT, 1) ='N'  THEN'N'		
				WHEN RIGHT(AATCATT, 1) ='X' THEN 'X'		
				 END from #LBLSGN where aatcinr=@ITEM_IN AND AATCCLA LIKE 'SGN%')

          SET @SIGNVALUE=(SELECT SATATT FROM ETL_SITATTRI WHERE  SATCLA='SIGNAGE' AND SATSITE=@GOLDSTORE);		
		  
		  (SELECT @X1DESC=X1DESC,@X2DESC=X2DESC,@X3DESC=X3DESC,@GPRODTYPE=PRODTYP FROM #TAB WHERE AATCINR=@ITEM_IN);

		  SELECT @GPRODTYPE=PRODTYP FROM #TAB WHERE AATCINR=@ITEM_IN;

		  SELECT @SCALEABLE=SCALE FROM #TAB WHERE AATCINR=@ITEM_IN;

		  SELECT @UOM=UOM FROM #TAB WHERE AATCINR=@ITEM_IN
		  

		  
		 IF  ((@LBLTYPE IS NULL OR @LBLTYPE = 'N') AND @PRCTYPE = 'REG') -- No signage for labels
               OR (@SIGNSIZE IS NULL AND @prctypE <> 'REG') -- No signage for items
			   OR @reasoncd > '4'                         -- Non-price changes
			   OR ISNULL(@GPRODTYPE,' ') = 'PRCP'              -- Price point items
        BEGIN
          --  assign_form('N',i.eventcd,i.prctyp,l_freqshopper,l.dept,i.upc,l_hierid,i.promoid,l_malama,@lblsize,l_signvalue, l);
          --  p_formnm := @form_no;
            --RETURN;
			GOTO NEXTRECORD;
        END ;

	  
		
						  RAISERROR('Label PRINTING STARTS',10,1) WITH NOWAIT


					/*	 SELECT * INTO #ARTUC FROM ETL_ARTUC WHERE ARACINR=@ITEM_IN AND ARATFOU=1
					   -- AND runid=@RUNID
						AND ARASITE=@GOLDSTORE
                        AND @APPLYDT BETWEEN ARADDEB AND ARADFIN ;	*/
        
				select @ravimulti=prcmulti,@Refffrom=EFFFROM,@REFFTHRU=EFFTHRU,@REGPRICE=PRICE FROM GET_REGULARPRICE(@GOLDSTORE,convert(date,@APPLYDT)) where item_sv=@ITEM_SV
				select @REGPRICE1=PRICE FROM GET_REGULARPRICE(@GOLDSTORE,dateadd(DAY,-1,@APPLYDT)) where item_sv=@ITEM_SV;

				--select @pavimulti=prcmulti,@Pefffrom=EFFFROM,@PEFFTHRU=EFFTHRU  from GET_PRICEHISTORY(@GOLDSTORE,convert(date,getdate())) where upc=@GOLDUPC
--
					with n as(
							select   objcint,objpere 
							from etl_strucrel
							where objcint =@item_in
							and CAST(GETDATE() AS DATE) between objddeb and objdfin
							union all
							select a.objcint,a.objpere
							from etl_strucrel a ,n
							where a.objcint=n.objpere 
							and CAST(GETDATE() AS DATE) between objddeb and objdfin)
							select   @CATGRY=reverse(substring(reverse(sobcext),1,3)) from n,ETL_STRUCOBJ obj
							where sobcint=objpere 
							and sobidniv=4; --catergory

							with n  (objcint,objpere)  as(
							select   objcint,objpere 
							from etl_strucrel
							where objcint=@ITEM_IN
							and CAST(GETDATE() AS DATE) between objddeb and objdfin
							union all
							select a.objcint,a.objpere
							from etl_strucrel a ,n
							where a.objcint=n.objpere 
							and CAST(GETDATE() AS DATE) between objddeb and objdfin)
							select  @group= reverse(substring(reverse(sobcext),1,3)) from n,ETL_STRUCOBJ obj
							where sobcint=objpere 
							and sobidniv=3 ; --groupnumber
						
						PRINT 'lareg ends'

                      -- SET @REG =(SELECT CASE WHEN @PRCTYPE LIKE 'REG%'  then 1 ELSE 0 END)

					
					--SET @LIMITDESC=(SELECT CASE WHEN @evtcode='DISC'  'DISC' END);

					SET @MALAMA=( SELECT CASE WHEN SATATT='MAL' THEN 'Y' ELSE 'N' END FROM ETL_SITATTRI 
							   WHERE SATSITE=@GOLDSTORE AND SATCLA='DIV_NUM' AND CONVERT(DATE,@APPLYDT) BETWEEN SATDDEB AND SATDFIN
							   AND RUNID=0 );

                    SET @DEPT= (SELECT  distinct  [dbo].[get_posdept](@GOLDSTORE,SUBDEPT) FROM #DEPT WHERE AATCINR=8933241)

					PRINT @dept

					set @FREEFORM=(select FREEFORM from #tab where aatcinr=@item_in);

					set @SKU=(select PRODID from #tab where aatcinr=@item_in);

               SET @RPTCODE=   (SELECT CASE WHEN RPTCODE='1' THEN 'A' WHEN RPTCODE='2' THEN 'B' WHEN RPTCODE='3' THEN 'C' WHEN RPTCODE='4' THEN 'O' 
			     WHEN RPTCODE='5' THEN 'T' ELSE '0' END FROM #TAB WHERE AATCINR=@ITEM_IN  ) 

 			SET @LBL=( SELECT DISTINCT TSOBDESC FROM ETL_TRA_STRUCOBJ WHERE TSOBCINT=@ITEM_IN AND RUNID=0 AND LANGUE='US' )

		  PRINT @lbl

			SET @DEPTCD=(SELECT CASE @DEPT WHEN '01' then 'G' WHEN '02' THEN 'P' WHEN '03' THEN 'M' 
				WHEN '04' THEN 'L' WHEN '05' THEN 'D' WHEN '06' THEN 'S'  WHEN '07' THEN 'B' WHEN '08' THEN 'F' 
				WHEN '09'THEN'N'  WHEN '10' THEN 'G' WHEN '11' THEN 'R' WHEN '13' THEN 'P' WHEN '14' THEN 'S' WHEN '15' THEN 'X'  
				ELSE '?' END  FROM #DEPT WHERE AATCINR=@ITEM_IN)				
				 

			  (SELECT @VDRNAME=FOULIBL,@VDRNUM=FOUCNUF FROM ETL_FOUDGENE WHERE FOUCFIN=@VDRIN)

			--  (SELECT @vdrprdid=ARACEAN FROM  #ARTUC WHERE ARACINR=@ITEM_IN);

			PRINT @vdrname
			  				--	SET @VDRNUM=@VENDOR
					
					--  WHERE FOUCFIN=(select aracfin from(SELECT aracfin, ROW_NUMBER() OVER(ORDER BY ARATFOU asc) AS Row FROM #ARTUC 
                                     --    ) t where row=1))

			 	SET @CASEPACK= 
			(SELECT ALLCOEFF FROM ETL_ARTULUL WHERE (allcinlp=@ARACINL OR ALLCINLF =@ARACINL))
			--(SELECT DISTINCT ARACINL FROM  #ARTUC) OR allcinlF=(SELECT DISTINCT ARACINL FROM  #ARTUC)))

			/*SELECT ARACINL, ROW_NUMBER() OVER(ORDER BY ARATFOU DESC) AS R FROM 
				#ARTUC WHERE aracinr=@ITEM_IN AND ARACFIN=@VDRIN AND ARASITE=@GOLDSTORE AND RUNID=0 )T WHERE R=1); */
				                      --)t WHERE ROW=1));

			  PRINT @CASEPACK

			  SET @MULTIUPC= (SELECT DISTINCT 'M'   FROM ETL_ARTCOCA WHERE ARCCINR=@ITEM_IN AND RUNID=0 AND ARCIETI=0);

			  PRINT @MULTIUPC

			--  SET @PROCESSTYPE =(SELECT CASE WHEN @OP_FLAG ='I'  THEN 'N' ELSE 'M' END);

		 
		   --  PRINT @PROCESSTYPE
				
			--	 SET @MALAMA= (SELECT CASE WHEN SOCCHAIN =13  'Y' ELSE 'N' END FROM ETL_SITDGENE WHERE SOCSITE =@GOLDSTORE and runid=0);

				 PRINT @MALAMA
				 
			--	SET @FORMNO=(SELECT CASE WHEN @MALAMA='Y'   'UDLRG' ELSE 'FDLS' END );
			
			
				SELECT @DOWSTART=DOWSTART ,@LEADTIME=LEADTIME,@SCHEDCD=SCHEDCD ,@EVENTCODE=EVENTCODE--,OFFLEADTIME=OFFLEADTIME
				FROM #SCHDTAB WHERE EVENTCODE = ISNULL(@EVTCODE,'ADMK')

	  print @dowstart
	  print 'priya'

     IF @OP_FLAG = 'I' OR @REASONCD = '7'
                 SET @docnum = 30;
     ELSE IF @UPC BETWEEN '20000000000' AND '29999999999' AND @DEPT = 7 -- Bakery        
           SET @DOCNUM = 14;
     ELSE IF @UPC BETWEEN '20000000000' AND '29999999999'        
           SET @DOCNUM = 11;
     ELSE IF @EVTCODE = 'DISC'    
		BEGIN
            SET @DOCNUM   = 13;
          SET @APPLYTYP = '0'
		  END
     ELSE IF @GPRODTYPE = 'MKTG' OR @PRODTYPE= 'CPN'
           SET @DOCNUM = 90;		  
		   --AD%
     ELSE IF @PRCTYPE LIKE 'AD%'	 

         BEGIN
		  print 'riya1'
		
	   	 DECLARE @OREG NUMERIC(15,4);
						--   IF @PEFFFROM < l_ii.applydt AND l_ii.effdate = (l_ii.applydt - 1) AND l_leadtime <> 1
		   IF @PEFFFROM<@APPLYDT AND @TODAY=DATEADD(Day,-1,@APPLYDT) --AND @LEADTIME<>1
		     BEGIN
						--	SELECT @OREG=PRICE FROM GET_REGULARPRICE(@GOLDSTORE,convert(date,@EFFFROM-1)) where item_sv=@ITEM_SV ;--previous day reg price
				IF @REGPRICE1 <> @REGPRICE -- / l_ii.regprcmult
                  BEGIN
                    set  @DOCNUM   = 72;
                    set @APPLYTYP = '0';
				  END;
                ELSE
                  set  @DOCNUM = 20;
             END    

			  ELSE IF @EVTCODE = '1DAY'            
               SET @DOCNUM = 21;
			 ELSE IF @EVTCODE = 'ROP'            
			   SET  @DOCNUM = 22;
			  ELSE IF @EVTCODE = 'HOT'            
               SET @DOCNUM = 23;
			 ELSE IF @EVTCODE = 'NEWS'            
               SET   @DOCNUM = 24;
			 ELSE
              SET  @DOCNUM = 25;
      END ;

			---PRO
     ELSE IF @PRCTYPE = 'PRO'
        BEGIN

		   print 'pro'
          -- IF l_ii.proefffrom < l_ii.applydt AND l_ii.effdate = (l_ii.applydt - 1)
		    IF @PEFFFROM<@APPLYDT AND @TODAY=dateadd(Day,-1,@APPLYDT) 
	 	     BEGIN
             	--SELECT @OREG=PRICE FROM GET_REGULARPRICE(@GOLDSTORE,@applydt-1) where item_sv=@ITEM_SV ;--previous day reg price
               IF @REGPRICE1 <> @REGPRICE -- / l_ii.regprcmult
                begin
                   set  @DOCNUM   = 72;
                   set @applytyp = '0';
				END;
                ELSE
                  SET  @DOCNUM = 12;                
             END
            ELSE
               SET  @DOCNUM = 12;
		 END
    ELSE IF @APPLYTYP = 'O' -- Off promotions 
        SET  @DOCNUM = 27;
    ELSE IF @PRCTYPE <> 'REG' -- Handle exceptions???        
          SET   @DOCNUM = 29;
    ELSE IF @DEPT = 2   
	  BEGIN     
          SET  @DOCNUM   = 42; -- Produce
          SET @applytyp = '0';
	 END;

      -- ELSIF l_dowstart = 0 OR l_ii.dept > 59 OR (l_ii.applydt <> l_ii.proefffrom) OR (l_ii.applydt - l_ii.effdate) <> l_leadtime
    ELSE IF @DOWSTART = 0 OR @DEPT > 59 OR (@APPLYDT<> @pefffrom) OR (datediff(D,@APPLYDT, @TODAY)) <> @leadtime 
	     	begin
               IF @REASONCD IN (3, 4)  
			   BEGIN
				SET @DOCNUM   = 16;
                SET @applytyp = '0';
				END;
              ELSE
               SET @DOCNUM = 20;     
		   end;
     ELSE IF @applytyp = 'V' -- Advance
           BEGIN
              SET @DOCNUM   = 40 + @DEPT;
              SET @applytyp = '0';
			END;
     ELSE 
		  BEGIN
           SET  @DOCNUM   = 40;
           SET @applytyp = '0';
          END;
	


	---******************------
	print @docnum
        IF @DOCNUM BETWEEN 10 AND 29        
           SET @applytyp = CONVERT(CHAR,(@DOCNUM + 87)); -- 'a'(97) - 'p'(112)
        ELSE IF @DOCNUM = 30
        
            SET @applytyp = '+'; -- '+'
        ELSE IF @DOCNUM = 90
             SET @applytyp = '!'; -- '!'
        ELSE IF @DOCNUM IN (40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 51, 53)
        
            SET @applytyp = CONVERT(CHAR,(@DOCNUM + 8)); -- '0' (48) - ';' (59)
        ELSE IF @DOCNUM IN (72, 76, 78, 79)
          SET @applytyp = CONVERT(CHAR,(@DOCNUM - 10)); -- '>' (62) - 'E' (69)
        ELSE
           SET @applytyp = '?'; -- '?'
       
		
	
		 IF @DEPT = 5 and @MALAMA = 'Y'        
           SET @COLOR = (SELECT SUBSTRING(X2DESC, 1, 30) FROM #TAB WHERE AATCINR=@ITEM_IN);
		   ELSE       
          SET @COLOR = ' ';

		 IF @VENDOR = 900001 and @X3DESC is not null 
		 BEGIN
          set  @VENDOR = substrING(@X3DESC, 1, CHARINDEX(@X3DESC, '=') - 1);
          set  @VENDOR = substrING(@X3DESC, CHARINDEX(@X3DESC, '=') + 1, 30);
         END 


          IF @VENDOR <> 50379          -- C+S        
           SET @upcbar = @upc;

		   DECLARE @BATCH INT,
		   @PCFLAG CHAR(1);
     -- Set batch number:

      /*  IF @CAT IS NULL
        BEGIN
            l.batch := i.t8;       -- Intactics
            l.aisle := i.posdesc;       -- Request sequence
            l.cpm   := substr(i.x3desc, 1, 12);*/

        IF @DOCNUM in (20, 27)    -- Off promotion        
           SET  @batch = 12;
        ELSE IF @DOCNUM between 21 and 29        
           SET  @batch = 22;              -- AD On
        ELSE IF @Docnum between 40 and 54        
            SET  @batch = 40;              -- Price Changes
        ELSE
            SET @batch = @docnum;               -- Requests for maintenance/tag
         
		 print 'PRIYA'
        -- SET Process TypE
        IF @DOCNUM = 30        
           SET  @processtype = 'N';      -- New Item
        ELSE IF @REASONCD IN ('1', '2','5')      -- TAG or POS Request
           OR @CATGRY IS NULL
        
           SET  @processtype ='R';      -- FUTURE - If request.tagid  Intactics?
        ELSE IF @PRCTYPE LIKE 'AD%'        
           SET  @processtype = 'A';
        ELSE
            SET  @processtype = 'M';
       

	   print 'check'
	   
        -- Regular Prices
      -- Regular Prices
     IF @PRCTYPE= 'REG'
      BEGIN

	  print 'REGULAR PRICE'
            If @processtype = 'N'            
             SET @pcflag = 'Y';
            ELSE
              SET @pcflag =  'N';
         DECLARE @REGLBL CHAR(1);

            SET @REGLBL = 'Y';

            IF @APPLYTYP = 'O'    -- Off Promo
            BEGIN

			print @APPLYTYP
           --     OPEN  pricel_cur (@APPLYDT, @prodid,@stornum); FETCH pricel_cur INTO @efffrom, @prctyp, @regprice; CLOSE pricel_cur;
              --  OPEN  pricel_cur(@APPLYDT-1,@prodid,@stornum); FETCH pricel_cur INTO @Pefffrom, @prctyp, @price; CLOSE pricel_cur;
			  	  print 'REGg'
                IF @regprice = @REGPRICE1 AND @CATGRY IS NOT NULL
                AND @processtype <> 'R' and @lblsize not in ('D', 'P') --and isnull(l_prtvalue, 'N') <> 'Y'  --check later this comment
				BEGIN   
				PRINT 'FIRT FIRST RETURN';
                 --  assign_form('N',i.eventcd,i.prctyp,l_freqshopper,l.dept,i.upc,l_hierid,i.promoid,l_malama,@lblsize,l_signvalue, l);
                 -- p_formnm := @form_no;
                 --  RETURN;             -- Regular price has not changed during the promotion
				 GOTO NEXTRECORD;
                END ;


				PRINT 'FIRST RETURN';

                IF @CATGRY IS NULL                
                  SET @batch = 1 --i.t8;       -- Intactics check later i.t8
                ELSE
                  SET @batch = 12;
              END

			   ---WORK LATER
              ELSE IF @REASONCD = 3        -- Potentially temp logic to eliminate unnecessary labels from target margin reset
                 BEGIN                   -- due to price change rows where the price is not changing

              /*  OPEN  price_cur (@APPLYDT-1,i.prodid,i.stornum);
                FETCH price_cur INTO l_regefffrom, l_prctyp, l_price;
                CLOSE price_cur;*/

				DECLARE @LPRCTYP VARCHAR(5);
				DECLARE @LPRICE NUMERIC(15,2); 

				PRINT @APPLYDT

			--	SELECT * FROM DBO.GET_PRICEHISTORY(@GOLDSTORE,dateadd(Day,-1,@APPLYDT)) WHERE UPC=@UPC

				(SELECT @LPRCTYP=PRCTYPE ,@LPRICE=PRICE FROM DBO.GET_PRICEHISTORY(@GOLDSTORE,dateadd(Day,-1,@APPLYDT)) WHERE UPC=@UPC)

                  IF @LPRCTYP = 'REG'
				   AND @LPRICE = @PRICE --  / i.prcmult  LATER CGANHE
                
                  --  assign_form('N',i.eventcd,i.prctyp,l_freqshopper,l.dept,i.upc,l_hierid,i.promoid,l_malama,@lblsize,l_signvalue, l);
                  --  p_formnm := @form_no;
                    --RETURN;             -- Price is not changing
					GOTO NEXTRECORD;
                END;
            

			 PRINT 'SECOND RETURN';

			DECLARE @form_no varchar(50);
          -- l.regprcmult = i.prcmult;
         --   l.regprice   = @price;
            SET @reglbl     = '1';   --CHECK LATER

         IF @MALAMA = 'Y'
            BEGIN
               IF @lblsize = 'D'               
                  IF @signsize = 'L'                  
                     set @form_no = 'UDLRG';
                  ELSE
                   set  @form_no = 'UDARG';
                  
               ELSE IF @lblsize = 'P'               
                set  @form_no = 'UPARG';

			   ELSE IF isnull(@signsize, 'A') in ('A', 'E') OR @signsize = ' '               
                 set  @form_no = 'ULBL32A';
               ELSE
                  set @form_no = CONCAT('ULBL20' , @signsize)
            END 
         ELSE IF @lblsize = 'S'            
             set   @form_no   = 'FDLS';
         ELSe IF @lblsize = 'P'            
              set  @form_no   = 'PARG';
         ELSE
              set  @form_no   = 'FDLS';
           
             IF @SIGNVALUE = 'F'
            
               IF @lblsize = 'D'
               
                  IF @signsize = 'A'
                  
                   set   @form_no = 'FDCRG';
                  ELSE
                    set  @form_no = CONCAT('F', @lblsize , @signsize ,'RG');
                  
                ELSE IF @lblsize = 'P'
                
                 SET  @form_no = 'FPARG';
                ELSE
                 SET  @form_no = 'FDLS';


PRINT  'CROSS'             
         --   p_formnm := @form_no;

       --     l.tags_page := isnull(i.qty,1); CHECK LATER

            IF @DCODE IS NOT NULL and @DDATE <= @TOMORROW
            BEGIN
              SET  @LIMITDESC = 'DISC';     -- Item is being discontinued
            END 
           SET @prctypE = 'REG';

            IF @REGLBL = 'Y' 
			 PRINT 'INSERT'
              GOTO insert_label;
            --   l_cnt := l_cnt + 1;

          /*  OPEN  brand_cur (i.prodid, i.stornum, i.applydt);
            FETCH brand_cur INTO l_freeformsz, l_lbldesc, l_price;
            IF brand_cur%FOUND AND ROUND((l_price * .93), 2) >= i.price / i.prcmult
            AND i.prctyp = 'REG'
            THEN
                l.savings   := l_price - (i.price / i.prcmult);
                l.brandsz   := l_freeformsz;
                l.branddesc := l_lbldesc;
                @form_no   := 'BEST';
                l.tags_page := isnull(i.qty,1);
                l.reglbl     := '0';
                insert_label(l);
            END IF;
            CLOSE brand_cur;*/

            GOTO NEXTRECORD;
        END

------------------------------------------PROMOTIONS
     
      DECLARE @limit int,
			@limitqty int;
		

	  DECLARE @SAVINGS NUMERIC(15,2);

	  SET  @savings      = ((@REGPRICE / @Ravimulti - (@PRICE / @PAVIMULTI)) * @PAVIMULTI) --LATER

      SET @PCFLAG = 'N';

	  set  @limitqty= 0;
	   
       declare @l_V varchar(20),
	   @advmsg VARCHAR(50),
	   @upricemsg VARCHAR(50);



        SET @l_V = '  ';
        IF (datediff(D,@peffthru , @applydt) > 9 
		or (datepart(W,@Peffthru) <> 3 and datediff(D,@Peffthru, @applydt) < 5)
        AND @prctypE LIKE 'AD%' AND @EVENTCODE <> 'DISC')
        
           SET  @l_V =  '_V';
         

        IF @form_no LIKE '%COUT'  OR (@DCODE IS NOT NULL and @DDATE <= @TOMORROW)        
           SET @limitdesc = 'DISC';     -- Item is being discontinued
      
        IF @malama = 'N'

		BEGIN        
            IF @prctypE LIKE 'AD%' AND @EVENTCODE NOT LIKE 'UA%'            
               SET  @advmsg = '- Advertised';            

            IF @PAVImultI > 1 AND @PROMOTYPE ='Y' -- 'A' WILL CHK LATER            
                SET @upricemsg = 'Card Price';



		    IF @limitqty <> 0            
               set @limit = @limitqty 
            ELSE IF @SCALEABLE = 'N' and (@uom <> 'LB' OR @dept in (1, 4, 5, 9, 11, 13)) 
			BEGIN
              SET @limit     = 5;
                if @limitdesc <> 'DISC' 
                   SET @LIMITDESC = 'units';                
            END
        END
		
        SET @reglbl     = '1';
        IF @l_V = '_V'
           SET @form_no = CONCAT(@form_no, @l_V)
        
        if @signvalue = 'F' or (@GOLDSTORE = 30 and @applydt > '29-may-18')
        BEGIN
          SET  @form_no =CONCAT('F' , @form_no);
        END 
		
       -- p_formnm := l.form_no;
        --l.tags_page := NVL(i.qty,1);
			GOTO insert_label ;

         

		 insert_label:
PRINT 'INERT 1'
		 
        INSERT INTO fdl_label
            (RUNID,
			 effdate
            ,stornum
            ,applydt
            ,upc
            ,effthru
            ,docnum
            ,process_type
            ,form_no
            ,tags_page
            ,vendnum
            ,vendprodnum
            ,lbldesc
            ,casepack
            ,freeformsz
            ,dept
            ,deptcd
            ,prcmult
            ,price
            ,cpm
            ,regprcmult
            ,regprice
            ,mult_upc
            ,aisle
            ,savings
            ,savemsg
            ,groupnum
            ,categorynum
            ,batch
            ,branddesc
            ,brandsz
            ,unitprice
            ,shortdesc
            ,ea
            ,limit
            ,limitdesc
            ,eap
            ,mixmdesc
            ,upcbar
            ,advmsg
            ,upricemsg
            ,eventcd
            ,SPECDESC1
            ,SPECDESC2
            ,SPECDESC3
            ,SPECDESC4
            ,MUSTBUY
            ,reglbl
            ,loen
            ,sku
            ,qtyprice
            ,pcflag
            ,prctyp
            ,rptcode
            ,colordesc
            ,vendnm
            ,proefffrom
            ,glutenfreeflg
            ,savings1
            ,unitprice1
            ,mustbuy1)
        values( 
              @runid
			,@effdt
            ,@GOLDSTORE
            ,@applydt
            ,@upc
            ,@PEFFTHRU
            ,@docnum
            ,@PROCESSTYPE
            ,case when @form_no in ('FDLRG', 'FDERG', 'FDORG', 'FDNRG') then 'FDCRG' else @form_no  end           
            ,1 --  @tags_page
            ,@VDRNUM
            ,@vdrprdid
            ,@LBL
            ,@casepack
            ,@FREEFORM    
            ,@dept
            ,@deptcd
            ,@PAVIMULTI
            ,@price
            ,@cpm
            ,@RAVIMULTI  --need sel
            ,@regprice
            ,@MULTIUPC
            ,null   --@aisle
            ,@SAVINGS --@savings
            ,null --@savemsg
            ,@group
            ,@CATGRY
            ,@batch
            ,NULL --@branddesc
            ,NULL  --@brandsz
            ,NULL --@unitprice
            ,NULL --UPPER(@shortdesc)
            ,@ea
            ,@LIMIT
            ,@limitdesc
            ,@eap
            ,NULL -- @mixmdesc
            ,@upcbar
            ,@advmsg
            ,@upricemsg
            ,@EVENTCODE
            ,NULL --@specdesc1
            ,NULL --@SPECDESC2
            ,NULL --@SPECDESC3
            ,NULL --@SPECDESC4
            ,NULL --@MUSTBUY
            ,@reglbl
            ,@SIGNsize --@loen
            ,@sku
            ,NULL --@qtyprice
            ,@pcflag
            ,@PRCTYPE
            ,@rptcode
            ,@COLOR
            ,@VDRNAME
            ,@pefffrom
            ,NULL --@glutenfreeflg
            ,NULL --@savings1
            ,NULL --@unitprice1
            ,NULL --@mustbuy1
			);
		 /*

INSERT INTO FDL_LABEL 
				(RUNID ,EFFDATE,STORNUM,APPLYDT,UPC,DEPT,CATEGORYNUM,GROUPNUM,UPCBAR,EA,FREEFORMSZ,RPTCODE,LBLDESC,REGLBL,LIMITDESC,DEPTCD,CPM,COLORDESC,ORDERMVMT,SKU,VENDNUM,VENDNM,vendprodnum,CASEPACK,MULT_UPC,EAP,PRICE,LOEN,TAGS_PAGE,DOCNUM,PROCESS_TYPE,FORM_NO,EVENTCD,
				PRCTYP,REGPRCMULT,REGPRICE,EFFTHRU,PRCMULT,SAVINGS,UNITPRICE) 
					VALUES (799,GETDATE(),@GOLDSTORE,@APPLYDT
					,@UPC,@DEPT,@CATGRY,@SCATGRY,@UPCBAR,@EA,@FREEFORM,@RPTCODE,@LBL,@REG,@LIMITDESC,@DEPTCD,@CPM,@COLOR,NULL,@SKU,@VDRNUM,@VDRNAME,@vdrprdid,@CASEPACK,@MULTIUPC,@EAP,@PRICE,@LOEN,1,@DOCNUM,@PROCESSTYPE,@FORMNO,
					(select OPLCEXOPR from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					(select PATATT from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					(select RAVIMULTI from #REGPRICE where Ritem_sv=@ITEM_SV AND Rstore=@STORE),
					(select Reg_price from #REGPRICE where Ritem_sv=@ITEM_SV AND Rstore=@STORE),
					(select AVIDFIN from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					(select AVIMULTI from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					((select Reg_price from #REGPRICE where Ritem_sv=@ITEM_SV AND Rstore=@STORE)-@PRICE),					
					 @PRICE/ISNULL((select AVIMULTI from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),1))*/
					;
/*(RUNID,				
EFFDATE  ,
STORNUM ,   
APPLYDT   ,
UPC 	,  
EFFTHRU  ,
DOCNUM ,  
PROCESS_TYPE  ,
FORM_NO	  ,
TAGS_PAGE ,  
VENDNUM 	,  
VENDPRODNUM 	,
LBLDESC 	 ,
CASEPACK 	,
FREEFORMSZ  ,
DEPT , 
DEPTCD 	 ,
PRCMULT 	, 
PRICE	, 
CPM 	 ,
REGPRCMULT , 
REGPRICE , 
MULT_UPC  ,
AISLE  ,
SAVINGS , 
SAVEMSG  ,
GROUPNUM  ,
CATEGORYNUM ,
BATCH ,
BRANDDESC ,
BRANDSZ  ,
UNITPRICE ,  
SHORTDESC  ,
EA  ,
LIMIT ,  
LIMITDESC  ,
EAP  ,
MIXMDESC  ,
UPCBAR ,  
ADVMSG  ,
UPRICEMSG  ,
EVENTCD  ,
ORDERMVMT ,  
SPECDESC1  ,
SPECDESC2  ,
SPECDESC3  ,
MUSTBUY  ,
SPECDESC4  ,
REGLBL  ,
LOEN  ,
SKU  ,
QTYPRICE ,  
PCFLAG  ,
PRCTYP  ,
RPTCODE  ,
VENDNM  ,
COLORDESC  ,
PROEFFFROM  ,
GLUTENFREEFLG  ,
CALORIE  ,
SAVINGS ,  
UNITPRICE ,  
MUSTBUY  )

SELECT */


			


				/*SELECT 10,GETDATE(),@STORENUM,GETDATE(),@UPC,@DEPT,@CATGRY,@SCATGRY,@UPCBAR,@EA,@FREEFORM,@RPTCODE,@LBL,@REG,@LIMITDESC,@DEPTCD,@CPM,@COLOR,NULL,@SKU,@VDRNUM,@VDRNAME,@vdrprdid,@CASEPACK,@MULTIUPC,@EAP,@PRICE,@LOEN,1,@DOCNUM,@PROCESSTYPE,@FORMNO 
				FROM stg_pos_items_010825 WHERE RUNID=799 AND STORE=*/
				--DROP TABLE #ARTUC;

								
				print 'new entry'

			
		
		     -- SET @MALAMA= (SELECT CASE WHEN SOCCHAIN =13  'Y' ELSE 'N' END FROM ETL_SITDGENE WHERE SOCSITE =@STORE);

		      --   print @MALAMA



			--	 update fdl_label set FORM_NO=@FORM where runid=799;
			NEXTRECORD:

				FETCH NEXT FROM LAB_CURSOR INTO @APPLYDT,@OP_FLAG,@APPLYTYP,@REASONCD,@GOLDSTORE,@ITEM_IN,@ITEM_SV,@PRICE,
		                                @PEFFFROM,@PEFFTHRU,@PAVIMULTI,@PRCTYPE,@EVTCODE,@UPC,@ARVCLIBL,@DCODE,@DDATE,@VDRIN,@VDRPRDID,@ARACINL
	
	
					 
					 
					 --END;

                    CLOSE LAB_CURSOR;

					DEALLOCATE LAB_CURSOR;


				RAISERROR('Label Processing Ends..',10,1) WITH NOWAIT	
				

				--	RAISERROR('Delete/Insert Lookup table',10,1) WITH NOWAIT


					--SELECT LEN(UPC) FROM stg_pos_items_010825  WHERE RUNID=486 AND   pos_new_item
					                --MOVE THIS QRY TO SSIS
				 /*INSERT INTO STG_POS_ITEM_LOOKUP SELECT ITEM_IN,ITEM_EX,SKU,GOLD_UPC,STORE,GETDATE(),VENDOR,UPC FROM stg_pos_items_010825 A WHERE OP_FLAG='I' 
				 and runid=799 AND UPC IS NOT NULL
				 AND EXISTS (SELECT 1 FROM pos_new_item B WHERE A.UPC=B.UPC AND B.status='processed'  )*/

				 --THIS ONE WILL BE MOVE TO SSIS
			----	 DELETE A FROM STG_POS_ITEM_LOOKUP A WHERE EXISTS (SELECT 1 FROM stg_pos_items_010825 B WHERE A.ITEM_IN=B.ITEM_IN AND A.SKU=B.SKU AND A.SITE#=B.STORE 
			--	 AND A.VENDOR=B.VENDOR  AND  OP_FLAG='D' and RUNID=799 AND UPC is not null );  


				--INSERT INTO pos_item_job_sweeper(request_id,action_type,store_number) AS SELECT request_id,'NEW',


--COMMIT TRANSACTION;
 RAISERROR('END TRY',10,1) WITH NOWAIT;
--end try


/*

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


ROLLBACK TRANSACTION;
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
end catch*/
END ;

GO

