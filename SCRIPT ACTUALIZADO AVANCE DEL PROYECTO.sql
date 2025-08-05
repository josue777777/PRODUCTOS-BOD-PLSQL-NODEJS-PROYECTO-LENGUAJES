-- Creacion de Usuarios Proyecto G5 Almacen Bodega Central
-- Se deben de correr en sys o system

-- creando usuario de operaciones
create user oper_tablas identified by oper_tablas
default tablespace users 
temporary tablespace temp
quota unlimited on users;

-- otorgando privilegios de sistema
grant create session, create table to oper_tablas;


-- creando usuario almacen
create user alm_tablas identified by alm_tablas
default tablespace users 
temporary tablespace temp
quota unlimited on users;

-- otorgando privilegios de sistema
grant create session, create table to alm_tablas;

-- creando usuario de inventario
create user inv_tablas identified by inv_tablas
default tablespace users 
temporary tablespace temp
quota unlimited on users;

-- otorgando privilegios de sistema
grant create session, create table to inv_tablas;

-- Revisar diccionario de datos
select username, default_tablespace, temporary_tablespace
from dba_users
where username like '%TABLAS';

select  *
from dba_ts_quotas
where username like '%TABLAS';

select *
from dba_sys_privs
where grantee like '%TABLAS';

select owner, object_name, object_type
from dba_objects
where owner like '%TABLAS'
order by 1,3,2;

select *
from dba_tab_privs
where grantee like '%TABLAS';


-- Creando tablas en los usuarios, se deben de correr en el orden siguiente en sus respectivas conexiones

-- Creando tablas dentro de alm_tablas

-- Tabla de estados
CREATE TABLE estado_tb(
    id_estado NUMBER(2) CONSTRAINT pk_estado_tb PRIMARY KEY,
    nombre_estado VARCHAR2(30)
);

-- Sucursales físicas
CREATE TABLE sucursal_tb(
    id_sucursal NUMBER CONSTRAINT pk_sucursal_tb PRIMARY KEY,
    nombre_sucursal VARCHAR2(100)
);

-- Departamentos (áreas que solicitan productos)
CREATE TABLE departamentos_tb(
    id_departamento NUMBER CONSTRAINT pk_departamentos_tb PRIMARY KEY,
    nombre_departamento VARCHAR2(100),
    id_sucursal NUMBER CONSTRAINT fk1_departamentos_tb REFERENCES sucursal_tb
);

-- Almacenes donde se guardan productos
CREATE TABLE almacen_tb(
    id_almacen NUMBER CONSTRAINT pk_almacen_tb PRIMARY KEY,
    nombre_almacen VARCHAR2(100),
    id_sucursal NUMBER CONSTRAINT fk1_almacen_tb REFERENCES sucursal_tb,
    id_estado NUMBER(2)CONSTRAINT fk2_almacen_tb REFERENCES estado_tb
);

-- Grants a otros módulos
GRANT REFERENCES ON departamentos_tb TO oper_tablas;
GRANT REFERENCES ON almacen_tb TO inv_tablas;
GRANT REFERENCES ON estado_tb TO inv_tablas;

-- Creando tablas dentro de inv_tablas

CREATE TABLE unidad_medida_tb(
    id_unidad_medida NUMBER  CONSTRAINT pk_unidad_medida_tb PRIMARY KEY,
    nombre VARCHAR2(30)
);

-- Productos (catálogo)
CREATE TABLE producto_tb(
    id_producto NUMBER CONSTRAINT pk_producto_tb  PRIMARY KEY,
    nombre_producto VARCHAR2(100),
    descripcion VARCHAR2(4000),
    precio_unitario NUMBER(10,2),
    id_unidad_medida NUMBER CONSTRAINT fk1_producto_tb REFERENCES unidad_medida_tb,
    id_estado NUMBER(2) CONSTRAINT fk2_producto_tb REFERENCES alm_tablas.estado_tb
);

-- Lotes y fechas de vencimiento
CREATE TABLE lote_tb(
    id_lote NUMBER CONSTRAINT pk_lote_tb PRIMARY KEY,
    id_producto NUMBER CONSTRAINT fk1_lote_tb REFERENCES producto_tb,
    fecha_vencimiento DATE
);

