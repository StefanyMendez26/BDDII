-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE SeleccionarClientes
    @Filtro NVARCHAR(100) = NULL
AS
BEGIN
    IF @Filtro IS NULL OR @Filtro = ''
    BEGIN
        SELECT * FROM Clientes;
    END
    ELSE
    BEGIN
        SELECT * FROM Clientes
        WHERE NombresCliente LIKE '%' + @Filtro + '%' OR ApellidosCliente LIKE '%' + @Filtro + '%';
    END
END
GO
