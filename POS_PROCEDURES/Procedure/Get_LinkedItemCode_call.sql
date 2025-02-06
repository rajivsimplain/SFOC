USE [POS]
GO

/****** Object:  StoredProcedure [dbo].[Get_LinkedItemCode_call]    Script Date: 2/5/2025 11:10:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Get_LinkedItemCode_call]
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
	
	SET @Lnkupc=0;

	--PRINT 'START'
	--PRINT @coupontype
	 If @coupontype in ('Y','A','M','N') BEGIN
	 --PRINT 'CCCC'
    SET @hdrid = (SELECT HdrID FROM dbo.LINKED_ITM_HDR 
	              WHERE FromDate=@stdt and ThruDate=@enddt and CouponType=@coupontype and EVTCODE=@evtcode and ItemsPerCpn=@amulti and CategoryID=@catno
				   AND CouponValue=@provalue); 
	set @hdrid=isnull(@hdrid,0);
	--PRINT 'HDRID'
	--PRINT @hdrid
	--If coupon hdr matches 
/*
	If @hdri<>0
	Begin
	set @Lnkupc=(SELECT LnkdItmupc from dbo.LINKED_ITM_DTL WHERE HdrID=@hdrid and LnkdItmVal=@provalue);
	set @Lnkupc=isnull(@Lnkupc,-2);  --Create Detail;
	End;
	Else
	Begin
	set @Lnkupc=isnull(@Lnkupc,-1);  --Create Hdr and Detail;
	ENd;*/

	IF @hdrid=0 
	set @Lnkupc=-1;

	--PRINT @Lnkupc;

	IF @Lnkupc=-1 
	Begin
	/*set @hdrid=  (SELECT ((COUNT(isnull(HdrID,0) ) + 1) * (COUNT(isnull(HdrID,0)) + 2) / 2) - SUM(isnull(HdrID,0)) FROM LINKED_ITM_HDR)
	set @hdrid=isnull(@hdrid,1);
	
	set @dtlid= (SELECT ((COUNT(isnull(Dtlid,0) ) + 1) * (COUNT(isnull(DtlID,0)) + 2) / 2) - SUM(isnull(DtlID,0)) FROM LINKED_ITM_DTL)
	set @dtlid=isnull(@dtlid,1);
	*/
	--PRINT '-1'
	

	INSERT INTO LINKED_ITM_HDR(Type,FromDate,ThruDate,CouponType,evtcode,CategoryID,CouponValue,ItemsPerCpn,CreatedDt,CreatedBy,ModifiedDt,ModifiedBy)
	 VALUES ('Simple',@stdt,@enddt,@coupontype,@evtcode,@catno,@provalue,@amulti,getdate(),'Simplain',getdate(),'Simplain');

	 
	SET @HDRID=( Select IDENT_CURRENT('LINKED_ITM_HDR'));

	IF @coupontype in ('A','Y','M') BEGIN  --later remove 'Y'
	-- SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '102%');
	 --set @Lnkupc =(select max(promocode)+1 from LINKED_ITM_DTL where LnkdItmupc like '102%');
	-- set @Lnkupc = isnull(@lnkupc,1);

	-- SELECT * FROM LINKED_ITM_SETUP
	
	 set @Lnkupc=NEXT VALUE FOR PROMOID_CARD_SEQ;

         IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN gencardfrom AND gencardthru ) = 'Y'   --card
            BEGIN
			INSERT INTO LINKED_ITM_DTL(HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod,ItemsPerCpn) VALUES (@hdrid,
			(SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1)+@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
	      	 @Lnkupc-convert(numeric,(SELECT cardfrom FROM LINKED_ITM_SETUP WHERE ID=1)),
			 @provalue,7,4,@amulti);              
             END
	END;
	IF @coupontype NOT IN ('A','Y') BEGIN  --paper

		  
	  set @Lnkupc=NEXT VALUE FOR PROMOID_NONCARD_SEQ;

	  -- --PRINT @lnkupc
			 IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN genpaperfrom AND genpaperthru  ) = 'Y' --paper
            BEGIN
			INSERT INTO LINKED_ITM_DTL(HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod,ItemsPerCpn) VALUES (@hdrid,
			@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
			 @Lnkupc-(SELECT paperfrom FROM LINKED_ITM_SETUP WHERE ID=1),			 
			--@Lnkupc,
			 @provalue,7,4,@amulti);              
            END
   END;
   END

    IF @Lnkupc=-2  --Create Detail only
	BEGIN
/*	   set @dtlid=(SELECT ((COUNT(isnull(Dtlid,0) ) + 1) * (COUNT(isnull(DtlID,0)) + 2) / 2) - SUM(isnull(DtlID,0)) FROM LINKED_ITM_DTL);
	   set @dtlid=isnull(@dtlid,1);*/
	   --ISNULL((select max(Dtlid) from LINKED_ITM_DTL),0)+1;

     IF @coupontype IN ('A','Y') BEGIN  --LATER REMOVE Y

	-- --PRINT '-2'
		
	 set @Lnkupc=NEXT VALUE FOR PROMOID_CARD_SEQ;

	 	-- SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '102%');
	    -- set @Lnkupc = isnull(@lnkupc,1);


	 --PRINT @Lnkupc;

         IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN gencardfrom AND gencardthru ) = 'Y'   --card
            BEGIN
			INSERT INTO LINKED_ITM_DTL(HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod,ItemsPerCpn) VALUES (@hdrid,
			convert(numeric,(SELECT cardoffset FROM LINKED_ITM_SETUP WHERE ID=1))+@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
			 @Lnkupc-convert(numeric,(SELECT cardfrom FROM LINKED_ITM_SETUP WHERE ID=1)),
			-- @Lnkupc,
			 @provalue,7,4,@amulti);    
			 --PRINT 'DONE'
             END
	END;
	IF @coupontype='M' BEGIN  --paper
	  set @Lnkupc=NEXT VALUE FOR PROMOID_NONCARD_SEQ;
	  	-- SET @Lnkupc = (SELECT ((COUNT(PromoCode) + 1) * (COUNT(PromoCode) + 2) / 2) - SUM(PromoCode) FROM Linked_itm_Dtl WHERE LnkdItmupc like '8%');
	    -- set @Lnkupc = isnull(@lnkupc,1);


	  -- --PRINT @Lnkupc
			 IF (SELECT 'Y' FROM dbo.LINKED_ITM_SETUP WHERE @Lnkupc BETWEEN genpaperfrom AND genpaperthru ) = 'Y' --paper
            BEGIN
			INSERT INTO LINKED_ITM_DTL(HdrID,LnkdItmupc,LnkdItmDesc,PromoCode,LnkdItmVal,LnkdItmTyp,PriceMethod,ItemsPerCpn) VALUES (@hdrid,
			@Lnkupc,
			(SELECT promoposdesc FROM LINKED_ITM_SETUP WHERE ID=1),
			 @Lnkupc-(SELECT paperfrom FROM LINKED_ITM_SETUP WHERE ID=1),
			--@Lnkupc,
			 @provalue,7,4,@amulti);              
            END
   END;
  END
  END;
--	set @result=@Lnkupc;
RETURN @Lnkupc;

END;
GO