-- Inventario disponible por almacén
CREATE TABLE inventario_tb(
    id_inventario NUMBER CONSTRAINT pk_inventario_tb PRIMARY KEY,
    id_producto NUMBER CONSTRAINT fk1_inventario_tb REFERENCES producto_tb,
    id_almacen NUMBER CONSTRAINT fk2_inventario_tb REFERENCES alm_tablas.almacen_tb,
    cantidad_disponible NUMBER,
    stock_minimo NUMBER,
    stock_maximo NUMBER,
    id_estado NUMBER(2) CONSTRAINT fk3_inventario_tb REFERENCES alm_tablas.estado_tb
);

-- Grants para Operaciones
GRANT REFERENCES ON inventario_tb TO oper_tablas;
GRANT REFERENCES ON producto_tb   TO oper_tablas;

-- Creando tablas dentro de oper_tablas

CREATE TABLE usuario_tb(
    id_usuario  NUMBER CONSTRAINT pk_usuario_tb PRIMARY KEY,
    nombre_completo VARCHAR2(100),
    username VARCHAR2(50),
    pass VARCHAR2(100),
    rol VARCHAR2(20),
    activo NUMBER(1)
);

-- Facturas internas
CREATE TABLE factura_tb(
    id_factura NUMBER  CONSTRAINT pk_factura_tb PRIMARY KEY,
    fecha DATE,
    monto_total NUMBER(10,2)
);

-- Solicitudes de productos que hacen los departamentos
CREATE TABLE solicitud_tb(
    id_solicitud NUMBER  CONSTRAINT pk_solicitud_tb PRIMARY KEY,
    fecha DATE,
    id_departamento NUMBER  CONSTRAINT fk1_solicitud_tb REFERENCES alm_tablas.departamentos_tb,
    id_factura NUMBER CONSTRAINT fk2_solicitud_tb REFERENCES factura_tb,
    id_usuario NUMBER CONSTRAINT fk3_solicitud_tb REFERENCES usuario_tb
);

-- Detalle por ítem solicitado
CREATE TABLE detalle_solicitud_tb(
    id_detalle_solicitud NUMBER CONSTRAINT pk_detalle_solicitud_tb PRIMARY KEY,
    id_solicitud NUMBER CONSTRAINT fk1_detalle_solicitud_tb REFERENCES solicitud_tb,
    id_inventario NUMBER CONSTRAINT fk2_detalle_solicitud_tb REFERENCES inv_tablas.inventario_tb,
    cantidad_solicitada NUMBER,
    cantidad_entregada NUMBER
);












-------------------------------------------------------------------------------------------------------------------------------------------------DIVISION PROXIMO PASO DEL PROYECTO DESA PROYECTO Y USUARIO FINALES 






-- Se corre en sys o system

CREATE USER G5Desa01 IDENTIFIED BY G5Desa01
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP;

CREATE USER G5Desa02 IDENTIFIED BY G5Desa02
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP;

CREATE ROLE G5_ROL_DESA;

GRANT CREATE SESSION, CREATE PROCEDURE, CREATE ROLE, CREATE SEQUENCE, CREATE VIEW, CREATE TRIGGER 
TO G5_ROL_DESA;

GRANT G5_ROL_DESA TO G5Desa01;
GRANT G5_ROL_DESA TO G5Desa02;
GRANT G5_ROL_APP TO G5DESA01;

CREATE USER G5UF01 IDENTIFIED BY G5_UF01
TEMPORARY TABLESPACE TEMP;

CREATE ROLE G5_ROL_UF;

GRANT CREATE SESSION TO G5_ROL_UF;
GRANT G5_ROL_UF TO G5UF01;



--SELECT * FROM alm_tablas.estado_tb;
INSERT INTO alm_tablas.estado_tb (id_estado, nombre_estado)
VALUES (1, 'Activo');
COMMIT;
--SELECT * FROM inv_tablas.unidad_medida_tb;
INSERT INTO inv_tablas.unidad_medida_tb (id_unidad_medida, nombre)
VALUES (1, 'Unidad');
COMMIT;


