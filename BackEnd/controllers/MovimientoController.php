 <?php
/* require_once $_SERVER["DOCUMENT_ROOT"] . "/Cliente-Servidor-Farmacia/Models/MovimientoModel.php";

date_default_timezone_set('America/Costa_Rica');
session_start();

// ===================================
// Función auxiliar para paginar movimientos
// ===================================
function paginarMovimientos($movimientos, $porPagina = 5)
{
    $_SESSION["MOVIMIENTOS_PAGINADOS"] = array_chunk($movimientos, $porPagina);
    $_SESSION["PAGINA_ACTUAL"] = 0;
}

// ===================================
// REGISTRAR MOVIMIENTO (Entrada)
// ===================================
if (isset($_POST["btnRegistrarMovimiento"])) {
    $codigo = $_POST["txtCodigo"];
    $lote = $_POST["txtLote"];
    $fecha_vencimiento = $_POST["txtFechaVencimiento"];
    $fecha = $_POST["txtFecha"];
    $hoy = date('Y-m-d');

    if ($fecha > $hoy) {
        $_SESSION["txtMensaje"] = "❌ La fecha del movimiento no puede ser posterior a hoy.";
        header("Location: /Cliente-Servidor-Farmacia/Views/pages/kardex.php");
        exit();
    }

    $tipo = 'Entrada';
    $cantidad = intval($_POST["txtCantidad"]);
    $descripcion = $_POST["txtDescripcion"];
    $empresa = isset($_POST["chkEmpresa"]) ? $_POST["txtEmpresa"] : '';

    if (empty($_POST["ddlAlmacen"])) {
        $_SESSION["txtMensaje"] = "❌ Debe seleccionar un almacén válido.";
        header("Location: /Cliente-Servidor-Farmacia/Views/pages/kardex.php");
        exit();
    }

    $id_almacen = intval($_POST["ddlAlmacen"]);

    $respuesta = InsertarMovimientoModel(
        $codigo,
        $lote,
        $fecha_vencimiento,
        $fecha,
        $tipo,
        $cantidad,
        $descripcion,
        $empresa,
        $id_almacen
    );

    $_SESSION["CANT_DISPONIBLE"] = ObtenerStockDisponible($codigo, $id_almacen);
    $movimientos = ObtenerHistorialMovimientos($codigo, $id_almacen);
    $_SESSION["MOVIMIENTOS"] = $movimientos;
    paginarMovimientos($movimientos);
    $_SESSION["CODIGO_BUSCADO"] = $codigo;
    $_SESSION["ALMACEN_BUSCADO"] = $id_almacen;

    $_SESSION["txtMensaje"] = $respuesta
        ? "✅ Movimiento registrado correctamente."
        : "❌ Error al registrar el movimiento.";

    header("Location: /Cliente-Servidor-Farmacia/Views/pages/kardex.php");
    exit();
}

// ===================================
// BUSCAR PRODUCTO
// ===================================
if (isset($_POST["btnBuscarProducto"])) {
    $codigo = $_POST["txtCodigo"];
    $id_almacen = intval($_POST["ddlAlmacenBuscar"]);

    $producto = BuscarProductoPorCodigo($codigo, $id_almacen);

    if ($producto) {
        $_SESSION["CANT_DISPONIBLE"] = $producto["CANTIDAD_DISPONIBLE"];
        $_SESSION["NOMBRE_PRODUCTO"] = $producto["NOMBRE"];
        $_SESSION["UNIDAD_MEDIDA"] = $producto["UNIDAD"];
    } else {
        $_SESSION["CANT_DISPONIBLE"] = null;
        $_SESSION["NOMBRE_PRODUCTO"] = "Producto no encontrado";
        $_SESSION["UNIDAD_MEDIDA"] = "No definida";
    }

    $movimientos = ObtenerHistorialMovimientos($codigo, $id_almacen);
    $_SESSION["MOVIMIENTOS"] = $movimientos;
    paginarMovimientos($movimientos);
    $_SESSION["CODIGO_BUSCADO"] = $codigo;
    $_SESSION["ALMACEN_BUSCADO"] = $id_almacen;

    header("Location: /Cliente-Servidor-Farmacia/Views/pages/kardex.php");
    exit();
}

// ===================================
// SALIDA AUTOMÁTICA POR LOTES
// ===================================
if (isset($_POST["btnSeleccionarLotes"])) {
    $codigo = $_POST["txtCodigo"];
    $id_almacen = intval($_POST["ddlAlmacenBuscar"]);
    $cantidad_solicitada = intval($_POST["txtCantidad"]);
    $fecha = date('Y-m-d');
    $descripcion = $_POST["txtDescripcion"];
    $empresa = isset($_POST["chkEmpresa"]) ? $_POST["txtEmpresa"] : '';

    $resultado = GenerarSalidaPorLotesModel(
        $codigo,
        $id_almacen,
        $cantidad_solicitada,
        $fecha,
        $descripcion,
        $empresa
    );

    $_SESSION["CANT_DISPONIBLE"] = ObtenerStockDisponible($codigo, $id_almacen);
    $movimientos = ObtenerHistorialMovimientos($codigo, $id_almacen);
    $_SESSION["MOVIMIENTOS"] = $movimientos;
    paginarMovimientos($movimientos);
    $_SESSION["CODIGO_BUSCADO"] = $codigo;
    $_SESSION["ALMACEN_BUSCADO"] = $id_almacen;

    $_SESSION["txtMensaje"] = $resultado
        ? "✅ Se aplicó correctamente la salida automática por lotes."
        : "❌ Error al aplicar salida automática. Verifique stock y datos.";

    header("Location: /Cliente-Servidor-Farmacia/Views/pages/kardex.php");
    exit();
}

// ===================================
// CAMBIAR DE HOJA EN HISTORIAL
// ===================================
if (isset($_POST["btnPaginaAnterior"]) || isset($_POST["btnPaginaSiguiente"])) {
    $paginaActual = $_SESSION["PAGINA_ACTUAL"] ?? 0;
    $totalPaginas = isset($_SESSION["MOVIMIENTOS_PAGINADOS"]) ? count($_SESSION["MOVIMIENTOS_PAGINADOS"]) : 0;

    if (isset($_POST["btnPaginaAnterior"]) && $paginaActual > 0) {
        $_SESSION["PAGINA_ACTUAL"] = $paginaActual - 1;
    } elseif (isset($_POST["btnPaginaSiguiente"]) && $paginaActual < $totalPaginas - 1) {
        $_SESSION["PAGINA_ACTUAL"] = $paginaActual + 1;
    }

    header("Location: /Cliente-Servidor-Farmacia/Views/pages/kardex.php");
    exit();
}
?> 