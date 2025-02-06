USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[GoldPOS_Upload_FullLoad]    Script Date: 2/5/2025 11:12:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GoldPOS_Upload_FullLoad]
@RUNID INT,
@PROCESSID INT


AS

DECLARE 
@CNT NVARCHAR(100),
 @I INT=0 ,
 @CN NVARCHAR(100),
 @ATTCN NVARCHAR(100),
 @l_docnum NVARCHAR(50),
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
 @ARVCLIBL INT;
 
 
BEGIN

	--BEGIN TRANSACTION 

	--BEGIN TRY
	

	RAISERROR('Initial Load Starts....',10,1) WITH NOWAIT

truncate table stg_pos_items;
truncate table pos_coupon_item;
truncate table pos_deposit_item;
truncate table pos_new_item;
truncate table LINKED_ITM_DTL;
truncate table LINKED_ITM_HDR;

	RAISERROR('Get the Active Stores....',10,1) WITH NOWAIT


--	select * from LINKED_ITM_HDR

--DROP TABLE #TESTSTORE

--need to add rank
	SELECT distinct store_id as active_posstore INTO #POSSTORE FROM pos_store_session 
--	WHERE CAST(getdate() as date)=CAST(created_at as date) 
	where session_type='REGULAR';
	
	SELECT GoldStore,active_posstore INTO #teststore
	FROM GoldPos_Store_map,#POSSTORE 
	WHERE PosStore=active_posstore;

	--select 1 GoldStore,'0093' active_posstore  into #teststore

	RAISERROR('Get COUPON_EQUALS_PRICE param....',10,1) WITH NOWAIT
	DECLARE @usemulti char(1)='N';
  IF (SELECT PARAM_VALUE FROM ETL_PARAM WHERE PARAM_NAME='COUPON_EQUALS_PRICE' ) ='TRUE' 
  BEGIN
   set @usemulti ='N';
  END
  ELSE
  BEGIN
   set @usemulti ='Y';
  END;
	
	DROP TABLE IF EXISTS TEMP_POSITEMS;
	
	RAISERROR('Create TEMP_POSITEMS....',10,1) WITH NOWAIT

 SELECT * INTO TEMP_POSITEMS
 FROM (

 SELECT * FROM 
(
    SELECT 
	    'P' as source,
		ARVCINR AS ITEM,
		'I' AS ITEM_FLAG,
     --   CASE WHEN @usemulti='Y' THEN (aviprix/avimulti)  ELSE AVIPRIX END as AVIPRIX,
	   ISNULL ((CASE WHEN @usemulti='Y'  AND  PATATT NOT LIKE 'REG%' THEN (i.aviprix/isnull(i.avimulti,1))  ELSE i.AVIPRIX END),0)  as AVIPRIX,		
        O.avorescint ,
		RESSITE,
	    ARACFIN,
		ARACEAN,
		ARACINL,
        I.avicinv ,
		ARVCLIBL,
		AVIDDEB ,
		AVIDFIN,
		OPLCEXOPR,
		PATATT,
		CASE WHEN @usemulti='Y' THEN 1 else AVIMULTI end AVIMULTI,
		--AVINTAR,
		--AVOPRIO,
		(select case when len(arccode)=12 then (select right('0000000000000'+ substring('000'+ARCCODE,1,14),14)) 
					when len(arccode)=13 then (select right('0000000000000'+ substring('00'+ARCCODE,1,14),14))
					when len(arccode)=14 then (select right('0000000000000'+ substring('0'+ARCCODE,1,14),14))
					--when len(arccode)<>12 or len(arccode)<>13 then  (select right('0000000000000'+ substring(ARCCODE,1,14),14)) 
					when len(arccode)<12 then  (select right('0000000000000'+ substring(ARCCODE,1,14),14)) 
					else '0' end  ) AS UPC,
        ARCCODE AS GOLDUPC,				
		(select patatt from etl_oprattri z where z.patcla='FRQ_SHOP' and z.PATNOPR=avenopr) promotype,       
		ROW_NUMBER() OVER(PARTITION BY RESSITE, I.avicinv ORDER BY avoprio,I.AVINTAR) AS rnk  
    FROM 
        etl_avetar e 
        JOIN etl_avescope o ON aventar = avontar 
        JOIN etl_aveprix i ON aventar = avintar 
        JOIN etl_OPRATTRI A ON PATNOPR = AVENOPR AND PATCLA = 'PRICE_TP'                 
        JOIN etl_OPRPLAN  L ON OPLNOPR = PATNOPR  
		JOIN ETL_ARTUV U ON ARVCINV=AVICINV AND ARVETAT=1
		JOIN ETL_ARTCOCA C ON ARCCINV=ARVCINV AND ARCIETI=1	
		JOIN ETL_RESEAU R ON RESPERE=AVORESCINT AND RESRESID='SF'	
		JOIN ETL_ARTUC Q ON ARASITE=O.AVORESCINT AND ARACINR=ARVCINR AND ARATFOU=1 AND RESRESID=ARARESID 
		                --    AND ISNULL(convert(date,ARALIBACH),(CAST(GETDATE()+1 AS DATE))) > CAST(GETDATE() AS DATE) --later check
					
		--JOIN ETL_ARTATTRI Z ON AATCINR=ARVCINR  
		AND EXISTS (SELECT 1 FROM ETL_ARTATTRI SUB 
			WHERE CAST(GETDATE() AS DATE) BETWEEN SUB.AATDDEB AND SUB.AATDFIN 
		    AND SUB.AATCINR=ARVCINR AND SUB.AATCCLA='POSITEM' AND SUB.AATCATT='Y')	
        AND NOT EXISTS (SELECT 1 FROM ETL_ARTATTRI SUB 
			WHERE CAST(GETDATE() AS DATE) BETWEEN SUB.AATDDEB AND SUB.AATDFIN 
		    AND SUB.AATCINR=ARVCINR AND SUB.AATCCLA='PRODTYP' AND SUB.AATCATT='DISC')	
      WHERE 
          CONVERT(DATE,GETDATE()) BETWEEN aveddeb AND avedfin
        AND ((CONVERT(DATE,GETDATE()) BETWEEN avoddeb AND avodfin))-- OR (CONVERT(DATE,GETDATE()) = AVODFIN))
        AND CONVERT(DATE,GETDATE()) BETWEEN aviddeb AND avidfin  
		AND CONVERT(DATE,GETDATE())  BETWEEN PATDDEB AND PATDFIN	
		AND CONVERT(DATE,GETDATE())  BETWEEN ARCDDEB AND ARCDFIN	
		AND ((CONVERT(DATE,GETDATE()) BETWEEN RESDDEB AND RESDFIN))-- OR (CONVERT(DATE,GETDATE()) = RESDFIN)) --STORE END	
		AND RESSITE in (SELECT GoldStore FROM #teststore) 	
		
		AND E.RUNID=0	AND O.RUNID=0	AND I.RUNID=0  AND A.RUNID=0 AND L.RUNID=0 AND R.RUNID=0 AND Q.RUNID=0    
		) AS T  WHERE RNK=1  )U



--REGULAR PRICE

RAISERROR('Get Regular price to temp table....',10,1) WITH NOWAIT

 SELECT RESSITE,ITEM_SV,UPC,EFFFROM,EFFTHRU,PRCTYPE,PRCMULTI,PRICE,EVENTCD
 INTO #REGPRICE
 FROM 