--- Se ejecuta despues de crear el procedimiento en G5Desa01

CREATE ROLE G5_ROL_APP;

GRANT EXECUTE ON G5Desa01.G5_INSERTAR_PRODUCTO TO G5_ROL_APP;

GRANT G5_ROL_APP TO G5UF01;

-----------------------------------------------------
-- Se corre en inv_tablas

GRANT SELECT, INSERT, UPDATE, DELETE ON producto_tb TO G5Desa01;
GRANT SELECT ON producto_tb TO G5UF01;

------------------------------------------------------
-- Se corre en G5Desa01 (crear la conexion)

CREATE OR REPLACE PROCEDURE G5_INSERTAR_PRODUCTO(
    vIdProducto IN NUMBER,
    vNombreProducto IN VARCHAR2,
    vDescripcion IN VARCHAR2,
    vPrecioUnitario IN NUMBER,
    vIdUnidadMedida IN NUMBER,
    vIdEstado IN NUMBER
)
AS
BEGIN
    INSERT INTO inv_tablas.producto_tb (
        id_producto,
        nombre_producto,
        descripcion,
        precio_unitario,
        id_unidad_medida,
        id_estado
    )
    VALUES (
        vIdProducto,
        vNombreProducto,
        vDescripcion,
        vPrecioUnitario,
        vIdUnidadMedida,
        vIdEstado
    );
END;
/

BEGIN
    G5_INSERTAR_PRODUCTO(100, 'Ejemplo Producto', 'Descripcion de prueba', 1234.56, 1, 1);
END;

/

COMMIT;

SELECT * FROM inv_tablas.producto_tb WHERE id_producto = 100;

------------------------------------
-- Se corre en G5UF01

EXECUTE G5Desa01.G5_INSERTAR_PRODUCTO(101, 'Nuevo Producto', 'Creado por usuario final', 750.00, 1, 1);

COMMIT;

SELECT * FROM inv_tablas.producto_tb WHERE id_producto = 101;

-------------------------------------------
-- Consultas

SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username LIKE 'INV_TABLAS' 
   OR username LIKE 'ALM_TABLAS'
   OR username LIKE 'OPER_TABLAS'
   OR username LIKE 'G5DESA01' 
   OR username LIKE 'G5DESA02' 
   OR username LIKE 'G5UF01'
ORDER BY 1;



SELECT *
FROM dba_ts_quotas
WHERE username LIKE 'INV_TABLAS' 
   OR username LIKE 'ALM_TABLAS'
   OR username LIKE 'OPER_TABLAS'
   OR username LIKE 'G5DESA01' 
   OR username LIKE 'G5DESA02' 
   OR username LIKE 'G5UF01'
ORDER BY 1;


SELECT owner, object_name, object_type
FROM dba_objects
WHERE owner LIKE 'INV_TABLAS' 
   OR owner LIKE 'ALM_TABLAS'
   OR owner LIKE 'OPER_TABLAS'
   OR owner LIKE 'G5DESA01' 
   OR owner LIKE 'G5DESA02' 
   OR owner LIKE 'G5UF01'
ORDER BY 1, 3;


SELECT *
FROM dba_sys_privs
WHERE grantee LIKE 'INV_TABLAS' 
   OR grantee LIKE 'ALM_TABLAS'
   OR grantee LIKE 'OPER_TABLAS'
   OR grantee LIKE 'G5DESA01' 
   OR grantee LIKE 'G5DESA02' 
   OR grantee LIKE 'G5UF01' 
   OR grantee LIKE 'G5_ROL%'
ORDER BY 1;


SELECT *
FROM dba_tab_privs
WHERE grantee LIKE 'INV_TABLAS' 
   OR grantee LIKE 'ALM_TABLAS'
   OR grantee LIKE 'OPER_TABLAS'
   OR grantee LIKE 'G5DESA01' 
   OR grantee LIKE 'G5DESA02' 
   OR grantee LIKE 'G5UF01' 
   OR grantee LIKE 'G5_ROL%'
ORDER BY 1;


