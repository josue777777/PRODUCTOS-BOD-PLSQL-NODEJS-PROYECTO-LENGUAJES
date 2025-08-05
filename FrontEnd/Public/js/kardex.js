// ✅ URL base de tu backend
const API_URL = "http://localhost:3000/api/inventario";

// 🔹 Cargar sucursales al iniciar
window.addEventListener("DOMContentLoaded", async () => {
  try {
    const resp = await fetch(`${API_URL}/sucursales`);
    const data = await resp.json();
    const ddlSucursal = document.getElementById("ddlSucursal");
    ddlSucursal.innerHTML = `<option value="">Seleccione sucursal...</option>`;
    data.forEach((s) => {
      ddlSucursal.innerHTML += `<option value="${s.id_sucursal}">${s.nombre_sucursal}</option>`;
    });
  } catch (err) {
    console.error("❌ Error al cargar sucursales:", err);
    alert("Error al cargar sucursales");
  }
});

// 🔹 Cargar almacenes al seleccionar sucursal
document.getElementById("ddlSucursal").addEventListener("change", async (e) => {
  const idSucursal = e.target.value;
  const ddlAlmacen = document.getElementById("ddlAlmacenGlobal");
  ddlAlmacen.innerHTML = `<option value="">Cargando almacenes...</option>`;

  if (!idSucursal) {
    ddlAlmacen.innerHTML = `<option value="">Seleccione almacén...</option>`;
    return;
  }

  try {
    const resp = await fetch(`${API_URL}/almacenes/${idSucursal}`);
    const data = await resp.json();
    ddlAlmacen.innerHTML = `<option value="">Seleccione almacén...</option>`;
    data.forEach((a) => {
      ddlAlmacen.innerHTML += `<option value="${a.id_almacen}">${a.nombre_almacen}</option>`;
    });
  } catch (err) {
    console.error("❌ Error al cargar almacenes:", err);
    alert("Error al cargar almacenes");
  }
});

// ✅ Registrar ingreso
document.getElementById("formAgregar").addEventListener("submit", async (e) => {
  e.preventDefault();
  const idProducto = document.getElementById("idProductoAgregar").value.trim();
  const idAlmacen = document.getElementById("ddlAlmacenGlobal").value.trim();
  const cantidad = document.getElementById("cantidadAgregar").value.trim();

  if (!idProducto || !idAlmacen || !cantidad) {
    alert("⚠️ Debes llenar todos los campos");
    return;
  }

  try {
    const resp = await fetch(`${API_URL}/agregar`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        idProducto: Number(idProducto),
        idAlmacen: Number(idAlmacen),
        cantidad: Number(cantidad),
      }),
    });
    const data = await resp.json();
    alert(data.mensaje || "Respuesta sin mensaje");
  } catch (err) {
    console.error("❌ Error al agregar:", err);
    alert("Error al agregar producto");
  }
});

// ✅ Registrar salida
document.getElementById("formRebajar").addEventListener("submit", async (e) => {
  e.preventDefault();
  const idProducto = document.getElementById("idProductoRebajar").value.trim();
  const idAlmacen = document.getElementById("ddlAlmacenGlobal").value.trim();
  const cantidad = document.getElementById("cantidadRebajar").value.trim();

  if (!idProducto || !idAlmacen || !cantidad) {
    alert("⚠️ Debes llenar todos los campos");
    return;
  }

  try {
    const resp = await fetch(`${API_URL}/rebajar`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        idProducto: Number(idProducto),
        idAlmacen: Number(idAlmacen),
        cantidad: Number(cantidad),
      }),
    });
    const data = await resp.json();
    alert(data.mensaje || "Respuesta sin mensaje");
  } catch (err) {
    console.error("❌ Error al rebajar:", err);
    alert("Error al rebajar producto");
  }
});

// ✅ Cargar inventario filtrado por almacén
document
  .getElementById("btnCargarProductos")
  .addEventListener("click", async () => {
    const idAlmacen = document.getElementById("ddlAlmacenGlobal").value.trim();
    if (!idAlmacen) {
      alert("⚠️ Seleccione un almacén primero");
      return;
    }

    try {
      const resp = await fetch(`${API_URL}/inventario/${idAlmacen}`);
      const data = await resp.json();
      const tbody = document.getElementById("tablaProductos");
      tbody.innerHTML = "";
      data.forEach((p) => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
        <td>${p.id_producto}</td>
        <td>${p.nombre_producto}</td>
        <td>${p.descripcion}</td>
        <td>${p.precio_unitario}</td>
        <td>${p.nombre_unidad_medida}</td>
        <td>${p.nombre_estado}</td>
        <td>${p.cantidad_disponible}</td>
        </tr>`;
        tbody.appendChild(tr);
      });
    } catch (err) {
      console.error("❌ Error al cargar inventario:", err);
      alert("Error al cargar inventario");
    }
  });