(
    SELECT distinct	 
       -- (aviprix/avimulti) AS price, --need to confir mwith ALex
	    aviprix PRICE,
        AVORESCINT AS storenum,
		RESSITE,
		ARCCODE AS UPC,
        avicinv AS item_sv,
		aviddeb as EFFFROM,
		avidfin as EFFTHRU,
		avimulti as prcmulti,
		OPLCEXOPR AS EVENTCD,			   
		PATATT PRCTYPE,
		ROW_NUMBER() OVER(PARTITION BY ressite, avicinv ORDER BY avintar) AS rnk  
    FROM 
        etl_avetar e 
        JOIN etl_avescope o ON aventar = avontar 
        JOIN etl_aveprix i ON aventar = avintar 
        JOIN etl_OPRATTRI A ON PATNOPR = AVENOPR 
            AND PATCLA = 'PRICE_TP' 
            AND PATATT = 'REG'           
        JOIN etl_OPRPLAN  L ON OPLNOPR = PATNOPR  
		JOIN ETL_RESEAU U ON avorescint = respere and resresid = 'SF'    
		JOIN ETL_ARTCOCA C ON ARCCINV=AVICINV AND ARCIETI=1  
		JOIN ETL_ARTRAC X ON ARTCINR=ARCCINR	
	   WHERE 
             CONVERT(DATE,getdate())  BETWEEN aveddeb AND avedfin
		AND  CONVERT(DATE,getdate()) BETWEEN ARCDDEB AND ARCDFIN
        AND  CONVERT(DATE,getdate())  BETWEEN avoddeb AND avodfin
        AND  CONVERT(DATE,getdate())  BETWEEN aviddeb AND avidfin 
		AND  CONVERT(DATE,getdate())  BETWEEN PATDDEB AND PATDFIN	
		AND  CONVERT(DATE,getdate())  BETWEEN resddeb and resdfin
		AND RESSITE in (SELECT GoldStore FROM #teststore) 	
		AND E.RUNID=0	AND O.RUNID=0	AND I.RUNID=0  AND A.RUNID=0 AND L.RUNID=0 AND U.RUNID=0 AND C.RUNID=0   AND X.RUNID=0 
		) AS T  WHERE RNK=1  
	

--select * from TEMP_POSITEMS
	
	-- SET STATISTICS IO ON
		    /*  SELECT AATCINR,AATCCLA,AATCATT,AATVALN ,AATVALNUM,AATDDEB,AATDFIN INTO #TAB
				FROM ETL_ARTATTRI A INNER hash JOIN TEMP_POSITEMS B
				  ON A.AATCINR=B.ITEM 
				 AND CAST(GETDATE() AS DATE) BETWEEN A.AATDDEB AND A.AATDFIN 
				 AND (AATCCLA IN ('FOODSTMP','NOSA','PRODTYP','RX','SCALE','PRICERQD','QHP',
						         'QTYONE','QTYRQD','RESTR','AGE','TAX','POSITEM','RPTCODE','LINK_CD')
								  OR (AATCCLA LIKE 'DEPT%')
								  OR (AATCCLA LIKE 'SUB_%'));
								  */
RAISERROR('Get item Attributes to temp table....',10,1) WITH NOWAIT

SELECT * INTO #TAB
FROM   

   (SELECT AATCINR,AATCCLA,AATCATT
    FROM ETL_ARTATTRI A INNER  JOIN TEMP_POSITEMS B  ON A.AATCINR=B.ITEM  
	 AND CAST(GETDATE() AS DATE) BETWEEN A.AATDDEB AND A.AATDFIN 
				 AND (AATCCLA IN ('FOODSTMP','NOSA','PRODTYP','RX','SCALE','PRICERQD','QHP',
						         'QTYONE','QTYRQD','RESTR','AGE','TAX','POSITEM','RPTCODE','LINK_CD'))
								 AND a.RUNID=0    
		--	OR ((AATCCLA LIKE 'DEPT%')  OR (AATCCLA LIKE 'SUB_%')))  
    UNION ALL
	SELECT AATCINR,AATCCLA, AATVALN AS AATCATT
    FROM ETL_ARTATTRI A INNER  JOIN TEMP_POSITEMS B  ON A.AATCINR=B.ITEM  
	 AND CAST(GETDATE() AS DATE) BETWEEN A.AATDDEB AND A.AATDFIN  AND A.RUNID=0
				 AND AATCCLA='PRODID') T	

PIVOT(
    max(aatcatt) 
    FOR AATCCLA IN 
        ([FOODSTMP],[NOSA],[PRODTYP],[RX],[SCALE],[PRICERQD],[QHP],
						         [QTYONE],[QTYRQD],[RESTR],[AGE],[TAX],[POSITEM],[RPTCODE],[LINK_CD],[PRODID])
        ) AS pivot_table;

 --SELECT DEPT,SUBDEPT FROM ETL_POSDEPT GROUP BY SUBDEPT,DEPT HAVING COUNT(*)>1
 select AATCINR,AATCCLA,SUBDEPT,AATCATT,(SELECT DISTINCT POSDEPT FROM ETL_POSDEPT A WHERE DEPT=RIGHT(AATCCLA,2) AND A.SUBDEPT=T.SUBDEPT) POSDEPT INTO  #DEPT
 FROM
   (SELECT AATCINR,AATCCLA, substring(AATCATT,CHARINDEX('_',AATCATT)+1,len(AATCATT)) as SUBDEPT ,AATCATT 
    FROM ETL_ARTATTRI A INNER  JOIN TEMP_POSITEMS B  ON A.AATCINR=B.ITEM  
	 AND CAST(GETDATE() AS DATE) BETWEEN A.AATDDEB AND A.AATDFIN 
	AND (AATCCLA LIKE 'DEPT%')  AND A.RUNID=0) T;


       RAISERROR('Get Category....',10,1) WITH NOWAIT   ;         						

						 ---CATEGORY
	    with n as(
							select   objcint,objpere ,item
							from etl_strucrel,TEMP_POSITEMS
							where objcint = ITEM and runid=0
							and CAST(GETDATE() AS DATE) between objddeb and objdfin
							union all
							select a.objcint,a.objpere,item
							from etl_strucrel a ,n
							where a.objcint=n.objpere 
							and CAST(GETDATE() AS DATE) between objddeb and objdfin and runid=0 ) 

							select  reverse(substring(reverse(sobcext),1,3)) Catno,item  into #Category from n,ETL_STRUCOBJ obj 
							where sobcint=objpere 
							and sobidniv=4
						

					-- select * from LINKED_ITM_HDR
-- ** Create Large Linked item /Coupon 

--TRUNCATE TABLE LINKED_ITM_HDR

/* Later apply this logic and test
l_promocode := l_promoid - l_promoidoffset;
        --foodland offset adjustment
        IF l_promocode > 80000
        THEN
           l_promocode := l_promocode - 20000;
        ELSIF l_promocode > 10000
        THEN
           l_promocode := l_promocode - 10000;
        END IF;   

        IF l_promocode > NVL(ZPP100.num_param('EM_PROMOCODE_MAX_LENGTH'), 32767)--23627
        THEN
            l_promocode := MOD(l_promocode, 10000);
        END IF*/
 