SELECT *
FROM dba_roles
WHERE role LIKE 'G5_ROL%';



SELECT *
FROM dba_role_privs
WHERE granted_role LIKE 'G5_ROL%'
ORDER BY grantee;




--------------------------------------------insersiones---------------------------------------------

--alm_tablas
DELETE FROM estado_tb;
COMMIT;

INSERT INTO estado_tb (id_estado, nombre_estado) VALUES (2, 'Inactivo');
INSERT INTO estado_tb (id_estado, nombre_estado) VALUES (3, 'En mantenimiento');
INSERT INTO estado_tb (id_estado, nombre_estado) VALUES (4, 'Cerrado');
COMMIT;

INSERT INTO sucursal_tb (id_sucursal, nombre_sucursal) VALUES (1, 'Sucursal Central');
INSERT INTO sucursal_tb (id_sucursal, nombre_sucursal) VALUES (2, 'Sucursal Norte');
INSERT INTO sucursal_tb (id_sucursal, nombre_sucursal) VALUES (3, 'Sucursal Sur');
INSERT INTO sucursal_tb (id_sucursal, nombre_sucursal) VALUES (4, 'Sucursal Este');
INSERT INTO sucursal_tb (id_sucursal, nombre_sucursal) VALUES (5, 'Sucursal Oeste');
COMMIT;

INSERT INTO departamentos_tb (id_departamento, nombre_departamento, id_sucursal)
VALUES (1, 'Depto Compras', 1);
INSERT INTO departamentos_tb (id_departamento, nombre_departamento, id_sucursal)
VALUES (2, 'Depto Ventas', 1);
INSERT INTO departamentos_tb (id_departamento, nombre_departamento, id_sucursal)
VALUES (3, 'Depto Logística', 2);
INSERT INTO departamentos_tb (id_departamento, nombre_departamento, id_sucursal)
VALUES (4, 'Depto Producción', 3);
INSERT INTO departamentos_tb (id_departamento, nombre_departamento, id_sucursal)
VALUES (5, 'Depto RRHH', 1);
COMMIT;

INSERT INTO almacen_tb (id_almacen, nombre_almacen, id_sucursal, id_estado)
VALUES (1, 'Almacén Central A', 1, 1);
INSERT INTO almacen_tb (id_almacen, nombre_almacen, id_sucursal, id_estado)
VALUES (2, 'Almacén Central B', 1, 1);
INSERT INTO almacen_tb (id_almacen, nombre_almacen, id_sucursal, id_estado)
VALUES (3, 'Almacén Norte', 2, 1);
INSERT INTO almacen_tb (id_almacen, nombre_almacen, id_sucursal, id_estado)
VALUES (4, 'Almacén Sur', 3, 2); -- inactivo
INSERT INTO almacen_tb (id_almacen, nombre_almacen, id_sucursal, id_estado)
VALUES (5, 'Almacén Este', 4, 1);
COMMIT;


--inv_tablas
DELETE FROM inv_tablas.producto_tb;
DELETE FROM inv_tablas.unidad_medida_tb;
COMMIT;

INSERT INTO unidad_medida_tb (id_unidad_medida, nombre) VALUES (1, 'Unidad');
INSERT INTO unidad_medida_tb (id_unidad_medida, nombre) VALUES (2, 'Caja');
INSERT INTO unidad_medida_tb (id_unidad_medida, nombre) VALUES (3, 'Paquete');
INSERT INTO unidad_medida_tb (id_unidad_medida, nombre) VALUES (4, 'Litro');
INSERT INTO unidad_medida_tb (id_unidad_medida, nombre) VALUES (5, 'Metro');
COMMIT;

