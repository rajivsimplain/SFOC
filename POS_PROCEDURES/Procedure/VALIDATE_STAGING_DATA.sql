USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[VALIDATE_STAGING_DATA]    Script Date: 2/5/2025 11:20:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[VALIDATE_STAGING_DATA]
AS
BEGIN
    -- Check if there are any employees with a NULL name
	 --   update Stg_label 
     --  set xlserr = '-1',XNUERRCD=1,
    --       xlserrdesc = 'Mandatory Field sku is required',
    --       MODIFIEDDATE  = CURRENT_TIMESTAMP ,
    --       Stg_label.ModifiedBy  = 'UpdStagHd'
    -- where Stg_label.XNUXPRID = 1 ;
       --and sku is null and Stg_label.xlssessionid in (select max(xlssessionid) from Stg_label)  and Stg_label.SKU not in ('123456789012','123456789017','123456789018');


	   	--    update Stg_label 
     --  set xlserr = null,XNUERRCD=null,
     --      xlserrdesc = null ,
     --      MODIFIEDDATE  = CURRENT_TIMESTAMP ,
     --     Stg_label.ModifiedBy  = 'UpdStagHd'
     --where Stg_label.XNUXPRID = 1 and   and Stg_label.SKU not in ('123456789012','123456789017','123456789018');

	 /*RAISERROR('lABEL Loading starts',10,1) WITH NOWAIT
	
	UPDATE A SET STATUSNO='2',XLSERR='1',XLSERRDESC='INVALID SKU' FROM STG_LABEL_UPLOAD A
	WHERE NOT EXISTS (SELECT 1 FROM ETL_ARTATTRI WHERE AATCCLA='PRODID' AND AATVALN=A.SKU and CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0)
	AND STATUSNO='0'*/


    -- Declare variables
    DECLARE @skuv NVARCHAR(MAX), @upcv NVARCHAR(MAX);
    -- Create a cursor
    DECLARE validatestage CURSOR FOR
    SELECT sku, upc
    FROM stg_label 
    WHERE stg_label.xlssessionid in (select max(xlssessionid) from Stg_label); -- Adjust condition as needed

    -- Open the cursor
    OPEN validatestage;

    -- Fetch the first row
    FETCH NEXT FROM validatestage INTO @skuv, @upcv;

    -- Loop through the cursor
    WHILE @@FETCH_STATUS = 0
    BEGIN

	--SKU
	 --  update Stg_label 
    -- set xlserr = '-1',XNUERRCD=1,
    --      xlserrdesc = 'SKU is not valid',
    --      MODIFIEDDATE  = CURRENT_TIMESTAMP ,
    --       Stg_label.ModifiedBy  = 'UpdStagHd'
    -- where Stg_label.XNUXPRID = 1 and sku in (@skuv) and Stg_label.xlssessionid in (select max(xlssessionid) from Stg_label)  and Stg_label.SKU not in ('112233445566','112233445567','112233445568');

	 	UPDATE A SET XLSERR='-1',XLSERRDESC='INVALID SKU',MODIFIEDDATE  = CURRENT_TIMESTAMP ,
           a.ModifiedBy  = 'UpdStagHd' FROM Stg_label A
	WHERE NOT EXISTS (SELECT 1 FROM ETL_ARTATTRI WHERE AATCCLA='PRODID' AND AATVALN=A.SKU and CAST(GETDATE()AS DATE) BETWEEN AATDDEB AND AATDFIN AND RUNID=0) AND A.sku in (@skuv) 
	AND  A.xlssessionid in (select max(xlssessionid) from Stg_label) 

	---------------------------------------------------------------------------------
	--UPC------
		   update Stg_label 
     set xlserr = '-1',XNUERRCD=1,
          xlserrdesc = 'UPC is not valid',
          MODIFIEDDATE  = CURRENT_TIMESTAMP ,
           Stg_label.ModifiedBy  = 'UpdStagHd'
     where Stg_label.XNUXPRID = 1 and NOT EXISTS (SELECT 1 FROM ETL_ARTCOCA WHERE  ETL_ARTCOCA.ARCCODE = (RIGHT('000000000000'+Stg_label.upc,12))   and CAST(GETDATE()AS DATE) BETWEEN ETL_ARTCOCA.ARCDDEB 
	 AND ETL_ARTCOCA.ARCDFIN AND RUNID=0) and upc in (@upcv) and Stg_label.xlssessionid in (select max(xlssessionid) from Stg_label);
	 --  and Stg_label.upc not in ('123456789012','123456789017','123456789018');


	 
   -- UPDATE A SET XLSERR='-1',XLSERRDESC='INVALID VENDOR' FROM STG_LABEL A
	--WHERE NOT EXISTS (SELECT 1 FROM ETL_FOUDGENE WHERE FOUCNUF=A.VENDOR AND RUNID=0) AND    A.xlssessionid in (select max(xlssessionid) from Stg_label) 



	  -- TODOs
	 -- Vendor Validation

	 -- label effective >= pricec Effective

        -- Fetch the next row
        FETCH NEXT FROM validatestage INTO @skuv, @upcv;
    END;

    -- Close and deallocate the cursor
    CLOSE validatestage;
    DEALLOCATE validatestage;




END;
GO

