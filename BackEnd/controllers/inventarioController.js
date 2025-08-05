// BackEnd/controllers/inventarioController.js
const {
  agregarProductoAlmacen,
  rebajarProductoAlmacen,
  listarProductos,
  listarKardexPorProducto,
  listarSucursales,
  listarAlmacenesPorSucursal,
  listarAlmacenesConSucursal,
  listarInventarioPorAlmacen,
} = require("../Models/inventarioModel.js");

// ✅ AGREGAR PRODUCTO
const agregarProducto = async (req, res) => {
  try {
    const { idProducto, idAlmacen, cantidad } = req.body;
    const mensaje = await agregarProductoAlmacen(
      idProducto,
      idAlmacen,
      cantidad
    );
    res.status(200).json({ mensaje });
  } catch (err) {
    console.error("❌ Error en agregarProducto:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ REBAJAR PRODUCTO
const rebajarProducto = async (req, res) => {
  try {
    const { idProducto, idAlmacen, cantidad } = req.body;
    const mensaje = await rebajarProductoAlmacen(
      idProducto,
      idAlmacen,
      cantidad
    );
    res.status(200).json({ mensaje });
  } catch (err) {
    console.error("❌ Error en rebajarProducto:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR PRODUCTOS
const listarTodosLosProductos = async (req, res) => {
  try {
    const data = await listarProductos();
    res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarProductos:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR KARDEX POR PRODUCTO
const listarKardex = async (req, res) => {
  try {
    const { idProducto } = req.params;
    const data = await listarKardexPorProducto(idProducto);
    res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarKardex:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR SUCURSALES
const listarTodasLasSucursales = async (req, res) => {
  try {
    const data = await listarSucursales();
    res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarSucursales:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR ALMACENES POR SUCURSAL
const listarAlmacenes = async (req, res) => {
  try {
    const { idSucursal } = req.params;
    const data = await listarAlmacenesPorSucursal(idSucursal);
    res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarAlmacenes:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR TODOS LOS ALMACENES CON SUCURSAL
const listarTodosLosAlmacenes = async (req, res) => {
  try {
    const data = await listarAlmacenesConSucursal();
    res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarTodosLosAlmacenes:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR INVENTARIO POR ALMACÉN
const listarInventario = async (req, res) => {
  try {
    const { idAlmacen } = req.params;
    const data = await listarInventarioPorAlmacen(idAlmacen);
    res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarInventario:", err);
    res.status(500).json({ mensaje: "Error en servidor" });
  }
};

module.exports = {
  agregarProducto,
  rebajarProducto,
  listarTodosLosProductos,
  listarKardex,
  listarTodasLasSucursales,
  listarAlmacenes,
  listarTodosLosAlmacenes,
  listarInventario,
};
