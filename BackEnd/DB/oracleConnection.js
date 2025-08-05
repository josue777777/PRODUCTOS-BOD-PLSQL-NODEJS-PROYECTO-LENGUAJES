const oracledb = require("oracledb");

const ORACLE_USER = "G5UF01";
const ORACLE_PASSWORD = "G5_UF01";
const ORACLE_CONNECT_STRING = "localhost:1521/XE";

async function iniciarConexion() {
  try {
    await oracledb.createPool({
      user: ORACLE_USER,
      password: ORACLE_PASSWORD,
      connectString: ORACLE_CONNECT_STRING,
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
