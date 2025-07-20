<?php /*
// ===================================
// CONEXIÓN A ORACLE
// ===================================
function OpenDB()
{
// 👇 Cambia G5UF01 y clave según tu usuario final
$conn = oci_connect('G5UF01', 'TU_CLAVE', 'localhost/XEPDB1');
if (!$conn) {
   $e = oci_error();
   throw new Exception('Error de conexión: ' . $e['message']);
}
return $conn;
}

function CloseDB($conn)
{
oci_close($conn);
}

function RegistrarError($e)
{
error_log($e->getMessage());
}

// ===================================
// SP: Insertar Movimiento Individual
// ===================================
function InsertarMovimientoModel($codigo, $lote, $fecha_vencimiento, $fecha, $tipo, $cantidad, $descripcion, $empresa, $id_almacen)
{
try {
   $conn = OpenDB();
   $stid = oci_parse($conn, 'BEGIN G5Desa01.G5_INSERTAR_MOVIMIENTO(:p_codigo,:p_lote,:p_fecha_venc,:p_fecha,:p_tipo,:p_cantidad,:p_desc,:p_empresa,:p_almacen); END;');
   oci_bind_by_name($stid, ':p_codigo', $codigo);
   oci_bind_by_name($stid, ':p_lote', $lote);
   oci_bind_by_name($stid, ':p_fecha_venc', $fecha_vencimiento);
   oci_bind_by_name($stid, ':p_fecha', $fecha);
   oci_bind_by_name($stid, ':p_tipo', $tipo);
   oci_bind_by_name($stid, ':p_cantidad', $cantidad);
   oci_bind_by_name($stid, ':p_desc', $descripcion);
   oci_bind_by_name($stid, ':p_empresa', $empresa);
   oci_bind_by_name($stid, ':p_almacen', $id_almacen);

   $ok = oci_execute($stid);
   oci_free_statement($stid);
   CloseDB($conn);

   return $ok;
} catch (Exception $e) {
   RegistrarError($e);
   return false;
}
}

// ===================================
// SP: Buscar Producto con Stock
// ===================================
function BuscarProductoPorCodigo($codigo, $id_almacen)
{
try {
   $conn = OpenDB();
   $stid = oci_parse($conn, 'BEGIN G5Desa01.G5_BUSCAR_PRODUCTO(:p_codigo,:p_almacen,:p_cursor); END;');
   oci_bind_by_name($stid, ':p_codigo', $codigo);
   oci_bind_by_name($stid, ':p_almacen', $id_almacen);

   $cursor = oci_new_cursor($conn);
   oci_bind_by_name($stid, ':p_cursor', $cursor, -1, OCI_B_CURSOR);

   oci_execute($stid);
   oci_execute($cursor);

   $producto = null;
   if ($row = oci_fetch_assoc($cursor)) {
       $producto = $row;
   }

   oci_free_statement($stid);
   oci_free_statement($cursor);
   CloseDB($conn);

   return $producto;
} catch (Exception $e) {
   RegistrarError($e);
   return null;
}
}

// ===================================
// Vista: Obtener Almacenes Activos
// ===================================
function ObtenerAlmacenesActivos()
{
try {
   $conn = OpenDB();
   // Asegúrate de crear una vista o consulta equivalente
   $stid = oci_parse($conn, 'SELECT id_almacen, nombre_almacen AS NOMBRE FROM alm_tablas.almacen_tb WHERE id_estado = 1');
   oci_execute($stid);

   $almacenes = [];
   while ($row = oci_fetch_assoc($stid)) {
       $almacenes[] = $row;
   }

   oci_free_statement($stid);
   CloseDB($conn);

   return $almacenes;
} catch (Exception $e) {
   RegistrarError($e);
   return [];
}
}

// ===================================
// SP: Historial por Producto/Almacén
// ===================================
function ObtenerHistorialMovimientos($codigo, $id_almacen)
{
try {
   $conn = OpenDB();
   $stid = oci_parse($conn, 'BEGIN G5Desa01.G5_HISTORIAL_MOVS(:p_codigo,:p_almacen,:p_cursor); END;');
   oci_bind_by_name($stid, ':p_codigo', $codigo);
   oci_bind_by_name($stid, ':p_almacen', $id_almacen);

   $cursor = oci_new_cursor($conn);
   oci_bind_by_name($stid, ':p_cursor', $cursor, -1, OCI_B_CURSOR);

   oci_execute($stid);
   oci_execute($cursor);

   $movimientos = [];
   while ($row = oci_fetch_assoc($cursor)) {
       $movimientos[] = $row;
   }

   oci_free_statement($stid);
   oci_free_statement($cursor);
   CloseDB($conn);

   return $movimientos;
} catch (Exception $e) {
   RegistrarError($e);
   return [];
}
}

// ===================================
// SP: Consultar Stock Disponible
// ===================================
function ObtenerStockDisponible($codigo, $id_almacen)
{
try {
   $conn = OpenDB();
   $stid = oci_parse($conn, 'BEGIN G5Desa01.G5_STOCK_DISPONIBLE(:p_codigo,:p_almacen,:p_cursor); END;');
   oci_bind_by_name($stid, ':p_codigo', $codigo);
   oci_bind_by_name($stid, ':p_almacen', $id_almacen);

   $cursor = oci_new_cursor($conn);
   oci_bind_by_name($stid, ':p_cursor', $cursor, -1, OCI_B_CURSOR);

   oci_execute($stid);
   oci_execute($cursor);

   $stock = null;
   if ($row = oci_fetch_assoc($cursor)) {
       $stock = $row['CANTIDAD_DISPONIBLE'];
   }

   oci_free_statement($stid);
   oci_free_statement($cursor);
   CloseDB($conn);

   return $stock;
} catch (Exception $e) {
   RegistrarError($e);
   return null;
}
}

// ===================================
// SP: Generar Salida Automática
// ===================================
function GenerarSalidaPorLotesModel($codigo, $id_almacen, $cantidad_total, $fecha_movimiento, $descripcion, $empresa)
{
try {
   $conn = OpenDB();
   $stid = oci_parse($conn, 'BEGIN G5Desa01.G5_SALIDA_POR_LOTES(:p_codigo,:p_almacen,:p_cant,:p_fecha,:p_desc,:p_empresa); END;');
   oci_bind_by_name($stid, ':p_codigo', $codigo);
   oci_bind_by_name($stid, ':p_almacen', $id_almacen);
   oci_bind_by_name($stid, ':p_cant', $cantidad_total);
   oci_bind_by_name($stid, ':p_fecha', $fecha_movimiento);
   oci_bind_by_name($stid, ':p_desc', $descripcion);
   oci_bind_by_name($stid, ':p_empresa', $empresa);

   $ok = oci_execute($stid);
   oci_free_statement($stid);
   CloseDB($conn);

   return $ok;
} catch (Exception $e) {
   RegistrarError($e);
   return false;
}
}
?>