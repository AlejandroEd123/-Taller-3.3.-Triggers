USE pubs;
GO

-- ========================================================================
-- 1. CREACIÓN DE LA TABLA DE AUDITORÍA
-- ========================================================================
-- Esta tabla registrará los movimientos automáticos generados por los triggers.
IF OBJECT_ID('dbo.Auditoria_Pubs', 'U') IS NOT NULL
    DROP TABLE dbo.Auditoria_Pubs;
GO

CREATE TABLE dbo.Auditoria_Pubs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TablaAfectada VARCHAR(50) NOT NULL,
    Accion VARCHAR(20) NOT NULL,
    Usuario VARCHAR(50) NOT NULL,
    Fecha DATETIME DEFAULT GETDATE(),
    Detalle VARCHAR(MAX) NOT NULL
);
GO


-- ========================================================================
-- 2. TRIGGER 1: AUDITORÍA DE CAMBIO DE PRECIOS (Tabla: titles)
-- ========================================================================
-- Borramos si ya existe para evitar el error 2714
IF OBJECT_ID('trg_AuditarPrecioLibro', 'TR') IS NOT NULL
    DROP TRIGGER trg_AuditarPrecioLibro;
GO

CREATE TRIGGER trg_AuditarPrecioLibro
ON titles
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(price)
    BEGIN
        INSERT INTO Auditoria_Pubs (TablaAfectada, Accion, Usuario, Detalle)
        SELECT 
            'titles', 
            'UPDATE PRICE', 
            SYSTEM_USER,
            'Libro ID: ' + d.title_id + ' | Título: ' + d.title + ' | Precio Anterior: $' + CAST(ISNULL(d.price, 0) AS VARCHAR) + ' -> Precio Nuevo: $' + CAST(ISNULL(i.price, 0) AS VARCHAR)
        FROM deleted d
        INNER JOIN inserted i ON d.title_id = i.title_id;
    END
END;
GO


-- ========================================================================
-- 3. TRIGGER 2: CONTROL Y VALIDACIÓN DE VOLUMEN DE VENTAS (Tabla: sales)
-- ========================================================================
IF OBJECT_ID('trg_ValidarCantidadVenta', 'TR') IS NOT NULL
    DROP TRIGGER trg_ValidarCantidadVenta;
GO

CREATE TRIGGER trg_ValidarCantidadVenta
ON sales
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE qty > 100)
    BEGIN
        RAISERROR ('[ERROR] No se permiten ventas individuales mayores a 100 unidades sin autorización de la gerencia.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- ========================================================================
-- 4. TRIGGER 3: ACTUALIZACIÓN AUTOMÁTICA DE VENTAS ANUALES (Tabla: sales)
-- ========================================================================
IF OBJECT_ID('trg_ActualizarYTD', 'TR') IS NOT NULL
    DROP TRIGGER trg_ActualizarYTD;
GO

CREATE TRIGGER trg_ActualizarYTD
ON sales
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE titles
    SET ytd_sales = ISNULL(ytd_sales, 0) + i.qty
    FROM titles t
    INNER JOIN inserted i ON t.title_id = i.title_id;
END;
GO


-- ========================================================================
-- 5. TRIGGER 4: PROTECCIÓN DE AUTORES CON CONTRATO ACTIVO (Tabla: authors)
-- ========================================================================
IF OBJECT_ID('trg_ProtegerAutoresActivos', 'TR') IS NOT NULL
    DROP TRIGGER trg_ProtegerAutoresActivos;
GO

CREATE TRIGGER trg_ProtegerAutoresActivos
ON authors
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM deleted WHERE contract = 1)
    BEGIN
        RAISERROR ('[ERROR] Restricción de Integridad: No se puede eliminar un autor que tiene un contrato activo vigente.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- ========================================================================
-- 6. TRIGGER 5: REGISTRO DE AUDITORÍA DE NUEVOS EMPLEADOS (Tabla: employee)
-- ========================================================================
IF OBJECT_ID('trg_LogNuevoEmpleado', 'TR') IS NOT NULL
    DROP TRIGGER trg_LogNuevoEmpleado;
GO

CREATE TRIGGER trg_LogNuevoEmpleado
ON employee
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria_Pubs (TablaAfectada, Accion, Usuario, Detalle)
    SELECT 
        'employee', 
        'INSERT', 
        SYSTEM_USER,
        'Nuevo empleado contratado -> ID: ' + i.emp_id + ' | Nombre: ' + i.fname + ' ' + i.lname + ' | Inicial: ' + ISNULL(i.minit, '-') + ' | Trabajo ID: ' + CAST(i.job_id AS VARCHAR)
    FROM inserted i;
END;
GO


-- ========================================================================
-- 7. SCRIPTS DE PRUEBA (Ejecuta cada bloque por separado para tus capturas)
-- ========================================================================

/*
-- PRUEBA TRIGGER 1:
UPDATE titles SET price = 29.99 WHERE title_id = 'BU1032';
SELECT * FROM Auditoria_Pubs WHERE Accion = 'UPDATE PRICE';
*/

/*
-- PRUEBA TRIGGER 2:
INSERT INTO sales (stor_id, ord_num, ord_date, qty, payterms, title_id)
VALUES ('7066', 'TEST_ALTA', GETDATE(), 150, 'Net 60', 'BU1032');
*/

/*
-- PRUEBA TRIGGER 3:
SELECT title_id, ytd_sales FROM titles WHERE title_id = 'BU1111';
INSERT INTO sales (stor_id, ord_num, ord_date, qty, payterms, title_id)
VALUES ('7066', 'VENTA_OK', GETDATE(), 50, 'Net 60', 'BU1111');
SELECT title_id, ytd_sales FROM titles WHERE title_id = 'BU1111';
*/

/*
-- PRUEBA TRIGGER 4 (CORREGIDA):
-- Creamos autor de prueba con contrato (1) sin llaves foráneas asignadas
INSERT INTO authors (au_id, au_lname, au_fname, phone, contract)
VALUES ('999-99-9999', 'Perez', 'Juan', '123 456-7890', 1);

-- Intentamos borrarlo para forzar la respuesta de NUESTRO trigger
DELETE FROM authors WHERE au_id = '999-99-9999';
*/

/*
-- PRUEBA TRIGGER 5 (CORREGIDA):
-- Nivel de trabajo en 150 para que no choque con las reglas internas de la BD
INSERT INTO employee (emp_id, fname, minit, lname, job_id, job_lvl, pub_id, hire_date)
VALUES ('Z-A12345M', 'Carlos', 'A', 'Mendoza', 5, 150, '1389', GETDATE());

SELECT * FROM Auditoria_Pubs WHERE Accion = 'INSERT';
*/
