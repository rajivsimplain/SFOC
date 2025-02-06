USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[Get_LinkedItemCode_call_woseq]    Script Date: 2/5/2025 11:10:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Get_LinkedItemCode_call_woseq]
(
  --  @dept Numeric(10),
--    @type char(2) default='S',
    @itemin numeric(10),
    @coupontype char(2),
    @provalue numeric(15,4),
	@evtcode varchar(10),
	@stdt date,
	@enddt date,
	@catno numeric(5),
	@amulti numeric(5)
	
)

AS
BEGIN
    DECLARE
        @result numeric(18),
        @hdrid NUMERIC(18),
        @Lnkupc numeric(18),
        @dtlid Numeric(18);

--		delete from LINKED_ITM_hdr
    -- Get header ID for the department
	
	SET @Lnkupc=Null;
	 If @coupontype in ('Y','A','M') BEGIN
    SET @hdrid = (SELECT HdrID FROM dbo.LINKED_ITM_HDR 
	              WHERE FromDate=@stdt and ThruDate=@enddt and CouponType=@coupontype and EVTCODE=@evtcode and ItemsPerCpn=@amulti);-- and CategoryID=@catno); for complex we can add
	set @hdrid=isnull(@hdrid,0);

	--If coupon hdr matches 
	If @hdrid<>0
	Begin
	set @Lnkupc=(SELECT LnkdItmupc from dbo.LINKED_ITM_DTL WHERE HdrID=@hdrid and LnkdItmVal=@provalue);
	set @Lnkupc=isnull(@Lnkupc,-2);  --Create Detail;
	End;
	Else
	Begin
	set @Lnkupc=isnull(@Lnkupc,-1);  --Create Hdr and Detail;
	ENd;

	--PRINT @Lnkupc;

	IF @Lnkupc=-1 
	Begin
	set @hdrid=  (SELECT ((COUNT(isnull(HdrID,0) ) + 1) * (COUNT(isnull(HdrID,0)) + 2) / 2) - SUM(isnull(HdrID,0)) FROM LINKED_ITM_HDR)
	set @hdrid=isnull(@hdrid,1);
	--ISNULL((select max(hdrid) from LINKED_ITM_HDR),0)+1;
	set @dtlid= (SELECT ((COUNT(isnull(Dtlid,0) ) + 1) * (COUNT(isnull(DtlID,0)) + 2) / 2) - SUM(isnull(DtlID,0)) FROM LINKED_ITM_DTL)
	set @dtlid=isnull(@dtlid,1);
	--ISNULL((select max(Dtlid) from LINKED_ITM_DTL),0)+1;

	

	INSERT INTO LINKED_ITM_HDR(HdrID,Type,FromDate,ThruDate,CouponType,evtcode,CategoryID,CouponValue,ItemsPerCpn,CreatedDt,CreatedBy,ModifiedDt,ModifiedBy)
	 VALUES (@hdrid,'Simple',@stdt,@enddt,@coupontype,@evtcode,@catno,@provalue,@amulti,getdate(),'Simplain',getdate(),'Simplain')

	IF @coupontype in ('A','Y') BEGIN  --later remove 'Y'
	 SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '102%');
	 set @Lnkupc = isnull(@lnkupc,(SELECT GENCARDFROM FROM LINKED_ITM_SETUP WHERE ID=1));

	-- SELECT * FROM LINKED_ITM_SETUP
	
	-- set @Lnkupc=NEXT VALUE FOR CARDSEQ;

         IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN gencardfrom AND gencardthru ) = 'Y'   --card
            BEGIN
			INSERT INTO LINKED_ITM_DTL(DtlID,HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod) VALUES (@dtlid,@hdrid,
			(SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1)+@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
		--	 @Lnkupc-(SELECT cardfrom FROM LINKED_ITM_SETUP WHERE ID=1),
		     @Lnkupc ,
			 @provalue,7,4);              
             END
	END;
	IF @coupontype='M' BEGIN  --paper

		 SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '8%');
	     set @Lnkupc = isnull(@lnkupc,(SELECT genpaperfrom FROM LINKED_ITM_SETUP WHERE ID=1));

	  
	  --set @Lnkupc=NEXT VALUE FOR PAPERSEQ;

	  -- PRINT @lnkupc
			 IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN genpaperfrom AND genpaperthru  ) = 'Y' --paper
            BEGIN
			INSERT INTO LINKED_ITM_DTL(DtlID,HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod) VALUES (@dtlid,@hdrid,
			@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
			-- @Lnkupc-(SELECT paperfrom FROM LINKED_ITM_SETUP WHERE ID=1),			 
			@Lnkupc,
			 @provalue,7,4);              
            END
   END;
   END

    IF @Lnkupc=-2  --Create Detail only
	BEGIN
	   set @dtlid=(SELECT ((COUNT(isnull(Dtlid,0) ) + 1) * (COUNT(isnull(DtlID,0)) + 2) / 2) - SUM(isnull(DtlID,0)) FROM LINKED_ITM_DTL);
	   --ISNULL((select max(Dtlid) from LINKED_ITM_DTL),0)+1;

     IF @coupontype IN ('A','Y') BEGIN  --LATER REMOVE Y
	-- SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '102%' );      
	
	 --set @Lnkupc=NEXT VALUE FOR CARDSEQ;

	 	 SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '102%');
	     set @Lnkupc = isnull(@lnkupc,(SELECT gencardfrom FROM LINKED_ITM_SETUP WHERE ID=1));


	-- PRINT @Lnkupc;

         IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN gencardfrom AND gencardthru ) = 'Y'   --card
            BEGIN
			INSERT INTO LINKED_ITM_DTL(DtlID,HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod) VALUES (@dtlid,@hdrid,
			convert(numeric,(SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1))+@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
			-- @Lnkupc-convert(numeric,(SELECT cardfrom FROM LINKED_ITM_SETUP WHERE ID=1)),
			 @Lnkupc,
			 @provalue,7,4);              
             END
	END;
	IF @coupontype='M' BEGIN  --paper
	  -- set @Lnkupc=NEXT VALUE FOR PAPERSEQ;
	  	 SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '8%');
	     set @Lnkupc = isnull(@lnkupc,(SELECT genpaperfrom FROM LINKED_ITM_SETUP WHERE ID=1));


	  -- print @Lnkupc
			 IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN genpaperfrom AND genpaperthru ) = 'Y' --paper
            BEGIN
			INSERT INTO LINKED_ITM_DTL(DtlID,HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod) VALUES (@dtlid,@hdrid,
			@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
			-- @Lnkupc-(SELECT paperfrom FROM LINKED_ITM_SETUP WHERE ID=1),
			@Lnkupc,
			 @provalue,7,4);              
            END
   END;
  END
  END;
--	set @result=@Lnkupc;
RETURN @Lnkupc;

END;
GO

