const oracledb = require("oracledb");
require("dotenv").config();

async function iniciarConexion() {
  try {
    await oracledb.createPool({
      user: process.env.ORACLE_USER, // G5UF01
      password: process.env.ORACLE_PASSWORD, // Contraseña
      connectString: process.env.ORACLE_CONNECT_STRING,
      poolAlias: "default",
    });
    console.log("✅ Pool de conexión Oracle creado.");
  } catch (err) {
    console.error("❌ Error creando pool:", err);
  }
}

async function OpenDB() {
  return await oracledb.getConnection("default");
}

async function ClosePool() {
  try {
    await oracledb.getPool("default").close(0);
    console.log("✅ Pool cerrado.");
  } catch (err) {
    console.error("❌ Error cerrando pool:", err);
  }
}

module.exports = { iniciarConexion, OpenDB, ClosePool };
