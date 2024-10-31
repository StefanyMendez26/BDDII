-- Trigger 1: Controlar Disponibilidad de Productos
CREATE TRIGGER Controlar_Disponibilidad_Producto
ON detalles_de_ventas
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @cantidad_disponible INT;
    DECLARE @id_zapato INT;
    DECLARE @cantidad_vendida INT;
    DECLARE @id_detalle INT;
    DECLARE @sub_total FLOAT;
    DECLARE @id_venta INT;

    SELECT @id_zapato = IdZapato, 
           @cantidad_vendida = Cantidad,
           @id_detalle = IdDetalleVenta,
           @sub_total = SubTotal,
           @id_venta = IdVenta
    FROM inserted;

    SELECT @cantidad_disponible = Stock
    FROM zapatos
    WHERE IdZapato = @id_zapato;
    
    IF @cantidad_disponible < @cantidad_vendida
    BEGIN
        RAISERROR('Stock insuficiente para realizar la venta.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        INSERT INTO detalles_de_ventas (IdDetalleVenta, IdZapato, Cantidad, SubTotal, IdVenta)
        VALUES (@id_detalle, @id_zapato, @cantidad_vendida, @sub_total, @id_venta);
        
        UPDATE zapatos
        SET Stock = Stock - @cantidad_vendida
        WHERE IdZapato = @id_zapato;
    END
END;

-- Trigger 2: Prevenir Actualización de Factura Completa
CREATE TRIGGER Prevenir_Actualizacion_Factura_Completa
ON Factura_De_Ventas
INSTEAD OF UPDATE
AS
BEGIN
    DECLARE @total_a_pagar DECIMAL(10, 2);
    DECLARE @id_factura INT;
    DECLARE @fecha_factura DATE;
    
    SELECT @total_a_pagar = TotalPagarVenta, 
           @id_factura = IdFacturaVenta, 
           @fecha_factura = Fecha_Factura_Venta 
    FROM inserted;
    
    IF @total_a_pagar = 0
    BEGIN
        RAISERROR('No se puede actualizar una factura que ya está completada.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        UPDATE Factura_De_Ventas
        SET Fecha_Factura_Venta = @fecha_factura, TotalPagarVenta = @total_a_pagar
        WHERE IdFacturaVenta = @id_factura;
    END
END;

-- Trigger 3: Validar Edad del Cliente
CREATE TRIGGER Validar_Edad_Cliente
ON clientes
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @edad INT;
    DECLARE @id_cliente INT;
    DECLARE @nombres_cliente VARCHAR(50);
    DECLARE @apellidos_cliente VARCHAR(50);
    DECLARE @dui_cliente VARCHAR(9);
    
    SELECT @edad = Edad, 
           @id_cliente = IdCliente, 
           @nombres_cliente = NombresCliente, 
           @apellidos_cliente = ApellidosCliente, 
           @dui_cliente = DuiCliente 
    FROM inserted;
    
    IF @edad < 18
    BEGIN
        RAISERROR('El cliente debe ser mayor de 18 años.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        INSERT INTO clientes (IdCliente, NombresCliente, ApellidosCliente, DuiCliente, Edad)
        VALUES (@id_cliente, @nombres_cliente, @apellidos_cliente, @dui_cliente, @edad);
    END
END;

-- Trigger 4: Prevenir Eliminación de Productos Asignados
CREATE TRIGGER Prevenir_Eliminacion_Producto_Asignado
ON Zapatos
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @id_zapato INT;
    DECLARE @num_asignaciones INT;

    SELECT @id_zapato = IdZapato 
    FROM deleted;
    
    SELECT @num_asignaciones = COUNT(*)
    FROM Detalles_De_Ventas
    WHERE IdZapato = @id_zapato;
    
    IF @num_asignaciones > 0
    BEGIN
        RAISERROR('No se puede eliminar un producto que ya está asignado.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Zapatos WHERE IdZapato = @id_zapato;
    END
END;

-- Trigger 5: Prevenir Actualización de Precios en Productos Antiguos
CREATE TRIGGER Prevenir_Actualizacion_Precio_Producto_Antiguo
ON zapatos
INSTEAD OF UPDATE
AS
BEGIN
    DECLARE @dias_en_sistema INT;
    DECLARE @id_zapato INT;
    DECLARE @precio FLOAT;

    SELECT @id_zapato = IdZapato, 
           @precio = Precio 
    FROM inserted;
    
    SET @dias_en_sistema = DATEDIFF(DAY, (SELECT FechaRegistro FROM zapatos WHERE IdZapato = @id_zapato), GETDATE());
    
    IF @dias_en_sistema > 30
    BEGIN
        RAISERROR('No se puede actualizar el precio de un producto con más de 30 días en el sistema.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        UPDATE zapatos SET Precio = @precio WHERE IdZapato = @id_zapato;
    END
END;

-- After Trigger


-- Trigger 1: Registrar Historial de Cambios en los Precios
CREATE TRIGGER Registrar_Historial_Cambios_Precio
ON zapatos
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Precio)
    BEGIN
        DECLARE @id_zapato INT;
        DECLARE @precio_anterior FLOAT;
        DECLARE @precio_nuevo FLOAT;
        DECLARE @fecha_cambio DATETIME;

        SELECT @id_zapato = IdZapato, 
               @precio_anterior = deleted.Precio, 
               @precio_nuevo = inserted.Precio, 
               @fecha_cambio = GETDATE()
        FROM inserted
        INNER JOIN deleted ON inserted.IdZapato = deleted.IdZapato;

        INSERT INTO historial_cambios_precio (IdZapato, PrecioAnterior, PrecioNuevo, FechaCambio)
        VALUES (@id_zapato, @precio_anterior, @precio_nuevo, @fecha_cambio);
    END
END;

-- Trigger 2: Registrar Fecha de Última Visita del Cliente
CREATE TRIGGER Registrar_Fecha_Ultima_Visita_Cliente
ON clientes
AFTER UPDATE
AS
BEGIN
    DECLARE @id_cliente INT;
    DECLARE @fecha_ultima_visita DATETIME;

    SELECT @id_cliente = IdCliente, 
           @fecha_ultima_visita = GETDATE()
    FROM inserted;

    UPDATE clientes
    SET FechaUltimaVisita = @fecha_ultima_visita
    WHERE IdCliente = @id_cliente;
END;

-- Trigger 3: Actualizar Stock Después de una Venta
CREATE TRIGGER Actualizar_Stock_Despues_Venta
ON detalles_de_ventas
AFTER INSERT
AS
BEGIN
    DECLARE @id_zapato INT;
    DECLARE @cantidad_vendida INT;
    DECLARE @fecha_venta DATETIME;

    SELECT @id_zapato = IdZapato, 
           @cantidad_vendida = Cantidad, 
           @fecha_venta = GETDATE()
    FROM inserted;

    UPDATE zapatos
    SET Stock = Stock - @cantidad_vendida, FechaUltimaVenta = @fecha_venta
    WHERE IdZapato = @id_zapato;
END;

-- Trigger 4: Registrar Cambios en Información del Cliente
CREATE TRIGGER Registrar_Cambios_Informacion_Cliente
ON clientes
AFTER UPDATE
AS
BEGIN
    DECLARE @id_cliente INT;
    DECLARE @nombre_cliente VARCHAR(50);
    DECLARE @direccion_cliente VARCHAR(100);
    DECLARE @telefono_cliente VARCHAR(15);
    DECLARE @fecha_cambio DATETIME;

    SELECT @id_cliente = IdCliente, 
           @nombre_cliente = inserted.NombresCliente, 
           @direccion_cliente = inserted.DireccionCliente, 
           @telefono_cliente = inserted.TelefonoCliente, 
           @fecha_cambio = GETDATE()
    FROM inserted;

    INSERT INTO auditoria_cambios_cliente (IdCliente, NombreCliente, DireccionCliente, TelefonoCliente, FechaCambio)
    VALUES (@id_cliente, @nombre_cliente, @direccion_cliente, @telefono_cliente, @fecha_cambio);
END;

-- Trigger 5: Actualizar Total de Factura Después de Insertar Detalle
CREATE TRIGGER Actualizar_Total_Factura
ON detalles_de_factura
AFTER INSERT
AS
BEGIN
    DECLARE @id_factura INT;
    DECLARE @nuevo_total FLOAT;

    SELECT @id_factura = IdFactura
    FROM inserted;

    SELECT @nuevo_total = SUM(SubTotal)
    FROM detalles_de_factura
    WHERE IdFactura = @id_factura;

    UPDATE factura_de_ventas
    SET TotalPagarVenta = @nuevo_total
    WHERE IdFacturaVenta = @id_factura;
END;
