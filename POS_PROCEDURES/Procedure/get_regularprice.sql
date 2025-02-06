USE [POS]
GO

/****** Object:  UserDefinedFunction [dbo].[GET_REGULARPRICE]    Script Date: 2/5/2025 11:26:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Priya Baskaran
-- Create date:  09-09-2024
-- Description:	Get the Retailprice of the item
-- =============================================
CREATE FUNCTION [dbo].[GET_REGULARPRICE]
(	
	-- Add the parameters for the function here
	-- Add the parameters for the function here
@P_site     INT=1,
@P_Date		DATE=NULL
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	--SELECT 0
 SELECT storenum AS STORENUM,item_sv,UPC,CONVERT(DATE,EFFFROM) EFFFROM,CONVERT(DATE,EFFTHRU) EFFTHRU,PRCTYPE,CONVERT(INT,PRCMULTI) PRCMULTI,PRICE,EVENTCD
 --PRCTYPE,COUNT(*) COUNT --INTO #TPR  --PRICE_V
 FROM 
(
    SELECT distinct	 
        aviprix AS price,
        avorescint AS storenum,
		ARCCODE AS UPC,
        avicinv AS item_sv,
		aviddeb as EFFFROM,
		avidfin as EFFTHRU,
		avimulti as prcmulti,
		OPLCEXOPR AS EVENTCD,
		--(SELECT AATVALN FROM ETL_ARTATTRI WHERE AATCINR=ARCCINR AND AATCCLA='PRODID' AND  CONVERT(DATE,@P_DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0) AS PRODID  ,
	    ARTCEXR AS ITEM,
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
		JOIN ETL_ARTCOCA C ON ARCCINV=AVICINV AND ARCIETI=1 AND CONVERT(DATE,@P_DATE) BETWEEN ARCDDEB AND ARCDFIN
		JOIN ETL_ARTRAC ON ARTCINR=ARCCINR
		-- LEFT JOIN ETL_ARTATTRI AA ON AATCINR=ARCCINR AND AATCCLA='PRODID' AND  CONVERT(DATE,@P_DATE) BETWEEN AATDDEB AND AATDFIN AND AA.RUNID=0
	   WHERE 
           CONVERT(DATE,@P_DATE)  BETWEEN aveddeb AND avedfin
        AND  CONVERT(DATE,@P_DATE)  BETWEEN avoddeb AND avodfin
        AND  CONVERT(DATE,@P_DATE)  BETWEEN aviddeb AND avidfin 
		AND  CONVERT(DATE,@P_DATE)  BETWEEN PATDDEB AND PATDFIN	
		and  CONVERT(DATE,@P_DATE)  BETWEEN resddeb and resdfin
		

		AND ressite=@P_site
		--AND AVICINV=IIF(@P_Cinv=1 ,AVICINV,@P_CinV)
		AND E.RUNID=0
				AND O.RUNID=0
				AND I.RUNID=0  
				AND A.RUNID=0
				AND L.RUNID=0 
				AND U.RUNID=0
				AND C.RUNID=0
				--AND AA.RUNID=0

				) AS T  WHERE RNK=1-- GROUP BY PRCTYPE -- ORDER BY PRCTYPE
		
)


GO

