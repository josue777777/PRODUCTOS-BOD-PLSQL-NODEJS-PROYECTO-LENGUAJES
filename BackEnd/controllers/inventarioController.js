const oracledb = require("oracledb");
const { OpenDB } = require("../db/oracleConnection");

// ✅ AGREGAR PRODUCTO
const agregarProductoAlmacen = async (req, res) => {
  const { idProducto, idAlmacen, cantidad } = req.body;
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_AGREGAR_PRODUCTO_ALMACEN(:idProducto,:idAlmacen,:cantidad,:resultado); END;`,
      {
        idProducto: { val: idProducto, dir: oracledb.BIND_IN },
        idAlmacen: { val: idAlmacen, dir: oracledb.BIND_IN },
        cantidad: { val: cantidad, dir: oracledb.BIND_IN },
        resultado: {
          dir: oracledb.BIND_OUT,
          type: oracledb.STRING,
          maxSize: 100,
        },
      }
    );
    await conn.commit();
    await conn.close();
    return res.status(200).json({ mensaje: result.outBinds.resultado });
  } catch (err) {
    console.error("❌ Error en agregarProductoAlmacen:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ REBAJAR PRODUCTO
const rebajarProductoAlmacen = async (req, res) => {
  const { idProducto, idAlmacen, cantidad } = req.body;
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_REBAJAR_PRODUCTO_ALMACEN(:idProducto,:idAlmacen,:cantidad,:resultado); END;`,
      {
        idProducto: { val: idProducto, dir: oracledb.BIND_IN },
        idAlmacen: { val: idAlmacen, dir: oracledb.BIND_IN },
        cantidad: { val: cantidad, dir: oracledb.BIND_IN },
        resultado: {
          dir: oracledb.BIND_OUT,
          type: oracledb.STRING,
          maxSize: 100,
        },
      }
    );
    await conn.commit();
    await conn.close();
    return res.status(200).json({ mensaje: result.outBinds.resultado });
  } catch (err) {
    console.error("❌ Error en rebajarProductoAlmacen:", err);
    return res
      .status(500)
      .json({ mensaje: "Error en servidor", detalle: err.message });
  }
};

// ✅ LISTAR PRODUCTOS (con nombre de unidad y nombre de estado)
const listarProductos = async (req, res) => {
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_LISTAR_PRODUCTOS(:cursor); END;`,
      { cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR } }
    );

    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    await conn.close();

    const data = rows.map((r) => ({
      id_producto: r[0],
      nombre_producto: r[1],
      descripcion: r[2],
      precio_unitario: r[3],
      nombre_unidad_medida: r[4],
      nombre_estado: r[5],
    }));

    return res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarProductos:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR INVENTARIO POR PRODUCTO (Kardex)
const listarKardexPorProducto = async (req, res) => {
  const { idProducto } = req.params;
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_LISTAR_KARDEX_PRODUCTO(:idProducto,:cursor); END;`,
      {
        idProducto: { val: idProducto, dir: oracledb.BIND_IN },
        cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
      }
    );

    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    await conn.close();

    const data = rows.map((r) => ({
      id_inventario: r[0],
      id_producto: r[1],
      id_almacen: r[2],
      cantidad_disponible: r[3],
      stock_minimo: r[4],
      stock_maximo: r[5],
      id_estado: r[6],
    }));
    return res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarKardexPorProducto:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR SUCURSALES
const listarSucursales = async (req, res) => {
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_LISTAR_SUCURSALES(:cursor); END;`,
      { cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR } }
    );

    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    await conn.close();

    const data = rows.map((r) => ({
      id_sucursal: r[0],
      nombre_sucursal: r[1],
    }));
    return res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarSucursales:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR ALMACENES POR SUCURSAL
const listarAlmacenesPorSucursal = async (req, res) => {
  const { idSucursal } = req.params;
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_LISTAR_ALMACENES_POR_SUCURSAL(:idSucursal,:cursor); END;`,
      {
        idSucursal: { val: idSucursal, dir: oracledb.BIND_IN },
        cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
      }
    );

    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    await conn.close();

    const data = rows.map((r) => ({
      id_almacen: r[0],
      nombre_almacen: r[1],
    }));
    return res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarAlmacenesPorSucursal:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR TODOS LOS ALMACENES CON SUCURSAL
const listarAlmacenesConSucursal = async (req, res) => {
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5Desa01.G5_LISTAR_ALMACENES_CON_SUCURSAL(:cursor); END;`,
      { cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR } }
    );

    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    await conn.close();

    const data = rows.map((r) => ({
      id_almacen: r[0],
      nombre_almacen: r[1],
      nombre_sucursal: r[2],
      id_estado: r[3],
    }));
    return res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarAlmacenesConSucursal:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

// ✅ LISTAR INVENTARIO POR ALMACÉN
const listarInventarioPorAlmacen = async (req, res) => {
  const { idAlmacen } = req.params;
  try {
    const conn = await OpenDB();
    const result = await conn.execute(
      `BEGIN G5DESA01.G5_LISTAR_INVENTARIO_ALMACEN(:idAlmacen, :cursor); END;`,
      {
        idAlmacen: { val: idAlmacen, dir: oracledb.BIND_IN },
        cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
      }
    );

    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    await conn.close();

    const data = rows.map((r) => ({
      id_inventario: r[0],
      nombre_producto: r[1],
      descripcion: r[2],
      precio_unitario: r[3],
      nombre_unidad_medida: r[4],
      nombre_estado: r[5],
      cantidad_disponible: r[6],
    }));

    return res.status(200).json(data);
  } catch (err) {
    console.error("❌ Error en listarInventarioPorAlmacen:", err);
    return res.status(500).json({ mensaje: "Error en servidor" });
  }
};

module.exports = {
  agregarProductoAlmacen,
  rebajarProductoAlmacen,
  listarProductos,
  listarKardexPorProducto,
  listarSucursales,
  listarAlmacenesPorSucursal,
  listarAlmacenesConSucursal,
  listarInventarioPorAlmacen,
};