RAISERROR('Generate Coupons....',10,1) WITH NOWAIT

	MERGE LINKED_ITM_HDR as hdr
 	USING(SELECT DISTINCT AVIDDEB,AVIDFIN,PROMOTYPE,OPLCEXOPR,AVIMULTI,AVIPRIX,(SELECT DISTINCT CATNO FROM #CATEGORY  X WHERE X.ITEM=A.ITEM)CATNO
		FROM TEMP_POSITEMS a --JOIN #Category b ON A.ITEM=B.ITEM
	  WHERE PATATT<>'REG' AND promotype IN ('A','Y')) as t
    ON (hdr.FromDate=t.aviddeb and hdr.thruDate=t.avidfin and hdr.evtcode=t.oplcexopr and hdr.coupontype=t.promotype and hdr.itemsperCpn=t.avimulti 
	and hdr.couponvalue=t.aviprix and CategoryId=CATNO)
    WHEN NOT MATCHED THEN
    INSERT ( Type,FromDate,ThruDate,CouponType,evtcode,CategoryID,CouponValue,ItemsPerCpn,CreatedDt,CreatedBy,ModifiedDt,ModifiedBy)
    VALUES ('Simple',t.AVIDDEB,t.AVIDFIN,t.PROMOTYPE,t.OPLCEXOPR,CATNO,aviprix,t.AVIMULTI,getdate(),'Simplain',getdate(),'Simplain'); 


	
			(select a.HdrID,
			  ((SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1)+(NEXT VALUE FOR PROMOID_CARD_SEQ) )CUPC,
		    	 couponvalue,ItemsPerCpn into #cupc from linked_itm_hdr a where NOT EXISTS (select 1 from LINKED_ITM_DTL b where a.Hdrid=b.Hdrid))

	 INSERT INTO LINKED_ITM_DTL  (HdrID,LnkdItmupc,LnkdItmDesc,LnkdItmVal,LnkdItmTyp,PriceMethod,promocode,ItemsPerCpn) 		
	 SELECT Hdrid,CUPC,(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),couponvalue,7,4 ,CUPC-(SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1)-10000,ItemsPerCpn
	 from #cupc 
	 where EXISTS  (SELECT * FROM dbo.LINKED_ITM_SETUP WHERE CUPC-(SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1) BETWEEN gencardfrom AND gencardthru ) 
  			 
			 

    select *  into #ETL_ARTCOCA FROM ETL_ARTCOCA WHERE RUNID=0;

	 ---**Bottle Deposit *****
	 
	 --DROP TABLE #BOTITEMS

	SELECT AATCINR SITEM,LINK_CD
	INTO #BOTITEMS
	FROM #TAB 
    WHERE LINK_CD IS NOT NULL

--	DROP TABLE #BDEPOSIT
	
	/* SELECT DISTINCT ARCCINR AS BOTCINR,ARCCODE AS BOTGOLDUPC,SUBSTRING(ARCCODE,1,LEN(ARCCODE)) AS BOTPOSUPC,A.AATCATT--,SITEM 
	 INTO #BDEPOSIT 
	 FROM #ETL_ARTCOCA C JOIN ETL_ARTATTRI A
	 ON ARCCINR = AATCINR AND AATCCLA='BTL_DPST' AND ARCIETI=1 AND ARCETAT=1	
	 JOIN #BOTITEMS B ON A.AATCATT=LINK_CD
	 WHERE CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN 
	 AND CAST(GETDATE() AS DATE) BETWEEN ARCDDEB AND ARCDFIN --AND A.RUNID=0 AND C.RUNID=0;*/

	 SELECT * INTO #BDEPOSIT FROM (
	 SELECT DISTINCT ITEM AS BOTCINR,GOLDUPC AS BOTGOLDUPC,UPC AS BOTPOSUPC,A.AATCATT--,SITEM 
	 FROM TEMP_POSITEMS C JOIN ETL_ARTATTRI A
	 ON ITEM = AATCINR AND AATCCLA='BTL_DPST' 
	  WHERE CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN 
	  AND EXISTS(SELECT 1 FROM ETL_ARTATTRI I WHERE I.AATCINR=A.AATCINR AND I.RUNID=0 AND AATCCLA='PRODTYP' AND AATCATT like 'DEP%'	)
	 ) T;
	 
	 
	 RAISERROR('Get item description to temp table....',10,1) WITH NOWAIT

 SELECT * INTO #ETL_TRA_STRUCOBJ FROM(
	  select TSOBCINT,TSOBDCAIS,TSOBDESC  FROM ETL_TRA_STRUCOBJ a INNER MERGE JOIN TEMP_POSITEMS B
	  ON A.TSOBCINT=B.ARVCLIBL 	AND A.RUNID=0
	  UNION ALL
	    select TSOBCINT,TSOBDCAIS,TSOBDESC FROM ETL_TRA_STRUCOBJ A INNER MERGE JOIN #BDEPOSIT B
	  ON A.TSOBCINT=B.BOTCINR AND A.RUNID=0) A
--	DROP TABLE #ETL_TRA_STRUCOBJ

