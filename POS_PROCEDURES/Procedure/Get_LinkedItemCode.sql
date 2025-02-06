USE [POS]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_LinkedItemCode]    Script Date: 2/5/2025 11:28:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[Get_LinkedItemCode]
(
    @itemin numeric(10),
    @coupontype char(2),
    @provalue numeric(15,4),
	@evtcode varchar(10),
	@stdt date,
	@enddt date,	
	@amulti numeric(5),
	@catno numeric(5)
)
RETURNS NUMERIC
AS
BEGIN
    DECLARE
        @result NUMERIC(18),
        @hdrid int,
        @Lnkupc numeric(18),
        @dtlcnt int;

	--	SET @result=NULL;
	
--	if @coupontype in ('A','Y','M') BEGIN 
--		select * from LINKED_ITM_dtl
    -- Get header ID for the department

    SET @hdrid = (SELECT HdrID FROM dbo.LINKED_ITM_HDR 
	              WHERE CouponValue=@provalue AND FromDate=@stdt and ThruDate=@enddt and  EVTCODE=@evtcode and CouponType=@coupontype and ItemsPerCpn=@amulti  and
				  CategoryID=@catno);

	set @hdrid=isnull(@hdrid,0);

	--If coupon hdr matches 
	If @hdrid<>0
	Begin
	set @Lnkupc=(SELECT LnkdItmupc from dbo.LINKED_ITM_DTL WHERE HdrID=@hdrid );--and LnkdItmVal=@provalue);
	set @Lnkupc=isnull(@Lnkupc,NULL);  --Create Detail;
	End;
	Else
	Begin
	set @Lnkupc=isnull(@Lnkupc,NULL);  --Create Hdr and Detail;
	ENd;

	set @result=@Lnkupc;
	--END;

    RETURN @result;
END;
GO

