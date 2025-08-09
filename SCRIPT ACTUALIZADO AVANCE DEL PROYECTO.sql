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

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
------ DIVISION PROXIMO PASO DEL PROYECTO DESA PROYECTO Y USUARIO FINALES 

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



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- FRONT END - PROCEDIMIENTOS Y PERMISOS
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
   2. CREAR SECUENCIA DESDE LA CONEXION inv_tablas
============================================================================================ */
-- Conectado como inv_tablas:
CREATE SEQUENCE inv_tablas.SEQ_INVENTARIO
START WITH 1
INCREMENT BY 1
NOCACHE;

GRANT SELECT ON inv_tablas.SEQ_INVENTARIO TO G5Desa01;

/* ============================================================================================
   3. PROCEDIMIENTOS USADOS EN FRONT END 
============================================================================================ */

/* ============================================================================================
   3. CREAR PROCEDIMIENTOS DESDE LA CONEXIION G5Desa01
============================================================================================ */

----------------------------------------------------------------------------------------------
-- PROCEDIMIENTO PARA AGREGAR PRODUCTO A UN ALMACEN
-- PROCEDIMIENTO PARA AGREGAR PRODUCTO A UN ALMACEN
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
     WHERE id_producto = p_id_producto
       AND id_almacen  = p_id_almacen;

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

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ALMACEN NO EXISTE';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;
/


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
     WHERE id_producto = p_id_producto
       AND id_almacen  = p_id_almacen;

    IF v_stock_actual < p_cantidad THEN
        p_resultado := 'STOCK INSUFICIENTE';
        RETURN;
    END IF;

    UPDATE inv_tablas.inventario_tb
       SET cantidad_disponible = cantidad_disponible - p_cantidad
     WHERE id_producto = p_id_producto
       AND id_almacen  = p_id_almacen;

    p_resultado := 'REBAJA EXITOSA';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'SIN REGISTRO EN ALMACEN';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;
