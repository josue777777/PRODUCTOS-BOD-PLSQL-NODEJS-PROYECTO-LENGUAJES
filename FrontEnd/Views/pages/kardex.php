<?php
require_once $_SERVER["DOCUMENT_ROOT"] . "/Cliente-Servidor-Farmacia/Models/MovimientoModel.php";
require_once $_SERVER["DOCUMENT_ROOT"] . "/Cliente-Servidor-Farmacia/Views/layout.php";

// Ahora obtenemos almacenes activos
$id_almacenes = ObtenerAlmacenesActivos();
?>

<!DOCTYPE html>
<html lang="es">
<?php añadirCSS(); ?>

<body>
    <?php verheader(); ?>
    <?php sidebar(); ?>
    <br><br><br>

    <main class="main-kardex">
        <section class="kardex-container">
            <div style="margin: 10px 50px;">
                <button onclick="toggleConsulta()" id="consultaProductoToggle" class="btn btn-info">
                    🔍 Consultar Producto
                </button>
            </div>

            <!-- CONSULTA DE PRODUCTO -->
            <div id="consultaProducto" class="formulario-kardex" style="display: none;">
                <h2>Consultar Producto</h2>
                <form method="POST" action="../../Controllers/MovimientoController.php" class="form-movimiento">
                    <input type="text" name="txtCodigo" placeholder="Código del producto" required>
                    <select name="ddlAlmacenBuscar" required>
                        <option value="">Seleccione un almacén</option>
                        <?php foreach ($id_almacenes as $alm): ?>
                            <option value="<?= $alm["ID_ALMACEN"] ?>"><?= htmlspecialchars($alm["NOMBRE"]) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <button type="submit" name="btnBuscarProducto">Buscar</button>
                </form>
            </div>

            <!-- INFORMACIÓN DE PRODUCTO Y FORMULARIOS -->
            <?php if (isset($_SESSION["CODIGO_BUSCADO"])): ?>
                <div class="formulario-kardex">
                    <div class="info-producto">
                        <h3><?= $_SESSION["NOMBRE_PRODUCTO"] ?? "Producto Desconocido" ?></h3>
                        <p><strong>Unidad de medida:</strong> <?= $_SESSION["UNIDAD_MEDIDA"] ?? "No definida" ?></p>
                        <p><strong>Código:</strong> <?= $_SESSION["CODIGO_BUSCADO"] ?></p>
                        <p><strong>Stock disponible:</strong> <?= $_SESSION["CANT_DISPONIBLE"] ?? 'No disponible' ?></p>
                        <p><strong>Almacén:</strong>
                            <?php
                            $idAlm = $_SESSION["ALMACEN_BUSCADO"] ?? null;
                            $nombreAlm = "No definido";
                            foreach ($id_almacenes as $alm) {
                                if ($alm["ID_ALMACEN"] == $idAlm) {
                                    $nombreAlm = $alm["NOMBRE"];
                                    break;
                                }
                            }
                            echo $nombreAlm;
                            ?>
                        </p>
                    </div>

                    <!-- REGISTRAR INGRESO -->
                    <h2>Registrar Ingreso</h2>
                    <form method="POST" action="../../Controllers/MovimientoController.php" class="form-movimiento">
                        <input type="text" name="txtCodigo" value="<?= $_SESSION["CODIGO_BUSCADO"] ?>" readonly>
                        <input type="text" name="txtLote" placeholder="Número de lote" required>
                        <h4>Fecha del movimiento</h4>
                        <input type="date" name="txtFecha" required max="<?= date('Y-m-d') ?>">
                        <h4>Fecha de vencimiento</h4>
                        <input type="date" name="txtFechaVencimiento" required>
                        <input type="number" name="txtCantidad" placeholder="Cantidad" required>

                        <label>
                            <input type="checkbox" id="chkDescripcion" data-target="txtDescripcion"> Incluir descripción
                        </label>
                        <input type="text" id="txtDescripcion" name="txtDescripcion" placeholder="Descripción" disabled>

                        <label>
                            <input type="checkbox" id="chkEmpresa" name="chkEmpresa" data-target="txtEmpresa"> Incluir
                            empresa
                        </label>
                        <input type="text" id="txtEmpresa" name="txtEmpresa" placeholder="Empresa" disabled>

                        <select name="ddlAlmacen" required>
                            <option value="">Seleccione un almacén</option>
                            <?php foreach ($id_almacenes as $alm): ?>
                                <option value="<?= $alm["ID_ALMACEN"] ?>" <?= ($alm["ID_ALMACEN"] == ($_SESSION["ALMACEN_BUSCADO"] ?? '')) ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($alm["NOMBRE"]) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                        <button type="submit" name="btnRegistrarMovimiento" class="btn btn-registrar">Registrar</button>
                    </form>

                    <!-- SALIDA AUTOMÁTICA -->
                    <h2>Salida Automática por Lotes</h2>
                    <form method="POST" action="../../Controllers/MovimientoController.php" class="form-movimiento">
                        <input type="text" name="txtCodigo" value="<?= $_SESSION["CODIGO_BUSCADO"] ?>" readonly>
                        <h4>Cantidad total a retirar</h4>
                        <input type="number" name="txtCantidad" placeholder="Cantidad" required>

                        <label>
                            <input type="checkbox" id="chkDescripcionLotes" data-target="txtDescripcionLotes"> Incluir
                            descripción
                        </label>
                        <input type="text" id="txtDescripcionLotes" name="txtDescripcion" placeholder="Descripción"
                            disabled>

                        <label>
                            <input type="checkbox" id="chkEmpresaLotes" name="chkEmpresa" data-target="txtEmpresaLotes">
                            Incluir empresa
                        </label>
                        <input type="text" id="txtEmpresaLotes" name="txtEmpresa" placeholder="Empresa" disabled>

                        <input type="hidden" name="ddlAlmacenBuscar" value="<?= $_SESSION["ALMACEN_BUSCADO"] ?>">

                        <button type="submit" name="btnSeleccionarLotes" class="btn btn-warning">
                            Seleccionar lotes disponibles
                        </button>
                    </form>

                    <!-- MENSAJE DEL SISTEMA -->
                    <?php if (isset($_SESSION["txtMensaje"])): ?>
                        <div class="mensaje-sistema">
                            <?= $_SESSION["txtMensaje"];
                            unset($_SESSION["txtMensaje"]); ?>
                        </div>
                    <?php endif; ?>
                </div>
            <?php endif; ?>

            <!-- HISTORIAL DE MOVIMIENTOS -->
            <?php
            $paginaActual = $_SESSION["PAGINA_ACTUAL"] ?? 0;
            $movimientosPaginados = $_SESSION["MOVIMIENTOS_PAGINADOS"] ?? [];
            $totalPaginas = count($movimientosPaginados);
            $historial = $movimientosPaginados[$paginaActual] ?? [];
            ?>

            <div class="historial-kardex">
                <h2>Historial de Movimientos</h2>
                <h4 style="margin-top: -10px; color: #444;">Página <?= $paginaActual + 1 ?> de
                    <?= max($totalPaginas, 1) ?>
                </h4>

                <?php if (!empty($historial)): ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Tipo</th>
                                <th>Cantidad</th>
                                <th>ID Movimiento</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($historial as $mov): ?>
                                <tr>
                                    <td><?= $mov["FECHA_MOVIMIENTO"] ?></td>
                                    <td><?= $mov["TIPO_MOVIMIENTO"] ?></td>
                                    <td><?= $mov["CANTIDAD"] ?></td>
                                    <td><?= $mov["ID_MOVIMIENTO"] ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php else: ?>
                    <p style="margin-top: 20px; color: #777;">No hay movimientos en esta página.</p>
                <?php endif; ?>

                <form method="POST" action="../../Controllers/MovimientoController.php" class="navegacion-kardex">
                    <button type="submit" name="btnPaginaAnterior" <?= $paginaActual == 0 ? 'disabled' : '' ?>>←
                        Anterior</button>
                    <span>Página <?= $paginaActual + 1 ?> de <?= max($totalPaginas, 1) ?></span>
                    <button type="submit" name="btnPaginaSiguiente" <?= $paginaActual >= $totalPaginas - 1 ? 'disabled' : '' ?>>Siguiente →</button>
                </form>
            </div>
        </section>
    </main>

    <script>
        // Habilitar/deshabilitar inputs por checkbox
        document.querySelectorAll('input[type="checkbox"][data-target]').forEach(chk => {
            chk.addEventListener('change', () => {
                const target = document.getElementById(chk.getAttribute('data-target'));
                if (target) target.disabled = !chk.checked;
            });
        });

        // Mostrar/Ocultar consulta
        function toggleConsulta() {
            const panel = document.getElementById("consultaProducto");
            panel.style.display = panel.style.display === "none" ? "block" : "none";
        }
    </script>
</body>

</html>