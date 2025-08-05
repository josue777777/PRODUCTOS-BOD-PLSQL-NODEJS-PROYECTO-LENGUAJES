const express = require("express");
const cors = require("cors");
const path = require("path");
const { iniciarConexion, OpenDB } = require("./db/oracleConnection");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const inventarioRoutes = require("./routers/inventarioRoutes");
app.use("/api/inventario", inventarioRoutes);

app.use(express.static(path.join(__dirname, "../FrontEnd")));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../FrontEnd/Views/kardex.html"));
});

app.listen(PORT, () => {
  console.log(`✅ Servidor en http://localhost:${PORT}`);
});

(async () => {
  try {
    await iniciarConexion();

    const conn = await OpenDB();
    const result = await conn.execute(`SELECT USER FROM DUAL`);
    console.log("🙌 Usuario conectado:", result.rows[0][0]);
    await conn.close();
  } catch (err) {
    console.error("❌ Error probando conexión:", err);
  }
})();
