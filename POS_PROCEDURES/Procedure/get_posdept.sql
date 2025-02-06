USE [POS]
GO

/****** Object:  UserDefinedFunction [dbo].[get_posdept]    Script Date: 2/5/2025 11:28:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[get_posdept]
(@p_stornum  NUMERIC, @p_subdept NUMERIC)
    RETURNS NUMERIC
    AS
BEGIN
DECLARE
	    @l_subdept  NUMERIC(4),
        @l_posdept  NUMERIC(4,2);

      
		(SELECT @l_posdept=SUBDEPTMAPPEDTO
		FROM ETL_POSDEPTSTORE
		WHERE STORNUM=@p_stornum
		AND SUBDEPTFROM =@p_subdept)

     --   IF @@ROWCOUNT=0
	 IF @l_posdept IS NULL
        BEGIN
           SET @l_subdept = @p_subdept;
        END
  
  
	select @l_posdept=posdept from ETL_POSDEPT where subdept=@l_subdept; 

	IF @p_subdept = 10
        BEGIN
            SET @l_posdept = 01;
        END;

        RETURN @l_posdept;
    END;
GO

