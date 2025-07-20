const express = require("express");
const router = express.Router();

// 🔹 Importa todas las funciones desde el controlador
const {
  agregarProductoAlmacen,
  rebajarProductoAlmacen,
  listarProductos,
  listarKardexPorProducto,
  listarSucursales,
  listarAlmacenesPorSucursal,
  listarAlmacenesConSucursal,
  listarInventarioPorAlmacen, // 👈 IMPORTANTE agregar esto
} = require("../controllers/inventarioController");

// ✅ Rutas
router.get("/productos", listarProductos);

router.post("/agregar", agregarProductoAlmacen);

router.post("/rebajar", rebajarProductoAlmacen);

router.get("/kardex/:idProducto", listarKardexPorProducto);

router.get("/sucursales", listarSucursales);

router.get("/almacenes/:idSucursal", listarAlmacenesPorSucursal);

router.get("/almacenes", listarAlmacenesConSucursal);

router.get("/inventario/:idAlmacen", listarInventarioPorAlmacen); // ✅ ya funciona

module.exports = router;
