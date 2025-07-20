const express = require("express");
const cors = require("cors");
const path = require("path");
const { iniciarConexion, OpenDB } = require("./db/oracleConnection");

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
const inventarioRoutes = require("./routers/inventarioRoutes");
app.use("/api/inventario", inventarioRoutes);

// Servir estáticos si tienes frontend
app.use(express.static(path.join(__dirname, "../FrontEnd")));

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`✅ Servidor en http://localhost:${PORT}`);
});

// Crear pool y luego probar la conexión
(async () => {
  try {
    // Primero inicia el pool
    await iniciarConexion();
    console.log("✅ Pool de conexión Oracle creado.");

    // Ahora sí, abre una conexión desde el pool
    const conn = await OpenDB();
    const result = await conn.execute(`SELECT USER FROM DUAL`);
    console.log("🙌 Usuario conectado:", result.rows[0][0]);
    await conn.close();
  } catch (err) {
    console.error("❌ Error probando conexión:", err);
  }
})();