RAISERROR('Get records to STG_POS_ITEMS....',10,1) WITH NOWAIT
--SELECT DISTINCT PRODTYP FROM #TAB WHERE  LEN(PRODTYP)>5
		INSERT INTO STG_POS_ITEMS        
	 
	            SELECT  
			@RUNID AS RUNID,
				ITEM ITEM_IN,
				'' AS TAB,
		        'I' AS OP_FLAG,
				(SELECT ARTCEXR FROM ETL_ARTRAC  WHERE ARTCINR= ITEM and runid=0 ) ITEM_EX , --from TEMP_POSITEMS				
                IIF(FOODSTMP='Y',1,0)  ,  
				(SELECT CASE
                WHEN PRODTYP='SCPN'  THEN '7'
				WHEN PRODTYP='CPN'  THEN '7'
	            WHEN PRODTYP='VCPN' THEN '6'
	            WHEN PRODTYP='MCPN' THEN '6'	          
	            WHEN PRODTYP='MREF' THEN '5'
				WHEN PRODTYP='DEP' THEN '1'
				WHEN PRODTYP='REF' THEN '2'
				WHEN PRODTYP='DEPR' THEN '3'
	            ELSE '0' END)PRODTYP,      
				
		    IIF (NOSA='Y',1,0) NOSA,	
				               
			 (select case when tsobdesc like '[=]%' then '1'   else '0'  end  
               from #ETL_TRA_STRUCOBJ where TSOBCINT = ARVCLIBL ) WIC, 
			  -- 1 AS WIC,
			 			  
          	 IIF (RX='Y',1,0) RX, --LATER
            
			 IIF (SCALE='Y',1,0) SCALEABLE,
            
			   IIF (PRICERQD='Y',1,0)PRICERQD,
            
			  IIF (QHP='Y',1,0)QHP,			      
			  
			  IIF (QTYONE='Y',1,0)QTYONE,				   
              
			  IIF (QTYRQD='Y',1,0)QTYRQD,				  
			  
			  IIF (RESTR='Y',1,0)RESTR,
			 
             (SELECT CASE WHEN AGE='21' THEN '1' WHEN AGE='18' THEN '2' ELSE '0' END)AGE,
			       
			-- (select substring(AATCATT,5,3) from #TAB where aatccla like 'DEPT_%' AND AATCINR=ITEM  )VALUECARD, 
			  --WILL CHANGE LATER
			  NULL AS VALUECARD,
            
			 IIF (TAX='Y',1,0)TAX,

	      --  (SELECT right('000'+ substring(AATCCLA,6,3),3) FROM #DEPT WHERE  AATCINR=ITEM)  DEPT_CODE,  --C1
			(SELECT right('000'+ POSDEPT,3) FROM #DEPT WHERE  AATCINR=ITEM)  DEPT_CODE,
			 
             --(SELECT DISTINCT substring(AATVALN,1,17) FROM #TAB WHERE  AATCCLA='X1DESC' )ITEM_NAME , 

			 

			 ( SELECT DISTINCT substring(TSOBDCAIS,1,17) FROM #ETL_TRA_STRUCOBJ WHERE TSOBCINT=ARVCLIBL ) ITEM_NAME,	
			 
			-- null as item_name,
			 UPC, 		
			 
			 RESSITE AS STORE,
				
			 AVIPRIX AS PRICE,

		--	(SELECT CASE WHEN AATCATT='Y' THEN '1' ELSE '0' END FROM #TAB WHERE AATCCLA='POINTS'  AND AATCINR=ITEM )POINTS,
		null as points,

			PRODID AS SKU,

			1  AS REQUEST_ID,
									
			 POSITEM ,

			--(SELECT DISTINCT AATVALN FROM #TAB WHERE AATCCLA LIKE 'FREEFORM%' AND AATCINR=ITEM)
			NULL AS FREEFORM,
					
			(SELECT CASE WHEN RPTCODE='1' THEN 'A' WHEN RPTCODE='2' THEN 'B' WHEN RPTCODE='3' THEN 'C' WHEN RPTCODE='4' THEN 'O' 
			     WHEN RPTCODE='5' THEN 'T' ELSE '0' END ) RPTCODE,

 		--	( SELECT DISTINCT TSOBDESC FROM ETL_TRA_STRUCOBJ WHERE TSOBCINT=ARVCLIBL AND RUNID=0 AND LANGUE='US' ) AS LBLDESC,	--	PRINT @LBL 
		    null as lbldesc,

			(SELECT CASE RIGHT(POSDEPT,2) WHEN '01' THEN 'G' WHEN '02' THEN 'P' WHEN '03' THEN 'M' 
				WHEN '04' THEN 'L' WHEN '05' THEN 'D' WHEN '06' THEN 'S'  WHEN '07' THEN 'B' WHEN '08' THEN 'F' 
				WHEN '09' THEN 'N'  WHEN '10' THEN 'G' WHEN '11' THEN 'R' WHEN '13' THEN 'P' WHEN '14' THEN 'S' WHEN '15' THEN 'X'  
				ELSE '0' END  FROM #DEPT WHERE AATCINR=ITEM)DEPTCD,
			
		--	(SELECT SUBSTRING(AATVALN,1,12) FROM #TAB WHERE AATCCLA LIKE '%X3DESC%' AND AATCINR=ITEM ) AS CPM,	
		NULL AS CPM,
				
		--	(SELECT SUBSTRING(AATVALN,1,12) FROM #TAB WHERE  AATCCLA LIKE '%X2DESC%'  AND AATCINR=ITEM ) AS COLOR,
		NULL AS COLOR,
									   
	/*	(SELECT CASE  WHEN AATCATT = 'LOCAL' THEN 'L' WHEN AATCATT = 'ORGANIC' THEN 'O' ELSE 'A' END AS LN
          FROM #TAB WHERE AATCCLA='SGN0' AND AATCINR=ITEM  )*/ 
		  null LOEN,

		(SELECT FOUCNUF FROM ETL_FOUDGENE WHERE FOUCFIN=ARACFIN AND RUNID=0) VENDOR,
    
        /*  (SELECT  distinct 'M'  FROM ETL_ARTCOCA WHERE ARCCINR=ITEM  AND ARCIETI=0  AND RUNID=0 AND CONVERT(DATE,GETDATE()) BETWEEN ARCDDEB AND ARCDFIN) */
		null MULTIUPC,
			
			 ARACEAN AS VDRPRDID, 
			
			(SELECT FOULIBL FROM ETL_FOUDGENE WHERE FOUCFIN=ARACFIN AND RUNID=0) AS	 VDRNAME,
              
			--(SELECT ALLCOEFF FROM ETL_ARTULUL WHERE (ALLCINLP=ARACINL OR ALLCINLF=ARACINL))	CASEPACK, --LATER ENABLE
			0 AS CASEPACK, 

			ARACFIN AS VENDORIN,

			GOLDUPC AS GOLD_UPC,
              '' AS ERRDESC,
			AVICINV,

			promotype,

			PATATT AS PRCTYPE,

			OPLCEXOPR AS EVTCODE,

		
			CASE WHEN PROMOTYPE IN ('A','Y') THEN (SELECT dbo.Get_LinkedItemCode(A.ITEM,promotype,AVIPRIX,OPLCEXOPR,AVIDDEB,AVIDFIN,AVIMULTI,
			(select DISTINCT CATNO from #category x where x.item=a.item))) ELSE NULL END AS LLINKEDUPC ,
		    (SELECT BOTPOSUPC FROM #BDEPOSIT WHERE AATCATT=(SELECT LINK_CD FROM #BOTITEMS WHERE SITEM=A.ITEM)) as LINKEDCODE,
		--	(SELECT PRICE FROM GET_REGULARPRICE(1,GETDATE()) WHERE item_sv=A.avicinv ) REGPRICE 
		(SELECT PRICE FROM #REGPRICE X WHERE X.ITEM_SV=A.AVICINV AND X.RESSITE=A.RESSITE) REGPRICE,
		PRODTYP
		
	--	SELECT * FROM #BDEPOSIT
		
    FROM TEMP_POSITEMS A ,#TAB WHERE AATCINR=ITEM  ;-- WHERE ITEM_FLAG!='D'


--SELECT * FROM STG_POS_ITEMS

	RAISERROR('Insert POS tables',10,1) WITH NOWAIT


	 --*********POS COUPON  select * from pos_coupon_item

	 RAISERROR('rECORDS TO cOUPON....',10,1) WITH NOWAIT
	  
	  SELECT * INTO  #CURPRICE FROM DBO.GET_PRICEHISTORY (1,getdate());
DECLARE @gstore int,
        @posstore varchar(5);
	
DECLARE C_STORE CURSOR FOR select GoldStore,active_posstore from #teststore;
OPEN C_STORE;
FETCH NEXT FROM C_STORE INTO @gstore,@posstore;

WHILE @@FETCH_STATUS = 0  
BEGIN

	
set @request_id =(SELECT ISNULL((SELECT MAX(request_id)+1 from pos_item_job_sweeper),1));

		INSERT INTO pos_coupon_item (id,created_at,price_type,request_id,sequence,status,type,upc,value,name,department,promo_code)
			SELECT NEXT VALUE FOR SEQ_CPNID,
				GETDATE(),3,@request_id,1,'pending',CASE WHEN Lnkditmtyp=7 then 'store' END
				,UPC,LnkdItmVal	,LnkdItmDesc,dept_code,PromoCode from
				(select distinct RIGHT (REPLICATE('0',13)+CAST(LnkdItmupc AS VARCHAR(14)),14) UPC, LnkdItmVal ,LnkdItmDesc,PriceMethod,LnkdItmTyp,
				-- RIGHT (REPLICATE('0',13)+CAST(LINKEDCODE AS VARCHAR(14)),14) code, 
				b.ItemsPerCpn ItemsPerCpn,
				 DEPT_CODE,promocode from LINKED_ITM_DTL A JOIN LINKED_ITM_HDR B ON A.HdrID=B.HdrID JOIN
				 STG_POS_ITEMS ON LnkdItmupc=LLINKEDUPC  WHERE runid=@runid and STORE=@gstore) T

--SELECT * FROM LINKED_ITM_HDR
				 --SCPN from gold
      	INSERT INTO pos_coupon_item (id,created_at,price_type,request_id,sequence,status,type,upc,value,name,department,promo_code)
			SELECT NEXT VALUE FOR SEQ_CPNID,
				GETDATE(),3,@request_id,1,'pending',CASE WHEN PRODTYP=7 then 'store' WHEN PRODTYP=6 THEN 'manufacturer' END,
				UPC,PRICE,ITEM_NAME,DEPT_CODE ,0
				FROM STG_POS_ITEMS A 
				WHERE OP_FLAG='I' and RUNID=@runid and UPC IS NOT NULL  and STORE=@gstore AND PRODTYP  in (7,6);


		--IF @@ROWCOUNT>0 
           INSERT INTO pos_item_job_sweeper values (@request_id,getdate(),null,null,'COUPON',NULL,'FULL LOAD ','pending',@posstore);


 --select * from pos_deposit_item   ---
 set @request_id =(SELECT ISNULL((SELECT MAX(request_id)+1 from pos_item_job_sweeper),1));


		INSERT INTO POS_DEPOSIT_ITEM (id,created_at,department,deposit_type,name,price,pricing_method,quantity,request_id,status,upc)
				 SELECT  NEXT VALUE FOR SEQ_BOTID,GETDATE(),DEPT_CODE,CASE WHEN PRODTYP=1 then 'normal' WHEN PRODTYP=3 THEN 'return' END
				 ,dname,price,0,1,@request_id,'pending',upc  FROM
				(select distinct item_name dname, price,UPC, DEPT_CODE,PRODTYP
			 	FROM STG_POS_ITEMS A JOIN #BDEPOSIT  B ON  A.ITEM_IN=B.BOTCINR AND STORE=@gstore and RUNID=@RUNID  ) AS a

			IF @@ROWCOUNT>0 
           INSERT INTO pos_item_job_sweeper values (@request_id,getdate(),null,null,'DEPOSIT',NULL,'FULL LOAD ','pending',@posstore);

		
  --set @request_id=NEXT VALUE FOR SEQ_REQID;

  set @request_id =(SELECT ISNULL((SELECT MAX(request_id)+1 from pos_item_job_sweeper),1));
   
 
	INSERT INTO POS_NEW_ITEM(ID,CREATED_AT,DEPARTMENT_CODE,FOOD_STAMP_ALLOWED,ITEM_NAME,ITEM_TYPE,LARGE_LINKED_TO,LINKED_ITEM_CODE,prescription_item,
	PRICE_METHOD,PRICE_REQUIRED,PRICE_TYPE,QUALIFIED_HEALTHCARE_PRODUCT,QUANTITY_NOT_ALLOWED,QUANTITY_REQUIRED,REPORTING_CODE,RESTRICTED_SALE_TYPE,SALE_PRICE,
	SALE_QUANTITY,TAXABLEA,UPC,VALUE_CARD_TYPE,WIC_ALLOWED,ERROR_MESSAGE,REQUEST_ID,STATUS)
	   SELECT 
                  NEXT VALUE FOR SEQ_POSID,
				  GETDATE(),DEPT_CODE,FOODSTMP,ITEM_NAME,PRODTYP,
				  RIGHT (REPLICATE('0',13)+CAST(LLINKEDUPC AS VARCHAR(14)),14) ,RIGHT(LINKEDCODE,4), 
				  RX,SCALEABLE,PRICERQD,NULL,QHP,QTYONE,QTYRQD,null,RESTR,   --rptcode need to check the value later
				  CASE WHEN LLINKEDUPC IS NOT NULL THEN REGPRICE ELSE isnull(PRICE,0) END ,
				  1,TAX,UPC,NULL,WIC,NULL,@request_id,'pending' --LINK TO DEP FLAG
	  FROM STG_POS_ITEMS A 
	  WHERE OP_FLAG='I' and RUNID=@runid and UPC IS NOT NULL  and STORE=@gstore AND PRODTYP=0 AND ISNULL(GPRODTYPE,'A')<>'ZERO'
	--  AND NOT EXISTS (SELECT 1 FROM #BDEPOSIT C WHERE C.BOTPOSUPC=A.UPC);

	  
	INSERT INTO POS_NEW_ITEM(ID,CREATED_AT,DEPARTMENT_CODE,FOOD_STAMP_ALLOWED,ITEM_NAME,ITEM_TYPE,LARGE_LINKED_TO,LINKED_ITEM_CODE,prescription_item,
	PRICE_METHOD,PRICE_REQUIRED,PRICE_TYPE,QUALIFIED_HEALTHCARE_PRODUCT,QUANTITY_NOT_ALLOWED,QUANTITY_REQUIRED,REPORTING_CODE,RESTRICTED_SALE_TYPE,SALE_PRICE,
	SALE_QUANTITY,TAXABLEA,UPC,VALUE_CARD_TYPE,WIC_ALLOWED,ERROR_MESSAGE,REQUEST_ID,STATUS,ldq_Deal_quantity,ldq_Limit_quantity)
	   SELECT 
                  NEXT VALUE FOR SEQ_POSID,
				  GETDATE(),DEPT_CODE,FOODSTMP,ITEM_NAME,PRODTYP,
				  RIGHT (REPLICATE('0',13)+CAST(LLINKEDUPC AS VARCHAR(14)),14) ,RIGHT(LINKEDCODE,4), 
				  RX,4,PRICERQD,NULL,QHP,QTYONE,QTYRQD,null,RESTR,   --rptcode need to check the value later
				  CASE WHEN LLINKEDUPC IS NOT NULL THEN REGPRICE ELSE isnull(PRICE,0) END ,
				  1,TAX,UPC,NULL,WIC,NULL,@request_id,'pending',1,99
	  FROM STG_POS_ITEMS A 
	  WHERE OP_FLAG='I' and RUNID=@runid and UPC IS NOT NULL  and STORE=@gstore AND PRODTYP=0 AND ISNULL(GPRODTYPE,'A')='ZERO';

	 -- 	IF @@ROWCOUNT>0 
	  INSERT INTO pos_item_job_sweeper values (@request_id,getdate(),null,null,'NEW',NULL,'FULL LOAD ','pending',@posstore);
	  
	--  UPDATE pos_item_job_sweeper set status='pending' where store_number=@posstore and  request_id=@requestid;
	  	  FETCH NEXT FROM C_STORE INTO @gstore,@posstore;
END;
CLOSE C_STORE;
DEALLOCATE C_STORE;

--  UPDATE pos_item_job_sweeper set status='sent' where request_id=94

				--    SELECT * FROM pos_item_job_sweeper  

					

					--SELECT COUNT(*) FROM pos_item_job_sweeper where request_id


                   /*  PRODTYP,0,NULL,0,1,isnull(PRICE,0),0,0,ITEM_NAME,PRODTYP,0,0,0,0,NULL,0,0,0,POINTS,0,RX,SCALEABLE,
                     ,0,QTYONE,,00,RESTR,isnull(PRICE,0),0,0,1,NULL,TAX,TAX,TAX,TAX,TAX,TAX,TAX,TAX,
                     upc,NULL,0,WIC,10,NULL,1,'pending' 
					 FROM STG_POS_ITEMS A WHERE OP_FLAG='I' and RUNID=@RUNID AND UPC is not null	
				
				--ROW_NUMBER() OVER (ORDER BY STORE,OP_FLAG,RUNID)

				
			insert into POS_UPDATE_ITEM
				 SELECT 
                             NEXT VALUE FOR SEQ_POSID,GETDATE(),NULL,NULL,null,0,0,0,NULL,NULL,0,DEPT_CODE,FOODSTMP,
                     PRODTYP,0,NULL,0,1,ISNULL(PRICE,0),0,0,ITEM_NAME,PRODTYP,0,0,0,0,NULL,0,0,0,POINTS,0,RX,SCALEABLE,
                     PRICERQD,0,QTYONE,QTYRQD,00,RESTR,ISNULL(PRICE,0),0,0,1,NULL,TAX,TAX,TAX,TAX,TAX,TAX,TAX,TAX,
                     upc,NULL,0,WIC,10,NULL,2,'pending'
					 FROM STG_POS_ITEMS A WHERE OP_FLAG='U' and RUNID=@RUNID AND UPC is not null				
					 
					 SELECT * FROM POS_DELETE_ITEM
	
			insert into POS_DELETE_ITEM
				 SELECT  NEXT VALUE FOR SEQ_POSID,NULL,GETDATE(),null,1,'pending','10210175' '00000100136319' FROM STG_POS_ITEMS A WHERE LLINKEDUPC='10210175'
				 OP_FLAG='D' and RUNID=@RUNID AND UPC is not null 
				 
				 update pos_item_job_sweeper set error_message=null,status='pending' where store_number='0094' ;--where */  --LATER UNCOMMENT


				 
				 --select * from pos_item_job_sweeper

				 --LATER WE USE THE BELOW 

		/*SET @NEWCNT=(SELECT COUNT(1) FROM pos_item_job_sweeper WHERE store_number='0094' and action_type='NEW' )--and status='pending');
		SET @UPDCNT=(SELECT COUNT(1) FROM pos_item_job_sweeper WHERE store_number='0094' and action_type='UPDATE');--and status='pending');
		SET @DELCNT=(SELECT COUNT(1) FROM pos_item_job_sweeper WHERE store_number='0094' and action_type='DELETE'); -- and status='pending');
  	 
	 if @NEWCNT>0
	 BEGIN
	 UPDATE pos_item_job_sweeper set error_message='' ,status='pending' where store_number='0094' and action_type='NEW';
	 END
	 ELSE
	 BEGIN
	 INSERT
	 END;*/

				 	RAISERROR('Delete/Insert Lookup table',10,1) WITH NOWAIT

		-- INSERT INTO STG_POS_ITEM_LOOKUP SELECT ITEM_IN,ITEM_EX,SKU,GOLD_UPC,STORE,GETDATE(),VENDOR,UPC FROM STG_POS_ITEMS WHERE OP_FLAG='I' and runid=@RUNID AND UPC IS NOT NULL;

				/* DELETE A FROM STG_POS_ITEM_LOOKUP A WHERE EXISTS (SELECT 1 FROM STG_POS_ITEMS B WHERE A.ITEM_IN=B.ITEM_IN AND A.SKU=B.SKU AND A.SITE#=B.STORE 
				 AND A.VENDOR=B.VENDOR  AND  OP_FLAG='D' and RUNID=@RUNID AND UPC is not null );*/

				 --as of now we use existing id
				
			/*	INSERT INTO pos_item_job_sweeper SELECT REQUEST_ID ,GETDATE(),NULL,
			    NULL,'UPDATE','','pending',(select distinct PosStore from GoldPos_Store_map)  FROM STG_POS_ITEMS WHERE RUNID=@RUNID AND OP_FLAG='U' 
				AND EXISTS (SELECT 1 FROM POS_UPDATE_ITEM WHERE batch_id=@RUNID)

				select * from pos_item_job_sweeper
			
				INSERT INTO pos_item_job_sweeper SELECT REQUEST_ID ,GETDATE(),NULL,
				NULL,'NEW','',' ','pending',(select distinct PosStore from GoldPos_Store_map)  FROM STG_POS_ITEMS WHERE RUNID=677 AND d item_in=9014433
				AND EXISTS (SELECT 1 FROM POS_NEW_ITEM WHERE batch_id=@RUNID)

				select * from stg_pos_items

				select * from pos_new_item where upc='00086105600263'
				
				INSERT INTO pos_item_job_sweeper SELECT REQUEST_ID ,GETDATE(),NULL,
				NULL,'DELETE','','pending',(select distinct PosStore from GoldPos_Store_map)  FROM STG_POS_ITEMS WHERE RUNID=@RUNID AND OP_FLAG='D'  AND EXISTS (SELECT 1 FROM POS_DELETE_ITEM WHERE batch_id=@RUNID)
 */
				-- SELECT * FROM STG_POS_ITEM_LOOKUP
				

			/*		DROP TABLE #PROCESS_ITEM;
					DROP TABLE #ETL_ARTATTRI;
					DROP TABLE #ETL_ARTCOCA;
				    DROP TABLE #ETL_ARTRAC;
					DROP TABLE #ETL_STRUCOBJ;
					DROP TABLE #ETL_TRA_STRUCOBJ;
					DROP TABLE #ETL_FOUDGENE;
					DROP TABLE #ETL_ARTUC;	
					DROP TABLE #ETL_ARTUV;
					DROP TABLE #ETL_AVESCOPE;
					DROP TABLE #ETL_AVETAR;
					DROP TABLE #ETL_AVEPRIX;
					DROP TABLE #ETL_RESEAU;
					DROP TABLE #ETL_OPRATTRI
					DROP TABLE #ETL_OPRPLAN
              
UPDATE ETL_AVEPRIX  SET OP_FLAG='N' WHERE RUNID=0 AND OP_FLAG LIKE '%P'
UPDATE ETL_AVETAR   SET OP_FLAG='N' WHERE RUNID=0 AND OP_FLAG LIKE '%P'
UPDATE ETL_AVESCOPE SET OP_FLAG='N' WHERE RUNID=0 AND OP_FLAG LIKE '%P';
UPDATE ETL_AVESCOPE SET OP_FLAG='N' WHERE RUNID=0 AND OP_FLAG LIKE '%P';*/

/*

			  	RAISERROR('Label processing Starts',10,1) WITH NOWAIT


					
    SELECT  
        * INTO #REGPRICE
    	  
    FROM 
    (
        SELECT distinct
            I.aviprix AS Reg_price,
            U.RESSITE AS Rstore,
            I.avicinv AS Ritem_sv,
			I.aviddeb as regstdate,
		    I.avidfin as regenddate,
			I.avimulti AS Ravimulti,
			ROW_NUMBER() OVER(PARTITION BY U.ressite, I.avicinv ORDER BY AVINTAR) AS rnk 
         --   case when(aviddeb>avoddeb) then aviddeb else aviddeb end AS latest_date,
          --  case when(avidmaj>avodmaj) then avidmaj else avodmaj end AS last_update_date,
         --   avoprio ,
		--	avenopr 
        FROM 
            etl_avetar e 
            JOIN etl_avescope o ON aventar = avontar 
            JOIN etl_aveprix i  ON aventar = avintar 
			JOIN TEMP_POSITEMS AI   ON AI.AVICINV=I.AVICINV AND AI.AVORESCINT=O.AVORESCINT			
		    JOIN etl_OPRATTRI A ON PATNOPR = AVENOPR 			
            AND PATCLA = 'PRICE_TP' 
            AND A.PATATT = 'REG'           
            JOIN etl_OPRPLAN  L ON OPLNOPR = PATNOPR  
		    JOIN ETL_RESEAU U   ON O.avorescint = respere and resresid = 'SF'

            WHERE 
                 CONVERT(DATE,GETDATE()) BETWEEN aveddeb AND avedfin
                AND  CONVERT(DATE,GETDATE())  BETWEEN avoddeb AND avodfin
                AND  CONVERT(DATE,GETDATE())  BETWEEN I.aviddeb AND I.avidfin 
				AND  CONVERT(DATE,GETDATE())   BETWEEN PATDDEB AND PATDFIN
				AND U.ressite=AI.RESSITE
				--AND I.AVICINV=AI.AVICINV
				AND E.RUNID=0
				AND O.RUNID=0
				AND I.RUNID=0  
				AND A.RUNID=0
				AND L.RUNID=0
				AND U.RUNID=0
				) 
	AS a WHERE rnk=1


	--SELECT * FROM #REGPRICE

                    DECLARE LAB_CURSOR CURSOR 

                     FOR 
					-- SELECT * FROM STG_POS_ITEMS

					  SELECT UPC,ITEM_IN,ITEM_SV,ITEM_EX,DEPT_CODE,STORE,PRICE,OP_FLAG,SKU,FREEFORM,RPTCODE,DEPTCD,LBLDESC,CPM,COLOR,LOEN,VENDOR,VENDORIN,CASEPACK,VDRPRODID,VDRDESC
					  FROM STG_POS_ITEMS WHERE OP_FLAG IN ('L','I') AND RUNID=@RUNID AND UPC IS NOT NULL AND STORE IS NOT NULL AND VENDOR IS NOT NULL 
					  AND STORE IN (SELECT GoldStore FROM GoldPos_Store_map) ;
					  ;--IN ('I','U','D','L')   -- ignore 'N' --AND OP_FLAG<>'D';???? IF NEEDED WE WILL 'I' OP_FLAG 012524

					  OPEN LAB_CURSOR

					  	RAISERROR('Label processing Starts',10,1) WITH NOWAIT

				FETCH NEXT FROM LAB_CURSOR INTO  @UPC,@ITEM_IN,@ITEM_SV,@CEXR,@DEPT,@GOLDSTORE,@PRICE,@OP_FLAG,@SKU,@FREEFORM,@RPTCODE,@DEPTCD,@LBL,@CPM,@COLOR,@LOEN,@VENDOR,@VDRIN,@CASEPACK,@VDRPRDID,@VDRNAME;--- CHNAGE CINR NAME

					   RAISERROR('Label AFTER FETCH',10,1) WITH NOWAIT
					  
                      WHILE @@FETCH_STATUS =0
                        BEGIN

						  RAISERROR('Label PRINTING STARTS',10,1) WITH NOWAIT
						/* SELECT * INTO #ARTUC FROM ETL_ARTUC WHERE ARACINR=@ITEM_IN  
					--	AND ARASITE=(select max(site#) from stg_pos_item_lookup WHERE item_in=@ITEM_IN)  
					    AND ARACFIN=@VDRIN
					    AND runid=0
						AND ARASITE=@GOLDSTORE
                        AND CAST(GETDATE() AS DATE) BETWEEN ARADDEB AND ARADFIN */

						  SET @DEPT=@DEPT;	
						  SET @STORE=@GOLDSTORE ;--(select max(site#) from stg_pos_item_lookup WHERE ITEM_IN=@ITEM_IN) ;

						--  print 'test12'
						  print @store;
						  print @GOLDSTORE;

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
							select  @SCATGRY= reverse(substring(reverse(sobcext),1,3)) from n,ETL_STRUCOBJ obj
							where sobcint=objpere 
							and sobidniv=3 ; --groupnumber

					
				--	print 'pri'

                       SET @REG =(SELECT CASE WHEN @UPC IS NOT NULL  THEN '1' ELSE '0' END );

					
					--  SET @LIMITDESC=(SELECT CASE WHEN @OP_FLAG='D' THEN 'DISC' END);-- (SELECT 'DISC' FROM STG_POS_ITEMS WHERE RUNID=@RUNID AND OP_FLAG='D');

					 
					--  PRINT @LIMITDESC


					--  (SELECT @VDRNUM=FOUCNUF,@VDRIN=FOUCFIN FROM ETL_FOUDGENE  WHERE 
					SET @VDRNUM=@VENDOR
					
					--  WHERE FOUCFIN=(select aracfin from(SELECT aracfin, ROW_NUMBER() OVER(ORDER BY ARATFOU asc) AS Row FROM #ARTUC 
                                     --    ) t where row=1))

					 -- SET @VDRNUM   =  (SELECT FOUCNUF FROM ETL_FOUDGENE WHERE FOUCFIN=(select aracfin from(SELECT aracfin, ROW_NUMBER() OVER(ORDER BY ARATFOU DESC) AS Row FROM #ARTUC 
                       --                  ) t where row=1));
   
					  PRINT @VDRNUM
					  		  PRINT 'STEP3'

					/*  SET @DEPTCD=   (SELECT CASE CONVERT(INT,RIGHT(AATCCLA,2)) WHEN 1 THEN 'G' WHEN 2 THEN 'P' WHEN 3 THEN 'M' WHEN 4 THEN 'L' WHEN 5 THEN 'D' WHEN 6 THEN 'S' 
				             WHEN 7 THEN 'B' WHEN 8 THEN 'F' WHEN 9 THEN 'N'  WHEN 10 THEN 'G' WHEN 11 THEN 'R' WHEN 13 THEN 'P' WHEN 14 THEN 'S' WHEN 15 THEN 'X'  ELSE '0' END 
							 FROM ETL_ARTATTRI WHERE AATCCLA LIKE 'DEPT_%' AND AATCINR=@ITEM_IN AND RUNID=0 AND (CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN));
							 */

							 PRINT @DEPTCD

							PRINT 'NEW2'
					--SET @CPM=
				          --     (SELECT SUBSTRING(AATVALN,1,12) FROM ETL_ARTATTRI WHERE AATCINR=@ITEM_IN AND AATCCLA LIKE '%X3DESC%' AND RUNID=0 AND (CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN));			
					--	PRINT @CPM
						
				--	SET @COLOR=     (SELECT SUBSTRING(AATVALN,1,12) FROM ETL_ARTATTRI WHERE AATCINR=@ITEM_IN AND AATCCLA LIKE '%X2DESC%' AND RUNID=0 AND (CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN));	
							   
                PRINT @COLOR
				  SET @STORENUM =@GOLDSTORE;-- (SELECT PosStore from GoldPos_Store_map where GoldStore=@GOLDSTORE); -- (SELECT STORE_NUMBER FROM pos_item_job_sweeper WHERE request_id=1);
				  
				  PRINT @STOREnum
		       --   set @vdrprdid= (SELECT ARACEAN FROM #ARTUC WHERE ARACINR=@ITEM_IN AND ARASITE=@GOLDSTORE AND ARACFIN=@VDRIN)
				                --  (select aracean from(SELECT ARACEAN,ROW_NUMBER() OVER(ORDER BY ARATFOU DESC) AS ROW FROM #ARTUC )t WHERE ROW=1);

								PRINT @ITEM_IN
								PRINT @STORE
								PRINT @VDRIN
								PRINT 'BB'
								PRINT @VDRPRDID

									--SELECT * FROM STG_POS_ITEMS

				 /* SET @VDRNAME =
								   (SELECT FOULIBL FROM ETL_FOUDGENE WHERE FOUCNUF=@VDRNUM and runid=0);*/


									 PRINT @VDRNAME
									
			  /*	SET @CASEPACK= 
									(SELECT ALLCOEFF FROM ETL_ARTULUL WHERE allcinlp= (SELECT aracinl FROM #ARTUC WHERE ARACINR=@ITEM_IN AND ARACFIN=@VDRIN AND ARASITE=@GOLDSTORE) and runid=0)*/
									--(SELECT aracinl FROM(SELECT ARACINL, ROW_NUMBER() OVER(ORDER BY ARATFOU DESC) AS ROW FROM 
									
								--	#ARTUC WHERE ITEMIN, ARACFIN=VDRIN AND ARASITE=@STORE  
				                      --)t WHERE ROW=1));

										PRINT @CASEPACK

			  SET @MULTIUPC= (SELECT DISTINCT 'M'   FROM ETL_ARTCOCA WHERE ARCCINR=@ITEM_IN AND RUNID=0   AND ARCIETI=0);

			  PRINT @MULTIUPC
		
				SET @LOEN=
                 (SELECT CASE  WHEN AATCATT = 'LOCAL' THEN 'L'
				 WHEN AATCATT = 'ORGANIC' THEN 'O' 
				  WHEN AATCATT = 'EXCLUSIV' THEN 'E'
				   WHEN AATCATT = 'PRIVATE' THEN 'X'
				 ELSE 'A' END AS LN
                FROM #TAB WHERE AATCINR=@ITEM_IN  AND AATCCLA='SGN0'  AND CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN);
              PRINT @LOEN

			  SET @UPCBAR=(SELECT CASE WHEN @VDRNUM<>50379 THEN @UPC ELSE '0' END);


			  PRINT @UPCBAR
			  SET @PROCESSTYPE =(SELECT CASE WHEN @OP_FLAG ='I' THEN 'N' ELSE 'M' END);

		 
		     PRINT @PROCESSTYPE
				
				 SET @MALAMA= (SELECT CASE WHEN SOCCHAIN =13 THEN 'Y' ELSE 'N' END FROM ETL_SITDGENE WHERE SOCSITE =@GOLDSTORE and runid=0);

				 PRINT @MALAMA
				 
			--	SET @FORMNO=(SELECT CASE WHEN @MALAMA='Y'  THEN 'UDLRG' ELSE 'FDLS' END );


			--	PRINT @FORMNO
				    
				  
				  ---U COMMENTED
				 SET @DOCNUM = (SELECT  CASE WHEN @OP_FLAG ='I' THEN '30'  WHEN @UPC BETWEEN '20000000000' AND '29999999999' THEN '11'
				 /*WHEN @OP_FLAG ='U' THEN '40'*/ 
				 WHEN @OP_FLAG='D' THEN '13' 
				 WHEN  'MKTG'=(SELECT AATCATT FROM #TAB WHERE AATCCLA='PRODTYP' AND  CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN AND 
				 AATCINR=@ITEM_IN ) THEN '90'
				 WHEN '2' =(SELECT (RIGHT(AATCCLA,1)) FROM #TAB  WHERE AATCCLA LIKE 'DEPT_02' and CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN 
				 AND AATCINR=@ITEM_IN and CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN  ) THEN '42'
				 ELSE '40' END );

				-- PRINT @DOCNUM

				set @lblsize= (SELECT distinct CASE WHEN RIGHT(AATCATT, 1) IN ('S') 
                THEN 'S'  when  RIGHT(AATCATT, 1) IN ('D') 
                THEN 'D' when RIGHT(AATCATT, 1) IN ('P') then 'P'
				ELSE 'N' END from #TAB where aatcinr=@ITEM_IN and CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN 
				and aatccla ='LBL0'  );

            
		      set @sgnsize=(SELECT distinct CASE WHEN left(AATCATT, 1) IN ('A') 
                THEN 'A' when left(AATCATT, 1) IN ('O') then 'O'
				WHEN left(AATCATT, 1) IN ('L') 
                THEN 'L' WHEN left(AATCATT, 1) IN ('P') 
                THEN 'P'
				ELSE 'N' END from #TAB where aatcinr=@ITEM_IN and CAST(GETDATE() AS DATE) BETWEEN AATDDEB AND AATDFIN and aatccla = 'SGN0'
		                  );
          
		    set @FORMNO =( select distinct case when @MALAMA='Y' and @lblsize='D' and @sgnsize='L' then 'UDLRG' when @lblsize='P'  then 'UPARG'  when @lblsize='S' then 'FDLS'  when @lblsize='P' then 'PARG' 
	              when @lblsize='D' and @sgnsize='A' then 'FDCRG' when left(@sgnsize, 1) in ('A' ,'E') OR @sgnsize = ' ' then 'ULBLA' when @MALAMA<>'Y' and @lblsize<>'D' and @sgnsize<>'L' then 'UDARG' 
                  when left(@sgnsize, 1) not in ('A', 'E') OR @sgnsize <> ' '  then 'ULBL20' when @lblsize<>'P' then 'FDLS' when @lblsize<>'D' and @sgnsize<>'A' then 'F' + @lblsize + @sgnsize + 'RG'
                 else 'FDLS' end );

				-- SELECT * FROM FDL_LABEL
							
INSERT INTO FDL_LABEL 
				(RUNID ,EFFDATE,STORNUM,APPLYDT,UPC,DEPT,CATEGORYNUM,GROUPNUM,UPCBAR,EA,FREEFORMSZ,RPTCODE,LBLDESC,REGLBL,LIMITDESC,DEPTCD,CPM,COLORDESC,ORDERMVMT,SKU,VENDNUM,VENDNM,vendprodnum,CASEPACK,MULT_UPC,EAP,PRICE,LOEN,TAGS_PAGE,DOCNUM,PROCESS_TYPE,FORM_NO,EVENTCD,
				PRCTYP,REGPRCMULT,REGPRICE,EFFTHRU,PRCMULT,SAVINGS,UNITPRICE) 
					VALUES (@RUNID,GETDATE(),@STORENUM,(select AVIDDEB from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE)
					,@UPC,@DEPT,@CATGRY,@SCATGRY,@UPCBAR,@EA,@FREEFORM,@RPTCODE,@LBL,@REG,@LIMITDESC,@DEPTCD,@CPM,@COLOR,NULL,@SKU,@VDRNUM,@VDRNAME,@vdrprdid,@CASEPACK,@MULTIUPC,@EAP,@PRICE,@LOEN,1,@DOCNUM,@PROCESSTYPE,@FORMNO,
					(select OPLCEXOPR from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					(select PATATT from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					(select RAVIMULTI from #REGPRICE where Ritem_sv=@ITEM_SV AND Rstore=@STORE),
					(select Reg_price from #REGPRICE where Ritem_sv=@ITEM_SV AND Rstore=@STORE),
					(select AVIDFIN from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					(select AVIMULTI from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),
					((select Reg_price from #REGPRICE where Ritem_sv=@ITEM_SV AND Rstore=@STORE)-@PRICE),					
					 @PRICE/ISNULL((select AVIMULTI from TEMP_POSITEMS where AVICINV=@ITEM_SV AND RESSITE=@STORE),1))
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
				FROM STG_POS_ITEMS WHERE RUNID=@RUNID AND STORE=*/
				--DROP TABLE #ARTUC;

								
				print 'new entry'

			
		
		     -- SET @MALAMA= (SELECT CASE WHEN SOCCHAIN =13 THEN 'Y' ELSE 'N' END FROM ETL_SITDGENE WHERE SOCSITE =@STORE);

		      --   print @MALAMA



			--	 update fdl_label set FORM_NO=@FORM where runid=@RUNID;


			 FETCH NEXT FROM LAB_CURSOR INTO  @UPC,@ITEM_IN,@ITEM_SV,@CEXR,@DEPT,@GOLDSTORE,@PRICE,@OP_FLAG,@SKU,@FREEFORM,@RPTCODE,@DEPTCD,@LBL,@CPM,@COLOR,@LOEN,@VENDOR,@VDRIN,@CASEPACK,@VDRPRDID,@VDRNAME;
					 END;
                    CLOSE LAB_CURSOR;

					DEALLOCATE LAB_CURSOR;

					
				RAISERROR('Label Processing Ends..',10,1) WITH NOWAIT	
				

					RAISERROR('Delete/Insert Lookup table',10,1) WITH NOWAIT

*/
					--SELECT LEN(UPC) FROM STG_POS_ITEMS  WHERE RUNID=486 AND   pos_new_item
					                --MOVE THIS QRY TO SSIS
				 /*INSERT INTO STG_POS_ITEM_LOOKUP SELECT ITEM_IN,ITEM_EX,SKU,GOLD_UPC,STORE,GETDATE(),VENDOR,UPC FROM STG_POS_ITEMS A WHERE OP_FLAG='I' 
				 and runid=@RUNID AND UPC IS NOT NULL
				 AND EXISTS (SELECT 1 FROM pos_new_item B WHERE A.UPC=B.UPC AND B.status='processed'  )*/

				 --THIS ONE WILL BE MOVE TO SSIS
			----	 DELETE A FROM STG_POS_ITEM_LOOKUP A WHERE EXISTS (SELECT 1 FROM STG_POS_ITEMS B WHERE A.ITEM_IN=B.ITEM_IN AND A.SKU=B.SKU AND A.SITE#=B.STORE 
			--	 AND A.VENDOR=B.VENDOR  AND  OP_FLAG='D' and RUNID=@RUNID AND UPC is not null );  


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

