const express = require("express");
const router = express.Router();

const {
  agregarProducto,
  rebajarProducto,
  listarTodosLosProductos,
  listarKardex,
  listarTodasLasSucursales,
  listarAlmacenes,
  listarTodosLosAlmacenes,
  listarInventario,
} = require("../controllers/inventarioController");

// RUTAS
router.post("/agregar", agregarProducto);
router.post("/rebajar", rebajarProducto);
router.get("/productos", listarTodosLosProductos);
router.get("/kardex/:idProducto", listarKardex);
router.get("/sucursales", listarTodasLasSucursales);
router.get("/almacenes/:idSucursal", listarAlmacenes);
router.get("/almacenes", listarTodosLosAlmacenes);
router.get("/inventario/:idAlmacen", listarInventario);

module.exports = router;