/

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
-- LISTAR INVENTARIO FILTRADO POR ALMACEN
----------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE G5_LISTAR_INVENTARIO_ALMACEN (
  p_id_almacen IN NUMBER,
  p_resultado OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_resultado FOR
    SELECT 
      i.id_inventario,          
      p.id_producto,            
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
   4. PERMISOS DE EJECUCION AL USUARIO FINAL DESDE desa
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
   5. EJEMPLO DE EJECUCION (usuario final G5UF01)
============================================================================================ */
DECLARE
  v_resultado VARCHAR2(50);
  v_cursor SYS_REFCURSOR;
BEGIN
  G5Desa01.G5_AGREGAR_PRODUCTO_ALMACEN(100,1,50,v_resultado);
  DBMS_OUTPUT.PUT_LINE('Resultado: '||v_resultado);

  G5Desa01.G5_LISTAR_SUCURSALES(v_cursor);


END;
/
COMMIT


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

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Se corre en sys o system
GRANT SELECT, UPDATE ON inv_tablas.inventario_tb TO oper_tablas;
GRANT SELECT ON inv_tablas.producto_tb TO oper_tablas;
GRANT SELECT ON alm_tablas.almacen_tb TO oper_tablas;
GRANT SELECT ON alm_tablas.departamentos_tb TO oper_tablas;
GRANT CREATE PROCEDURE TO OPER_TABLAS;

-- Se corre en oper_tablas
-- tablas rechazos

CREATE TABLE oper_tablas.rechazos_tb (
    id_solicitud       NUMBER,
    id_producto        NUMBER,
    cantidad_solicitada NUMBER,
    cantidad_rechazada  NUMBER,
    CONSTRAINT pk_rechazos_tb PRIMARY KEY (id_solicitud, id_producto)
);

-- Transaccion Principal --

-- Inventario inicial para pruebas
-- SE CORRE EN INV_TABLAS
INSERT INTO inv_tablas.inventario_tb
    (id_inventario, id_producto, id_almacen, cantidad_disponible, stock_minimo, stock_maximo, id_estado)
VALUES
    (1, 100, 1, 100, 0, 0, 1);  

INSERT INTO inv_tablas.inventario_tb
    (id_inventario, id_producto, id_almacen, cantidad_disponible, stock_minimo, stock_maximo, id_estado)
VALUES
    (2, 101, 1, 0, 0, 0, 1);    

INSERT INTO inv_tablas.inventario_tb
    (id_inventario, id_producto, id_almacen, cantidad_disponible, stock_minimo, stock_maximo, id_estado)
VALUES
    (3, 102, 1, 20, 0, 0, 1);   

INSERT INTO inv_tablas.inventario_tb
    (id_inventario, id_producto, id_almacen, cantidad_disponible, stock_minimo, stock_maximo, id_estado)
VALUES
    (4, 103, 1, 50, 0, 0, 1);   

INSERT INTO inv_tablas.inventario_tb
    (id_inventario, id_producto, id_almacen, cantidad_disponible, stock_minimo, stock_maximo, id_estado)
VALUES
    (5, 104, 1, 0, 0, 0, 1);    

INSERT INTO inv_tablas.inventario_tb
    (id_inventario, id_producto, id_almacen, cantidad_disponible, stock_minimo, stock_maximo, id_estado)
VALUES
    (6, 105, 1, 60, 0, 0, 1);  
COMMIT;    

-- Restaurar inventario a cantidades originales
UPDATE inv_tablas.inventario_tb
SET cantidad_disponible = CASE id_producto
    WHEN 100 THEN 100  
    WHEN 101 THEN 0    
    WHEN 102 THEN 20   
    WHEN 103 THEN 50   
    WHEN 104 THEN 0    
    WHEN 105 THEN 60  
END
WHERE id_producto BETWEEN 100 AND 105;

COMMIT;


SELECT * FROM INV_TABLAS.INVENTARIO_TB;

CREATE TABLE oper_tablas.peticion_tb (
    id_peticion         NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    id_usuario          NUMBER       NOT NULL,
    id_departamento     NUMBER       NOT NULL,
    id_producto         NUMBER       NOT NULL,
    cantidad_requerida  NUMBER(12,2) NOT NULL CHECK (cantidad_requerida > 0),
    estado              NUMBER(1)    DEFAULT 0 NOT NULL CHECK (estado IN (0,1)), -- 0=pending, 1=atendida
    fecha_creacion      DATE         DEFAULT SYSDATE NOT NULL,
    fecha_atencion      DATE,
    resultado_msg       VARCHAR2(4000)
);

-- FK a usuario
ALTER TABLE oper_tablas.peticion_tb
  ADD CONSTRAINT fk_pet_usuario
  FOREIGN KEY (id_usuario)
  REFERENCES oper_tablas.usuario_tb (id_usuario);

-- FK a departamento
ALTER TABLE oper_tablas.peticion_tb
  ADD CONSTRAINT fk_pet_departamento
  FOREIGN KEY (id_departamento)
  REFERENCES alm_tablas.departamentos_tb (id_departamento);

-- FK a producto
ALTER TABLE oper_tablas.peticion_tb
  ADD CONSTRAINT fk_pet_producto
  FOREIGN KEY (id_producto)
  REFERENCES inv_tablas.producto_tb (id_producto);

-- �ndice para barrer pendientes r�pidamente
CREATE INDEX oper_tablas.ix_peticion_estado
  ON oper_tablas.peticion_tb (estado, fecha_creacion);



-- 2. agregar v�nculo id_peticion en solicitud_tb
ALTER TABLE oper_tablas.solicitud_tb ADD (id_peticion NUMBER NULL);
ALTER TABLE oper_tablas.solicitud_tb ADD CONSTRAINT fk_solicitud_peticion
  FOREIGN KEY (id_peticion) REFERENCES oper_tablas.peticion_tb (id_peticion);
CREATE INDEX oper_tablas.ix_solicitud_id_peticion ON oper_tablas.solicitud_tb (id_peticion);

-- 3. procedimiento: seleccionar siguiente petici�n pendiente (bloquea la fila)
CREATE OR REPLACE PROCEDURE oper_tablas.seleccionaPeticion (
    rPeticion OUT oper_tablas.peticion_tb%ROWTYPE,
    vTermina  OUT NUMBER
) AS
    CURSOR cPet IS
        SELECT *
          FROM oper_tablas.peticion_tb
         WHERE estado = 0
         ORDER BY fecha_creacion, id_peticion
         FOR UPDATE SKIP LOCKED;
BEGIN
    OPEN cPet;
    FETCH cPet INTO rPeticion;
    IF cPet%NOTFOUND THEN
        vTermina := 1;
    ELSE
        vTermina := 0;
    END IF;
    CLOSE cPet;
END;
/

-- 4. PROCEDIMIENTO PRINCIPAL
CREATE OR REPLACE PROCEDURE oper_tablas.G5_SOLICITAR_PRODUCTO
(
    p_id_usuario       IN  NUMBER,
    p_id_departamento  IN  NUMBER,
    p_id_producto      IN  NUMBER,
    p_cantidad         IN  NUMBER,
    p_mensaje          OUT VARCHAR2,
    p_id_peticion      IN  NUMBER DEFAULT NULL
) AUTHID DEFINER
AS
    v_existe_usuario     NUMBER := 0;
    v_existe_depto       NUMBER := 0;
    v_existe_producto    NUMBER := 0;
    v_id_sucursal        NUMBER;
    v_precio_unitario    NUMBER := 0;
    v_stock_total        NUMBER := 0;
    v_a_entregar_total   NUMBER := 0;
    v_rechazado          NUMBER := 0;
    v_pendiente          NUMBER := 0;
    v_monto_total        NUMBER := 0;
    v_id_factura         NUMBER;
    v_id_solicitud       NUMBER;
    v_nuevo_detalle_id   NUMBER;
    v_dep  NUMBER := p_id_departamento;
    v_prod NUMBER := p_id_producto;
    v_cant NUMBER := p_cantidad;
BEGIN
    -- 4.1. si viene id_peticion, leer datos de la bandeja y bloquear la fila
    IF p_id_peticion IS NOT NULL THEN
        BEGIN
            SELECT id_departamento, id_producto, cantidad_requerida
              INTO v_dep, v_prod, v_cant
              FROM oper_tablas.peticion_tb
             WHERE id_peticion = p_id_peticion
               AND estado = 0
             FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_mensaje := 'Petici�n inv�lida o ya atendida (id='||p_id_peticion||')';
                RETURN;
        END;
    END IF;

    -- 4.2. validaciones
    SELECT COUNT(*) INTO v_existe_usuario FROM oper_tablas.usuario_tb WHERE id_usuario = p_id_usuario;
    IF v_existe_usuario = 0 THEN p_mensaje := 'Usuario inv�lido'; RETURN; END IF;

    SELECT COUNT(*) INTO v_existe_depto FROM alm_tablas.departamentos_tb WHERE id_departamento = v_dep;
    IF v_existe_depto = 0 THEN p_mensaje := 'Departamento inv�lido'; RETURN; END IF;

    SELECT COUNT(*) INTO v_existe_producto FROM inv_tablas.producto_tb WHERE id_producto = v_prod;
    IF v_existe_producto = 0 THEN p_mensaje := 'Producto inv�lido'; RETURN; END IF;

    IF v_cant IS NULL OR v_cant <= 0 THEN p_mensaje := 'Cantidad solicitada inv�lida'; RETURN; END IF;

    -- 4.3. datos base
    SELECT id_sucursal INTO v_id_sucursal
      FROM alm_tablas.departamentos_tb WHERE id_departamento = v_dep;

    SELECT precio_unitario INTO v_precio_unitario
      FROM inv_tablas.producto_tb WHERE id_producto = v_prod;

    -- 4.4. stock total y reparto inicial
    SELECT NVL(SUM(i.cantidad_disponible), 0)
      INTO v_stock_total
      FROM inv_tablas.inventario_tb i
      JOIN alm_tablas.almacen_tb a ON a.id_almacen = i.id_almacen
     WHERE a.id_sucursal = v_id_sucursal
       AND i.id_producto = v_prod;

    IF v_stock_total <= 0 THEN
        v_a_entregar_total := 0; v_rechazado := v_cant;
    ELSIF v_stock_total < v_cant THEN
        v_a_entregar_total := v_stock_total; v_rechazado := v_cant - v_stock_total;
    ELSE
        v_a_entregar_total := v_cant; v_rechazado := 0;
    END IF;

    -- 4.5. factura
    SELECT NVL(MAX(id_factura),0) + 1 INTO v_id_factura FROM oper_tablas.factura_tb;
    INSERT INTO oper_tablas.factura_tb (id_factura, fecha, monto_total)
    VALUES (v_id_factura, SYSDATE, 0);

    -- 4.6. solicitud (guarda id_peticion si vino)
    SELECT NVL(MAX(id_solicitud),0) + 1 INTO v_id_solicitud FROM oper_tablas.solicitud_tb;
    INSERT INTO oper_tablas.solicitud_tb
        (id_solicitud, fecha, id_departamento, id_factura, id_usuario, id_peticion)
    VALUES
        (v_id_solicitud, SYSDATE, v_dep, v_id_factura, p_id_usuario, p_id_peticion);

    -- 4.7. rechazo (si aplica)
    IF v_rechazado > 0 THEN
        INSERT INTO oper_tablas.rechazos_tb
            (id_solicitud, id_producto, cantidad_solicitada, cantidad_rechazada)
        VALUES
            (v_id_solicitud, v_prod, v_cant, v_rechazado);
    END IF;

    -- 4.8. reparto por inventarios
    v_pendiente := v_a_entregar_total;
    FOR reg IN (
        SELECT i.id_inventario, i.cantidad_disponible, i.stock_minimo, i.id_almacen
          FROM inv_tablas.inventario_tb i
          JOIN alm_tablas.almacen_tb a ON a.id_almacen = i.id_almacen
         WHERE a.id_sucursal = v_id_sucursal
           AND i.id_producto = v_prod
         ORDER BY i.id_inventario
    ) LOOP
        EXIT WHEN v_pendiente <= 0;
        DECLARE v_entregar NUMBER; v_restante NUMBER; BEGIN
            v_entregar := LEAST(reg.cantidad_disponible, v_pendiente);
            SELECT NVL(MAX(id_detalle_solicitud),0) + 1
              INTO v_nuevo_detalle_id
              FROM oper_tablas.detalle_solicitud_tb;
            INSERT INTO oper_tablas.detalle_solicitud_tb
                (id_detalle_solicitud, id_solicitud, id_inventario,
                 cantidad_solicitada, cantidad_entregada)
            VALUES
                (v_nuevo_detalle_id, v_id_solicitud, reg.id_inventario,
                 v_pendiente, v_entregar);
            UPDATE inv_tablas.inventario_tb
               SET cantidad_disponible = cantidad_disponible - v_entregar
             WHERE id_inventario = reg.id_inventario;
            v_restante := reg.cantidad_disponible - v_entregar;
            v_pendiente := v_pendiente - v_entregar;
            v_monto_total := v_monto_total + (v_entregar * v_precio_unitario);
            IF v_restante < reg.stock_minimo THEN
                DBMS_OUTPUT.PUT_LINE('Alerta: stock bajo en almac�n '||reg.id_almacen||
                                     ' para producto '||v_prod);
            END IF;
        END;
    END LOOP;

    -- 4.9. actualizar factura
    UPDATE oper_tablas.factura_tb
       SET monto_total = v_monto_total
     WHERE id_factura = v_id_factura;

    -- 4.10. mensaje
    IF v_a_entregar_total = 0 THEN
        p_mensaje := 'Solicitud '||v_id_solicitud||' rechazada: sin stock. Rechazado: '||v_rechazado;
    ELSIF v_rechazado > 0 THEN
        p_mensaje := 'Solicitud '||v_id_solicitud||' parcial. Entregado: '||v_a_entregar_total||
                     ', Rechazado: '||v_rechazado||'. Monto: '||v_monto_total;
    ELSE
        p_mensaje := 'Solicitud '||v_id_solicitud||' completa. Entregado: '||v_a_entregar_total||
                     '. Monto: '||v_monto_total;
    END IF;

    -- 4.11. cerrar petici�n si vino desde la bandeja
    IF p_id_peticion IS NOT NULL THEN
        UPDATE oper_tablas.peticion_tb
           SET estado = 1, fecha_atencion = SYSDATE, resultado_msg = p_mensaje
         WHERE id_peticion = p_id_peticion;
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := 'Error: '||SQLERRM;
        IF p_id_peticion IS NOT NULL THEN
            UPDATE oper_tablas.peticion_tb
               SET resultado_msg = p_mensaje
             WHERE id_peticion = p_id_peticion;
            COMMIT;
        END IF;
END;
/

-- 5. procedimiento: atiende todas las peticiones estado=0 
CREATE OR REPLACE PROCEDURE oper_tablas.pruebaActualizaInventario AS
    rPeticion oper_tablas.peticion_tb%ROWTYPE;
    fin       NUMBER;
    v_msg     VARCHAR2(4000);
BEGIN
    LOOP
        oper_tablas.seleccionaPeticion(rPeticion, fin);
        EXIT WHEN fin = 1;

        oper_tablas.G5_SOLICITAR_PRODUCTO(
            p_id_usuario      => rPeticion.id_usuario,        
            p_id_departamento => rPeticion.id_departamento,   
            p_id_producto     => rPeticion.id_producto,
            p_cantidad        => rPeticion.cantidad_requerida,
            p_mensaje         => v_msg,
            p_id_peticion     => rPeticion.id_peticion
        );
    END LOOP;
END;
/

-- 6. INSERTS DE EJEMPLO (peticiones pendientes)
-- 6.1 STOCK SUFICIENTE (entrega completa): 103 (tiene 100), 105 (dejamos 80)
INSERT INTO oper_tablas.peticion_tb
    (id_usuario, id_departamento, id_producto, cantidad_requerida, estado, fecha_creacion)
VALUES (2, 1, 103, 8, 0, SYSDATE);

INSERT INTO oper_tablas.peticion_tb
    (id_usuario, id_departamento, id_producto, cantidad_requerida, estado, fecha_creacion)
VALUES (2, 1, 105, 20, 0, SYSDATE);

-- 6.2 STOCK INSUFICIENTE (entrega parcial): 100 (=40 -> pide 50), 104 (=20 -> pide 30)
INSERT INTO oper_tablas.peticion_tb
    (id_usuario, id_departamento, id_producto, cantidad_requerida, estado, fecha_creacion)
VALUES (2, 1, 100, 50, 0, SYSDATE);

INSERT INTO oper_tablas.peticion_tb
    (id_usuario, id_departamento, id_producto, cantidad_requerida, estado, fecha_creacion)
VALUES (2, 1, 104, 30, 0, SYSDATE);

-- 6.3 SIN STOCK (rechazo total): 101 (=0), 102 (=0)
INSERT INTO oper_tablas.peticion_tb
    (id_usuario, id_departamento, id_producto, cantidad_requerida, estado, fecha_creacion)
VALUES (2, 1, 101, 10, 0, SYSDATE);

INSERT INTO oper_tablas.peticion_tb
    (id_usuario, id_departamento, id_producto, cantidad_requerida, estado, fecha_creacion)
VALUES (2, 1, 102, 15, 0, SYSDATE);

COMMIT;

SELECT * FROM OPER_TABLAS.PETICION_TB;

-- 7. EJECUCI�N (uno a uno o en lote)
-- 7.1 en lote (atiende todas las estado=0)
BEGIN
  oper_tablas.pruebaActualizaInventario;
END;
/

-- 7.2 individual (si quer�s disparar una espec�fica por id)
SET SERVEROUTPUT ON;
DECLARE
  v_msg VARCHAR2(4000);
BEGIN
  oper_tablas.G5_SOLICITAR_PRODUCTO(
    p_id_usuario      => 2,
    p_id_departamento => NULL,   -- ignorado cuando se pasa p_id_peticion
    p_id_producto     => NULL,   -- ignorado
    p_cantidad        => NULL,   -- ignorado
    p_mensaje         => v_msg,
    p_id_peticion     => (SELECT MIN(id_peticion) FROM oper_tablas.peticion_tb WHERE estado=0)
  );
  DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/

-- 8. CONSULTAS DE CONTROL
-- 8.1 peticiones 
SELECT id_peticion, id_usuario, id_departamento, id_producto, cantidad_requerida,
       estado, fecha_creacion, fecha_atencion, resultado_msg
  FROM oper_tablas.peticion_tb
 ORDER BY id_peticion;

-- 8.2 solicitudes recientes (enlazadas a peticiones)
SELECT s.id_solicitud, s.fecha, s.id_departamento, s.id_usuario, s.id_peticion, s.id_factura
  FROM oper_tablas.solicitud_tb s
 WHERE s.id_peticion IS NOT NULL
 ORDER BY s.id_solicitud DESC;

-- 8.3 facturas de esas solicitudes
SELECT f.id_factura, f.fecha, f.monto_total
  FROM oper_tablas.factura_tb f
 WHERE EXISTS (SELECT 1 FROM oper_tablas.solicitud_tb s
                WHERE s.id_factura = f.id_factura
                  AND s.id_peticion IS NOT NULL)
 ORDER BY f.id_factura DESC;

-- 8.4 detalles de solicitud
SELECT d.id_detalle_solicitud, d.id_solicitud, d.id_inventario,
       d.cantidad_solicitada, d.cantidad_entregada
  FROM oper_tablas.detalle_solicitud_tb d
 WHERE d.id_solicitud IN (SELECT s.id_solicitud
                            FROM oper_tablas.solicitud_tb s
                           WHERE s.id_peticion IS NOT NULL)
 ORDER BY d.id_detalle_solicitud DESC;

-- 8.5 rechazos (si hubo)
SELECT r.id_solicitud, r.id_producto, r.cantidad_solicitada, r.cantidad_rechazada
  FROM oper_tablas.rechazos_tb r
 WHERE r.id_solicitud IN (SELECT s.id_solicitud
                            FROM oper_tablas.solicitud_tb s
                           WHERE s.id_peticion IS NOT NULL)
 ORDER BY r.id_solicitud DESC;

-- 8.6 inventario del/los productos usados en la sucursal del depto (opcional)
SELECT i.id_inventario, i.id_producto, i.cantidad_disponible, i.stock_minimo, a.id_almacen, a.id_sucursal
  FROM inv_tablas.inventario_tb i
  JOIN alm_tablas.almacen_tb a ON a.id_almacen = i.id_almacen
 WHERE i.id_producto IN (SELECT id_producto FROM oper_tablas.peticion_tb);


-- 9. LIMPIEZA DE DATOS DE PRUEBA

DELETE FROM oper_tablas.detalle_solicitud_tb;
DELETE FROM oper_tablas.rechazos_tb;
DELETE FROM oper_tablas.solicitud_tb;
DELETE FROM oper_tablas.factura_tb;
DELETE FROM oper_tablas.peticion_tb;

COMMIT;

------------alertas------
-- Tabla de alertas
-- se crea en oper_tablas
CREATE TABLE oper_tablas.alerta_inventario_tb (
  id_alerta         NUMBER CONSTRAINT pk_alerta_inventario_tb PRIMARY KEY,
  id_inventario     NUMBER,
  id_producto       NUMBER,
  id_almacen        NUMBER,
  cantidad_disponible NUMBER,
  stock_minimo      NUMBER,
  fecha_alerta      DATE DEFAULT SYSDATE,
  tipo_alerta       VARCHAR2(100), -- 'BAJO_STOCK', 'INCONSISTENCIA', etc.
  mensaje           VARCHAR2(4000),
  procesado         NUMBER DEFAULT 0  -- 0 = no, 1 = sí
);

 -- Crea secuencia para las alertas:
-- se crea en oper_tablas
CREATE SEQUENCE oper_tablas.SEQ_ALERTA_INVENTARIO START WITH 1 INCREMENT BY 1 NOCACHE;

-- Trigger para detectar bajo stock
-- se crea en inv_tablas
CREATE OR REPLACE TRIGGER inv_tablas.trg_alerta_inventario
AFTER INSERT OR UPDATE ON inv_tablas.inventario_tb
FOR EACH ROW
DECLARE
  v_mensaje VARCHAR2(4000);
  v_tipo    VARCHAR2(50);
BEGIN
  -- Bajo stock
  IF :NEW.cantidad_disponible IS NOT NULL AND :NEW.stock_minimo IS NOT NULL 
     AND :NEW.cantidad_disponible < :NEW.stock_minimo THEN
    v_tipo := 'BAJO_STOCK';
    v_mensaje := 'Stock por debajo del mínimo. Disponible=' || :NEW.cantidad_disponible ||
                 ', Mínimo=' || :NEW.stock_minimo;
    INSERT INTO oper_tablas.alerta_inventario_tb (
      id_alerta, id_inventario, id_producto, id_almacen,
      cantidad_disponible, stock_minimo, tipo_alerta, mensaje
    ) VALUES (
      oper_tablas.SEQ_ALERTA_INVENTARIO.NEXTVAL,
      :NEW.id_inventario,
      :NEW.id_producto,
      :NEW.id_almacen,
      :NEW.cantidad_disponible,
      :NEW.stock_minimo,
      v_tipo,
      v_mensaje
    );
  END IF;

  -- Inconsistencia: cantidad_disponible negativa
  IF :NEW.cantidad_disponible < 0 THEN
    v_tipo := 'INCONSISTENCIA';
    v_mensaje := 'Cantidad disponible negativa: ' || :NEW.cantidad_disponible;
    INSERT INTO oper_tablas.alerta_inventario_tb (
      id_alerta, id_inventario, id_producto, id_almacen,
      cantidad_disponible, stock_minimo, tipo_alerta, mensaje
    ) VALUES (
      oper_tablas.SEQ_ALERTA_INVENTARIO.NEXTVAL,
      :NEW.id_inventario,
      :NEW.id_producto,
      :NEW.id_almacen,
      :NEW.cantidad_disponible,
      :NEW.stock_minimo,
      v_tipo,
      v_mensaje
    );
  END IF;
END;
/

-- Historico de movimientos - Tabla de log de movimientos
-- se crea en inv_tablas
CREATE TABLE inv_tablas.kardex_movimientos_tb (
  id_movimiento         NUMBER CONSTRAINT pk_kardex_movimientos PRIMARY KEY,
  id_inventario         NUMBER,
  id_producto           NUMBER,
  id_almacen            NUMBER,
  cantidad_anterior     NUMBER,
  cantidad_nueva        NUMBER,
  diferencia            NUMBER,
  tipo_movimiento       VARCHAR2(50), -- 'AGREGADO', 'REBAJADO', 'SOLICITUD', etc.
  usuario_ejecutor      VARCHAR2(100),
  fecha_movimiento      DATE DEFAULT SYSDATE,
  referencia            VARCHAR2(200) -- opcional: e.g., 'Solicitud 123'
);
CREATE SEQUENCE inv_tablas.SEQ_KARDEX_MOV START WITH 1 INCREMENT BY 1 NOCACHE;

-- Trigger para registrar cambios en inventario 
-- se crea en inv_tablas
CREATE OR REPLACE TRIGGER inv_tablas.trg_kardex_inventario
BEFORE UPDATE ON inv_tablas.inventario_tb
FOR EACH ROW
DECLARE
  v_tipo VARCHAR2(50);
BEGIN
  IF :NEW.cantidad_disponible > :OLD.cantidad_disponible THEN
    v_tipo := 'AGREGADO';
  ELSIF :NEW.cantidad_disponible < :OLD.cantidad_disponible THEN
    v_tipo := 'REBAJADO';
  ELSE
    v_tipo := 'SIN_CAMBIO';
  END IF;

  INSERT INTO inv_tablas.kardex_movimientos_tb (
    id_movimiento,
    id_inventario,
    id_producto,
    id_almacen,
    cantidad_anterior,
    cantidad_nueva,
    diferencia,
    tipo_movimiento,
    usuario_ejecutor,
    referencia
  ) VALUES (
    inv_tablas.SEQ_KARDEX_MOV.NEXTVAL,
    :OLD.id_inventario,
    :OLD.id_producto,
    :OLD.id_almacen,
    :OLD.cantidad_disponible,
    :NEW.cantidad_disponible,
    :NEW.cantidad_disponible - :OLD.cantidad_disponible,
    v_tipo,
    SYS_CONTEXT('USERENV','SESSION_USER'),
    NULL 
  );
END;
/

-- reportes--
--  Productos mas solicitados
-- se crea en oper tablas
CREATE OR REPLACE VIEW reporte_productos_mas_solicitados_vw AS
SELECT 
  p.id_producto,
  p.nombre_producto,
  SUM(d.cantidad_solicitada) AS total_solicitado,
  COUNT(DISTINCT s.id_solicitud) AS veces_solicitado
FROM oper_tablas.detalle_solicitud_tb d
JOIN oper_tablas.solicitud_tb s ON d.id_solicitud = s.id_solicitud
JOIN inv_tablas.producto_tb p ON d.id_inventario = (
    SELECT i.id_inventario FROM inv_tablas.inventario_tb i 
    WHERE i.id_producto = p.id_producto AND i.id_inventario = d.id_inventario
)
GROUP BY p.id_producto, p.nombre_producto
ORDER BY total_solicitado DESC;

-- Consumo por departamento
-- se crea en oper tablas
CREATE OR REPLACE VIEW reporte_consumo_departamento_vw AS
SELECT 
  dep.id_departamento,
  dep.nombre_departamento,
  SUM(ds.cantidad_entregada) AS total_entregado,
  COUNT(DISTINCT s.id_solicitud) AS solicitudes,
  SUM(ds.cantidad_solicitada) AS total_solicitado
FROM oper_tablas.detalle_solicitud_tb ds
JOIN oper_tablas.solicitud_tb s ON ds.id_solicitud = s.id_solicitud
JOIN alm_tablas.departamentos_tb dep ON s.id_departamento = dep.id_departamento
GROUP BY dep.id_departamento, dep.nombre_departamento
ORDER BY total_entregado DESC;

-- Historico completo por producto 
-- se crea en oper tablas
CREATE OR REPLACE VIEW reporte_kardex_producto_vw AS
SELECT 
  km.id_movimiento,
  km.id_producto,
  km.id_almacen,
  km.cantidad_anterior,
  km.cantidad_nueva,
  km.diferencia,
  km.tipo_movimiento,
  km.usuario_ejecutor,
  km.fecha_movimiento,
  km.referencia
FROM inv_tablas.kardex_movimientos_tb km
ORDER BY km.fecha_movimiento DESC;

-- Job programado para generacion automatica
-- se crea en oper tablas
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_REPORTE_INVENTARIO_DIARIO',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'[
      BEGIN
        -- Aquí podrías, por ejemplo, volcar vistas en tablas de snapshot o hacer inserciones
        INSERT INTO oper_tablas.snapshot_productos_mas_solicitados (
          fecha_generacion, id_producto, nombre_producto, total_solicitado, veces_solicitado
        )
        SELECT SYSDATE, id_producto, nombre_producto, total_solicitado, veces_solicitado
        FROM reporte_productos_mas_solicitados_vw WHERE ROWNUM <= 50;

        INSERT INTO oper_tablas.snapshot_consumo_departamento (
          fecha_generacion, id_departamento, nombre_departamento, total_entregado, solicitudes, total_solicitado
        )
        SELECT SYSDATE, id_departamento, nombre_departamento, total_entregado, solicitudes, total_solicitado
        FROM reporte_consumo_departamento_vw;
      END;
    ]',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=6;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Snapshot diario de reportes de inventario y consumo'
  );
END;
/

-- Consultas de verificacion rapidas
-- se corre en oper tablas
-- Alertas pendientes:
SELECT * FROM oper_tablas.alerta_inventario_tb WHERE procesado = 0 ORDER BY fecha_alerta DESC;
-- Top productos solicitados:
SELECT * FROM reporte_productos_mas_solicitados_vw WHERE ROWNUM <= 10;
-- Consumo por departamento:
SELECT * FROM reporte_consumo_departamento_vw;
-- Kárdex de un producto:
SELECT * FROM reporte_kardex_producto_vw WHERE id_producto = 100;
