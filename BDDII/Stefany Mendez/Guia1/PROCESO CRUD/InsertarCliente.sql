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
CREATE PROCEDURE InsertarCliente
    @NombresCliente NVARCHAR(100),
    @ApellidosCliente NVARCHAR(100),
    @DuiCliente NVARCHAR(20),
    @TelefonoCliente NVARCHAR(15),
    @CorreoCliente NVARCHAR(100),
    @IdDireccion INT
AS
BEGIN
    INSERT INTO Clientes (NombresCliente, ApellidosCliente, DuiCliente, TelefonoCliente, CorreoCliente, IdDireccion)
    VALUES (@NombresCliente, @ApellidosCliente, @DuiCliente, @TelefonoCliente, @CorreoCliente, @IdDireccion);
END
GO
