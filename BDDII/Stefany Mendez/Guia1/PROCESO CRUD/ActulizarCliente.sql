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
CREATE PROCEDURE sp_ActualizarCliente
    @IdCliente INT,
    @NombresCliente NVARCHAR(100),
    @ApellidosCliente NVARCHAR(100),
    @DuiCliente NVARCHAR(20),
    @TelefonoCliente NVARCHAR(15),
    @CorreoCliente NVARCHAR(100),
    @IdDireccion INT
AS
BEGIN
    UPDATE Clientes
    SET NombresCliente = @NombresCliente,
        ApellidosCliente = @ApellidosCliente,
        DuiCliente = @DuiCliente,
        TelefonoCliente = @TelefonoCliente,
        CorreoCliente = @CorreoCliente,
        IdDireccion = @IdDireccion
    WHERE IdCliente = @IdCliente;
END
GO

