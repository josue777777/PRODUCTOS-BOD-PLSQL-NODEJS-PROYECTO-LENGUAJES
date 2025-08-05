// BackEnd/models/inventarioModel.js
const oracledb = require("oracledb");
const { OpenDB } = require("../db/oracleConnection");

// Función genérica para ejecutar procedimientos con OUT tipo STRING
async function ejecutarProcedimiento(nombreProcedimiento, binds) {
  const conn = await OpenDB();
  try {
    const result = await conn.execute(
      `BEGIN ${nombreProcedimiento}; END;`,
      binds
    );
    await conn.commit();
    return result;
  } finally {
    await conn.close();
  }
}

// Función para ejecutar procedimientos que devuelven un cursor
async function ejecutarCursor(nombreProcedimiento, binds) {
  const conn = await OpenDB();
  try {
    const result = await conn.execute(
      `BEGIN ${nombreProcedimiento}; END;`,
      binds
    );
    const resultSet = result.outBinds.cursor;
    const rows = await resultSet.getRows();
    await resultSet.close();
    return rows;
  } finally {
    await conn.close();
  }
}

async function agregarProductoAlmacen(idProducto, idAlmacen, cantidad) {
  const binds = {
    idProducto: { val: idProducto, dir: oracledb.BIND_IN },
    idAlmacen: { val: idAlmacen, dir: oracledb.BIND_IN },
    cantidad: { val: cantidad, dir: oracledb.BIND_IN },
    resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 100 },
  };
  const result = await ejecutarProcedimiento(
    "G5Desa01.G5_AGREGAR_PRODUCTO_ALMACEN(:idProducto,:idAlmacen,:cantidad,:resultado)",
    binds
  );
  return result.outBinds.resultado;
}

async function rebajarProductoAlmacen(idProducto, idAlmacen, cantidad) {
  const binds = {
    idProducto: { val: idProducto, dir: oracledb.BIND_IN },
    idAlmacen: { val: idAlmacen, dir: oracledb.BIND_IN },
    cantidad: { val: cantidad, dir: oracledb.BIND_IN },
    resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 100 },
  };
  const result = await ejecutarProcedimiento(
    "G5Desa01.G5_REBAJAR_PRODUCTO_ALMACEN(:idProducto,:idAlmacen,:cantidad,:resultado)",
    binds
  );
  return result.outBinds.resultado;
}

async function listarProductos() {
  const rows = await ejecutarCursor("G5Desa01.G5_LISTAR_PRODUCTOS(:cursor)", {
    cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
  });
  return rows.map((r) => ({
    id_producto: r[0],
    nombre_producto: r[1],
    descripcion: r[2],
    precio_unitario: r[3],
    nombre_unidad_medida: r[4],
    nombre_estado: r[5],
  }));
}

async function listarKardexPorProducto(idProducto) {
  const rows = await ejecutarCursor(
    "G5Desa01.G5_LISTAR_KARDEX_PRODUCTO(:idProducto,:cursor)",
    {
      idProducto: { val: idProducto, dir: oracledb.BIND_IN },
      cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
    }
  );
  return rows.map((r) => ({
    id_inventario: r[0],
    id_producto: r[1],
    id_almacen: r[2],
    cantidad_disponible: r[3],
    stock_minimo: r[4],
    stock_maximo: r[5],
    id_estado: r[6],
  }));
}

async function listarSucursales() {
  const rows = await ejecutarCursor("G5Desa01.G5_LISTAR_SUCURSALES(:cursor)", {
    cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
  });
  return rows.map((r) => ({
    id_sucursal: r[0],
    nombre_sucursal: r[1],
  }));
}

async function listarAlmacenesPorSucursal(idSucursal) {
  const rows = await ejecutarCursor(
    "G5Desa01.G5_LISTAR_ALMACENES_POR_SUCURSAL(:idSucursal,:cursor)",
    {
      idSucursal: { val: idSucursal, dir: oracledb.BIND_IN },
      cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
    }
  );
  return rows.map((r) => ({
    id_almacen: r[0],
    nombre_almacen: r[1],
  }));
}

async function listarAlmacenesConSucursal() {
  const rows = await ejecutarCursor(
    "G5Desa01.G5_LISTAR_ALMACENES_CON_SUCURSAL(:cursor)",
    {
      cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
    }
  );
  return rows.map((r) => ({
    id_almacen: r[0],
    nombre_almacen: r[1],
    nombre_sucursal: r[2],
    id_estado: r[3],
  }));
}

async function listarInventarioPorAlmacen(idAlmacen) {
  const rows = await ejecutarCursor(
    "G5DESA01.G5_LISTAR_INVENTARIO_ALMACEN(:idAlmacen, :cursor)",
    {
      idAlmacen: { val: idAlmacen, dir: oracledb.BIND_IN },
      cursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
    }
  );
  return rows.map((r) => ({
    id_inventario: r[0], // no se usa por ahora
    id_producto: r[1],
    nombre_producto: r[2],
    descripcion: r[3],
    precio_unitario: r[4],
    nombre_unidad_medida: r[5],
    nombre_estado: r[6],
    cantidad_disponible: r[7],
  }));
}

module.exports = {
  ejecutarProcedimiento,
  ejecutarCursor,
  agregarProductoAlmacen,
  rebajarProductoAlmacen,
  listarProductos,
  listarKardexPorProducto,
  listarSucursales,
  listarAlmacenesPorSucursal,
  listarAlmacenesConSucursal,
  listarInventarioPorAlmacen,
};