INSERT INTO producto_tb (id_producto, nombre_producto, descripcion, precio_unitario, id_unidad_medida, id_estado)
VALUES (100, 'Producto A', 'Producto de prueba A', 500.00, 1, 1);
INSERT INTO producto_tb (id_producto, nombre_producto, descripcion, precio_unitario, id_unidad_medida, id_estado)
VALUES (101, 'Producto B', 'Producto de prueba B', 750.00, 1, 1);
INSERT INTO producto_tb (id_producto, nombre_producto, descripcion, precio_unitario, id_unidad_medida, id_estado)
VALUES (102, 'Producto C', 'Producto de prueba C', 1000.00, 2, 1);
INSERT INTO producto_tb (id_producto, nombre_producto, descripcion, precio_unitario, id_unidad_medida, id_estado)
VALUES (103, 'Producto D', 'Producto de prueba D', 250.50, 3, 1);
INSERT INTO producto_tb (id_producto, nombre_producto, descripcion, precio_unitario, id_unidad_medida, id_estado)
VALUES (104, 'Producto E', 'Producto de prueba E', 99.99, 4, 1);
COMMIT;


--oper_tablas

DELETE FROM oper_tablas.detalle_solicitud_tb;
DELETE FROM oper_tablas.solicitud_tb;
DELETE FROM oper_tablas.factura_tb;
DELETE FROM oper_tablas.usuario_tb;
COMMIT;

INSERT INTO usuario_tb (id_usuario, nombre_completo, username, pass, rol, activo)
VALUES (1, 'Administrador General', 'admin', '1234', 'ADMIN', 1);
INSERT INTO usuario_tb (id_usuario, nombre_completo, username, pass, rol, activo)
VALUES (2, 'Operador Uno', 'oper1', 'abcd', 'OPERADOR', 1);
INSERT INTO usuario_tb (id_usuario, nombre_completo, username, pass, rol, activo)
VALUES (3, 'Operador Dos', 'oper2', 'abcd', 'OPERADOR', 1);
INSERT INTO usuario_tb (id_usuario, nombre_completo, username, pass, rol, activo)
VALUES (4, 'Invitado', 'guest', 'abcd', 'CONSULTA', 1);
COMMIT;

INSERT INTO factura_tb (id_factura, fecha, monto_total) VALUES (1, SYSDATE, 1500.00);
INSERT INTO factura_tb (id_factura, fecha, monto_total) VALUES (2, SYSDATE, 3000.00);
INSERT INTO factura_tb (id_factura, fecha, monto_total) VALUES (3, SYSDATE, 500.00);
COMMIT;



-----------------------------------------------------------------------------------------------------
/* ============================================================================================
   FRONT END - PROCEDIMIENTOS Y PERMISOS
   ============================================================================================

   ? Los GRANT sobre tablas y secuencias se corren como SYS o SYSTEM.
   ? La creación de la secuencia se corre como inv_tablas.
   ? Los procedimientos se crean en G5Desa01 (usuario desarrollador).
   ? Al final se dan permisos de EXECUTE a G5UF01 (usuario final).

============================================================================================ */

/* ============================================================================================
   1. DAR PERMISOS DESDE SYS O SYSTEM PARA QUE DESARROLLADOR PUEDA VER TABLAS Y SECUENCIA
============================================================================================ */

GRANT SELECT ON alm_tablas.almacen_tb TO G5Desa01;
GRANT SELECT ON alm_tablas.sucursal_tb TO G5Desa01;

GRANT SELECT, INSERT, UPDATE ON inv_tablas.inventario_tb TO G5Desa01;
GRANT SELECT ON inv_tablas.producto_tb TO G5Desa01;
GRANT SELECT, INSERT ON inv_tablas.lote_tb TO G5Desa01;
GRANT SELECT ON alm_tablas.estado_tb TO G5Desa01;
GRANT SELECT ON inv_tablas.unidad_medida_tb TO G5Desa01;


-- Permiso a inv_tablas para crear la secuencia
GRANT CREATE SEQUENCE TO inv_tablas;



/* ============================================================================================
   2. CREAR SECUENCIA DESDE LA CONEXIÓN inv_tablas
============================================================================================ */
-- Conectado como inv_tablas:
CREATE SEQUENCE inv_tablas.SEQ_INVENTARIO
START WITH 1
INCREMENT BY 1
NOCACHE;

GRANT SELECT ON inv_tablas.SEQ_INVENTARIO TO G5Desa01;


/* ============================================================================================
   3. CREAR PROCEDIMIENTOS DESDE LA CONEXIÓN G5Desa01
============================================================================================ */

