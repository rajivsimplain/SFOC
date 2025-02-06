USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[insert_label]    Script Date: 2/5/2025 11:16:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  CREATE PROCEDURE [dbo].[insert_label] (@label dbo.LABEL_TYPE READONLY)
    as
        DECLARE @form_no   VARCHAR(10);

    BEGIN
        IF @form_no in ('FDLRG', 'FDERG', 'FDORG', 'FDNRG')
        
           SET @form_no = 'FDCRG';
        ELSE
           SELEcT @form_no = form_no FROM @LABEL;
        

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
        SELECT 
            1 as runid,
			l.effdate
            ,l.stornum
            ,l.applydt
            ,l.upc
            ,l.effthru
            ,l.docnum
            ,l.process_type
            ,case when @form_no in ('FDLRG', 'FDERG', 'FDORG', 'FDNRG') then 'FDCRG' else @form_no  end           
            ,l.tags_page
            ,l.vendnum
            ,l.vendprodnum
            ,l.lbldesc
            ,l.casepack
            ,l.freeformsz
            ,l.dept
            ,l.deptcd
            ,l.prcmult
            ,l.price
            ,l.cpm
            ,l.regprcmult
            ,l.regprice
            ,l.mult_upc
            ,l.aisle
            ,l.savings
            ,l.savemsg
            ,l.groupnum
            ,l.categorynum
            ,l.batch
            ,l.branddesc
            ,l.brandsz
            ,l.unitprice
            ,UPPER(l.shortdesc)
            ,l.ea
            ,l.limit
            ,l.limitdesc
            ,l.eap
            ,l.mixmdesc
            ,l.upcbar
            ,l.advmsg
            ,l.upricemsg
            ,l.eventcd
            ,l.specdesc1
            ,l.SPECDESC2
            ,l.SPECDESC3
            ,l.SPECDESC4
            ,l.MUSTBUY
            ,l.reglbl
            ,l.loen
            ,l.sku
            ,l.qtyprice
            ,l.pcflag
            ,l.prctyp
            ,l.rptcode
            ,l.colordesc
            ,l.vendnm
            ,l.proefffrom
            ,l.glutenfreeflg
            ,l.savings1
            ,l.unitprice1
            ,l.mustbuy1 FROM @LABEL l;
    END;
GO

