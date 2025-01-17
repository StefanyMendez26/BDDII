USE [Zapateria]
GO
/****** Object:  UserDefinedFunction [dbo].[CalcularEdad]    Script Date: 14/10/2024 10:21:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CalcularEdad]
(
    @FechaNacimiento DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Edad INT;
    SET @Edad = DATEDIFF(YEAR, @FechaNacimiento, GETDATE()) - 
                CASE 
                    WHEN MONTH(@FechaNacimiento) > MONTH(GETDATE()) OR 
                         (MONTH(@FechaNacimiento) = MONTH(GETDATE()) AND DAY(@FechaNacimiento) > DAY(GETDATE())) 
                    THEN 1 
                    ELSE 0 
                END;
    RETURN @Edad;
END