----------------------------------------------------------------------------------------------
-- PROCEDIMIENTO PARA AGREGAR PRODUCTO A UN ALMACÉN
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_AGREGAR_PRODUCTO_ALMACEN (
    p_id_producto IN NUMBER,
    p_id_almacen  IN NUMBER,
    p_cantidad    IN NUMBER,
    p_resultado   OUT VARCHAR2
) AS
    v_id_sucursal NUMBER;
    v_estado      NUMBER;
BEGIN
    SELECT id_sucursal, id_estado
    INTO v_id_sucursal, v_estado
    FROM alm_tablas.almacen_tb
    WHERE id_almacen = p_id_almacen;

    IF v_estado <> 1 THEN
        p_resultado := 'ALMACEN INACTIVO';
        RETURN;
    END IF;

    UPDATE inv_tablas.inventario_tb
    SET cantidad_disponible = cantidad_disponible + p_cantidad
    WHERE id_producto = p_id_producto AND id_almacen = p_id_almacen;

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO inv_tablas.inventario_tb (
            id_inventario, id_producto, id_almacen,
            cantidad_disponible, stock_minimo, stock_maximo, id_estado
        ) VALUES (
            inv_tablas.SEQ_INVENTARIO.NEXTVAL,
            p_id_producto,
            p_id_almacen,
            p_cantidad,
            0, 0, 1
        );
    END IF;

    p_resultado := 'AGREGADO EXITOSO';
END;
/

----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-- PROCEDIMIENTO PARA REBAJAR PRODUCTO DE UN ALMACÉN
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_REBAJAR_PRODUCTO_ALMACEN (
    p_id_producto IN NUMBER,
    p_id_almacen  IN NUMBER,
    p_cantidad    IN NUMBER,
    p_resultado   OUT VARCHAR2
) AS
    v_stock_actual NUMBER;
BEGIN
    SELECT cantidad_disponible
    INTO v_stock_actual
    FROM inv_tablas.inventario_tb
    WHERE id_producto = p_id_producto AND id_almacen = p_id_almacen;

    IF v_stock_actual < p_cantidad THEN
        p_resultado := 'STOCK INSUFICIENTE';
        RETURN;
    END IF;

    UPDATE inv_tablas.inventario_tb
    SET cantidad_disponible = cantidad_disponible - p_cantidad
    WHERE id_producto = p_id_producto AND id_almacen = p_id_almacen;

    p_resultado := 'REBAJA EXITOSA';
END;
/
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- LISTAR SUCURSALES
----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE G5_LISTAR_SUCURSALES (
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT s.id_sucursal, s.nombre_sucursal
    FROM alm_tablas.sucursal_tb s
    ORDER BY s.id_sucursal;
END;
/


----------------------------------------------------------------------------------------------
-- LISTAR ALMACENES POR SUCURSAL (solo activos)
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_LISTAR_ALMACENES_POR_SUCURSAL (
  p_id_sucursal IN NUMBER,
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT a.id_almacen, a.nombre_almacen
    FROM alm_tablas.almacen_tb a
    WHERE a.id_sucursal = p_id_sucursal
      AND a.id_estado = 1
    ORDER BY a.id_almacen;
END;
/



----------------------------------------------------------------------------------------------
-- LISTAR PRODUCTOS
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_LISTAR_PRODUCTOS (
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT 
      p.id_producto,
      p.nombre_producto,
      p.descripcion,
      p.precio_unitario,
      u.nombre         AS nombre_unidad_medida,
      e.nombre_estado  AS nombre_estado
    FROM inv_tablas.producto_tb p
    JOIN inv_tablas.unidad_medida_tb u
      ON p.id_unidad_medida = u.id_unidad_medida
    JOIN alm_tablas.estado_tb e
      ON p.id_estado = e.id_estado
    ORDER BY p.id_producto;
END;
/


----------------------------------------------------------------------------------------------
-- LISTAR KARDEX POR PRODUCTO
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_LISTAR_KARDEX_PRODUCTO (
  p_id_producto IN NUMBER,
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT i.id_inventario,
           i.id_producto,
           i.id_almacen,
           i.cantidad_disponible,
           i.stock_minimo,
           i.stock_maximo,
           i.id_estado
    FROM inv_tablas.inventario_tb i
    WHERE i.id_producto = p_id_producto
    ORDER BY i.id_almacen;
END;
/


----------------------------------------------------------------------------------------------
-- LISTAR TODOS LOS ALMACENES CON SUCURSAL
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_LISTAR_ALMACENES_CON_SUCURSAL (
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT a.id_almacen,
           a.nombre_almacen,
           s.nombre_sucursal,
           a.id_estado
    FROM alm_tablas.almacen_tb a
    JOIN alm_tablas.sucursal_tb s
      ON a.id_sucursal = s.id_sucursal
    ORDER BY s.id_sucursal, a.id_almacen;
END;
/



----------------------------------------------------------------------------------------------
-- LISTAR INVENTARIO FILTRADO POR ALMACÉN
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_LISTAR_INVENTARIO_ALMACEN (
  p_id_almacen IN NUMBER,
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT 
      i.id_inventario,
      p.nombre_producto,
      p.descripcion,
      p.precio_unitario,
      u.nombre AS nombre_unidad_medida,
      e.nombre_estado,
      i.cantidad_disponible
    FROM inv_tablas.inventario_tb i
      JOIN inv_tablas.producto_tb p 
        ON i.id_producto = p.id_producto
      JOIN inv_tablas.unidad_medida_tb u 
        ON p.id_unidad_medida = u.id_unidad_medida
      JOIN alm_tablas.estado_tb e 
        ON i.id_estado = e.id_estado
    WHERE i.id_almacen = p_id_almacen
    ORDER BY p.id_producto;
END;
/


----------------------------------------------------------------------------------------------


/* ============================================================================================
   4. PERMISOS DE EJECUCIÓN AL USUARIO FINAL DESDE desa
============================================================================================ */


GRANT EXECUTE ON G5Desa01.G5_AGREGAR_PRODUCTO_ALMACEN TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_REBAJAR_PRODUCTO_ALMACEN TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_LISTAR_SUCURSALES TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_LISTAR_ALMACENES_POR_SUCURSAL TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_LISTAR_PRODUCTOS TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_LISTAR_KARDEX_PRODUCTO TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_LISTAR_ALMACENES_CON_SUCURSAL TO G5UF01;
GRANT EXECUTE ON G5Desa01.G5_LISTAR_INVENTARIO_ALMACEN TO G5UF01;



-- en inv_tablas
GRANT SELECT ON inv_tablas.producto_tb TO G5UF01;


/* ============================================================================================
   5. EJEMPLO DE EJECUCIÓN (usuario final G5UF01)
============================================================================================ */
DECLARE
  v_resultado VARCHAR2(50);
  v_cursor SYS_REFCURSOR;
BEGIN
  G5Desa01.G5_AGREGAR_PRODUCTO_ALMACEN(100,1,50,v_resultado);
  DBMS_OUTPUT.PUT_LINE('Resultado: '||v_resultado);

  G5Desa01.G5_LISTAR_SUCURSALES(v_cursor);
  -- Aquí puedes FETCH desde el cursor o usarlo en tu backend

END;
/
COMMIT;






--verificar insersiones o movimientos del frontend

  --verificar saldo por bodega 
SELECT 
  id_producto      AS codigo, 
  id_almacen       AS almacen, 
  cantidad_disponible AS disponible
FROM inv_tablas.inventario_tb
WHERE id_producto = 100
  AND id_almacen = 2;
  
  
  
  --verificar saldo general del codigo 
SELECT  
  p.id_producto        AS codigo, 
  p.nombre_producto    AS producto,
  a.nombre_almacen     AS almacen,
  i.cantidad_disponible AS disponible
FROM inv_tablas.inventario_tb i
JOIN inv_tablas.producto_tb p ON i.id_producto = p.id_producto
JOIN alm_tablas.almacen_tb a ON i.id_almacen = a.id_almacen
ORDER BY p.id_producto, a.id_almacen;



