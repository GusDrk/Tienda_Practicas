const ADMIN_USER = "Admin";
const ADMIN_PASS = "12345";
const DATA_VERSION = "2026-11-26-v3";
const VERSION_KEY = "decorarte_data_version";
const CATALOGOS_KEY = "decorarte_catalogos";
const PRODUCTOS_KEY = "decorarte_productos";

let catalogos = [];
let productos = [];
let imagenBase64 = "";
let busquedaAdmin = "";
let filtroCatAdmin = "todos";

const loginSection = document.getElementById("admin-login");
const adminPanel = document.getElementById("admin-panel");
const logoutBtn = document.getElementById("logout-btn");
const loginForm = document.getElementById("login-form");

const productForm = document.getElementById("product-form");
const productFormTitle = document.getElementById("product-form-title");
const cancelEditBtn = document.getElementById("cancel-edit-btn");
const prodCategoriaSelect = document.getElementById("prod-categoria");
const subcatSuggestions = document.getElementById("subcat-suggestions");
const imgFileInput = document.getElementById("prod-imagen-file");
const imgUrlInput = document.getElementById("prod-imagen-url");
const imgPreviewWrap = document.getElementById("img-preview-wrap");
const imgPreview = document.getElementById("img-preview");

const catalogForm = document.getElementById("catalog-form");
const catalogsList = document.getElementById("catalogs-list");
const productsBody = document.getElementById("admin-products-body");

const searchForm = document.getElementById("admin-search-form");
const searchInput = document.getElementById("admin-search-input");
const filterCatSelect = document.getElementById("admin-filter-cat");
const clearSearchBtn = document.getElementById("admin-clear-search");
const resultCountEl = document.getElementById("admin-result-count");

function verificarSesion() {
  const autenticado = sessionStorage.getItem("decorarte_admin_auth") === "true";
  loginSection.classList.toggle("hidden", autenticado);
  adminPanel.classList.toggle("hidden", !autenticado);
  logoutBtn.classList.toggle("hidden", !autenticado);
  if (autenticado) cargarDatos();
}

loginForm.addEventListener("submit", (e) => {
  e.preventDefault();
  const user = document.getElementById("admin-user").value.trim();
  const pass = document.getElementById("admin-pass").value;
  if (user === ADMIN_USER && pass === ADMIN_PASS) {
    sessionStorage.setItem("decorarte_admin_auth", "true");
    verificarSesion();
  } else {
    alert("Usuario o contraseña incorrectos.");
  }
});

logoutBtn.addEventListener("click", () => {
  sessionStorage.removeItem("decorarte_admin_auth");
  verificarSesion();
});

async function cargarDatos() {
  if (localStorage.getItem(VERSION_KEY) !== DATA_VERSION) {
    localStorage.removeItem(CATALOGOS_KEY);
    localStorage.removeItem(PRODUCTOS_KEY);
    localStorage.setItem(VERSION_KEY, DATA_VERSION);
  }

  const catGuardados = localStorage.getItem(CATALOGOS_KEY);
  const prodGuardados = localStorage.getItem(PRODUCTOS_KEY);

  if (catGuardados) {
    catalogos = JSON.parse(catGuardados);
  } else {
    const res = await fetch(`data/catalogos.json?v=${DATA_VERSION}`);
    catalogos = await res.json();
    localStorage.setItem(CATALOGOS_KEY, JSON.stringify(catalogos));
  }

  if (prodGuardados) {
    productos = JSON.parse(prodGuardados);
  } else {
    const res = await fetch(`data/productos.json?v=${DATA_VERSION}`);
    productos = await res.json();
    localStorage.setItem(PRODUCTOS_KEY, JSON.stringify(productos));
  }

  renderCatalogos();
  renderProductos();
  actualizarKPIs();
}

function guardarTodo() {
  localStorage.setItem(VERSION_KEY, DATA_VERSION);
  localStorage.setItem(CATALOGOS_KEY, JSON.stringify(catalogos));
  localStorage.setItem(PRODUCTOS_KEY, JSON.stringify(productos));
  actualizarKPIs();
}

function actualizarKPIs() {
  document.getElementById("kpi-total").textContent = productos.length;
  document.getElementById("kpi-ofertas").textContent = productos.filter((p) => p.en_oferta).length;
  document.getElementById("kpi-catalogos").textContent = catalogos.filter((c) => c.habilitado !== false).length;
  document.getElementById("kpi-bajo").textContent = productos.filter((p) => Number(p.cantidad) <= 3).length;
}

function renderCatalogos() {
  prodCategoriaSelect.innerHTML = catalogos
    .map((c) => `<option value="${c.slug}">${c.nombre}${c.habilitado ? "" : " (Deshabilitado)"}</option>`)
    .join("");

  const catAnterior = filterCatSelect.value || "todos";
  filterCatSelect.innerHTML =
    `<option value="todos">Todos los catálogos</option>` +
    catalogos.map((c) => `<option value="${c.slug}">${c.nombre}</option>`).join("");
  filterCatSelect.value = catAnterior;

  actualizarSugerenciasSubcat();

  catalogsList.innerHTML = catalogos
    .map(
      (c, idx) => `
      <div class="catalog-list-item">
        <div>
          <strong>${c.nombre}</strong>
          <span class="status-pill ${c.habilitado ? "status-on" : "status-off"}">
            ${c.habilitado ? "Habilitado" : "Deshabilitado"}
          </span>
          ${c.es_temporada ? '<small style="color:var(--dorado-oscuro);margin-left:4px;">· Temporada</small>' : ""}
        </div>
        <button class="btn btn-outline btn-sm" onclick="toggleCatalogo(${idx})">
          ${c.habilitado ? "Deshabilitar" : "Habilitar"}
        </button>
      </div>
    `
    )
    .join("");
}

function actualizarSugerenciasSubcat() {
  const slug = prodCategoriaSelect.value;
  const cat = catalogos.find((c) => c.slug === slug);
  subcatSuggestions.innerHTML = (cat?.subcategorias || [])
    .map((s) => `<option value="${s}"></option>`)
    .join("");
}

prodCategoriaSelect.addEventListener("change", actualizarSugerenciasSubcat);

function toggleCatalogo(idx) {
  catalogos[idx].habilitado = !catalogos[idx].habilitado;
  guardarTodo();
  renderCatalogos();
}

catalogForm.addEventListener("submit", (e) => {
  e.preventDefault();
  const nombre = document.getElementById("cat-nombre").value.trim();
  const subcatsRaw = document.getElementById("cat-subcats").value.trim();
  const esTemporada = document.getElementById("cat-temporada").checked;

  const slug = nombre
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");

  if (catalogos.some((c) => c.slug === slug)) {
    alert("Ya existe un catálogo con ese nombre.");
    return;
  }

  const subcategorias = subcatsRaw
    ? subcatsRaw.split(",").map((s) => s.trim()).filter(Boolean)
    : [];

  catalogos.push({
    slug,
    nombre,
    habilitado: true,
    es_temporada: esTemporada,
    subcategorias,
  });

  guardarTodo();
  renderCatalogos();
  catalogForm.reset();
});

imgFileInput.addEventListener("change", (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    imagenBase64 = reader.result;
    imgPreview.src = imagenBase64;
    imgPreviewWrap.classList.remove("hidden");
  };
  reader.readAsDataURL(file);
});

imgUrlInput.addEventListener("input", (e) => {
  if (e.target.value.trim()) {
    imagenBase64 = "";
    imgPreview.src = e.target.value.trim();
    imgPreviewWrap.classList.remove("hidden");
  }
});

productForm.addEventListener("submit", (e) => {
  e.preventDefault();
  const idEdit = document.getElementById("prod-id").value;
  const codigo = document.getElementById("prod-codigo").value.trim();
  const nombre = document.getElementById("prod-nombre").value.trim();
  const descripcion = document.getElementById("prod-descripcion").value.trim();
  const categoria = prodCategoriaSelect.value;
  const subcategoria = document.getElementById("prod-subcategoria").value.trim();
  const precio = parseFloat(document.getElementById("prod-precio").value);
  const precioAnteriorRaw = document.getElementById("prod-precio-anterior").value;
  const precio_anterior = precioAnteriorRaw ? parseFloat(precioAnteriorRaw) : null;
  const cantidad = parseInt(document.getElementById("prod-cantidad").value, 10);
  const en_oferta = document.getElementById("prod-oferta").checked;
  const imagen =
    imagenBase64 ||
    imgUrlInput.value.trim() ||
    "https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=600&q=80";

  const catObj = catalogos.find((c) => c.slug === categoria);
  const temporada = Boolean(catObj?.es_temporada);

  if (idEdit) {
    const idx = productos.findIndex((p) => p.id === Number(idEdit));
    if (idx !== -1) {
      productos[idx] = {
        ...productos[idx],
        codigo,
        nombre,
        descripcion,
        categoria,
        subcategoria,
        precio,
        precio_anterior,
        en_oferta,
        cantidad,
        temporada,
        imagen,
      };
    }
  } else {
    const nuevoId = productos.length ? Math.max(...productos.map((p) => p.id)) + 1 : 1;
    productos.unshift({
      id: nuevoId,
      codigo,
      nombre,
      descripcion,
      categoria,
      subcategoria,
      precio,
      precio_anterior,
      en_oferta,
      cantidad,
      temporada,
      imagen,
    });
  }

  guardarTodo();
  renderProductos();
  limpiarFormularioProducto();
});

function editarProducto(id) {
  const p = productos.find((item) => item.id === id);
  if (!p) return;

  document.getElementById("prod-id").value = p.id;
  document.getElementById("prod-codigo").value = p.codigo || "";
  document.getElementById("prod-nombre").value = p.nombre;
  document.getElementById("prod-descripcion").value = p.descripcion;
  prodCategoriaSelect.value = p.categoria;
  actualizarSugerenciasSubcat();
  document.getElementById("prod-subcategoria").value = p.subcategoria || "";
  document.getElementById("prod-precio").value = p.precio;
  document.getElementById("prod-precio-anterior").value = p.precio_anterior || "";
  document.getElementById("prod-cantidad").value = p.cantidad;
  document.getElementById("prod-oferta").checked = Boolean(p.en_oferta);
  imgUrlInput.value = p.imagen.startsWith("data:") ? "" : p.imagen;
  imagenBase64 = p.imagen.startsWith("data:") ? p.imagen : "";
  imgPreview.src = p.imagen;
  imgPreviewWrap.classList.remove("hidden");

  productFormTitle.textContent = "Editar Producto";
  cancelEditBtn.classList.remove("hidden");
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function eliminarProducto(id) {
  if (!confirm("¿Seguro que deseas eliminar este producto?")) return;
  productos = productos.filter((p) => p.id !== id);
  guardarTodo();
  renderProductos();
}

function limpiarFormularioProducto() {
  productForm.reset();
  document.getElementById("prod-id").value = "";
  imagenBase64 = "";
  imgPreviewWrap.classList.add("hidden");
  productFormTitle.textContent = "Dar de Alta Producto";
  cancelEditBtn.classList.add("hidden");
}

cancelEditBtn.addEventListener("click", limpiarFormularioProducto);

searchForm.addEventListener("submit", (e) => {
  e.preventDefault();
  busquedaAdmin = searchInput.value.trim().toLowerCase();
  filtroCatAdmin = filterCatSelect.value;
  renderProductos();
});

searchInput.addEventListener("input", (e) => {
  busquedaAdmin = e.target.value.trim().toLowerCase();
  renderProductos();
});

filterCatSelect.addEventListener("change", (e) => {
  filtroCatAdmin = e.target.value;
  renderProductos();
});

clearSearchBtn.addEventListener("click", () => {
  searchInput.value = "";
  filterCatSelect.value = "todos";
  busquedaAdmin = "";
  filtroCatAdmin = "todos";
  renderProductos();
});

function renderProductos() {
  const filtrados = productos.filter((p) => {
    const coincideCat = filtroCatAdmin === "todos" || p.categoria === filtroCatAdmin;
    const coincideTexto =
      !busquedaAdmin ||
      p.nombre.toLowerCase().includes(busquedaAdmin) ||
      (p.codigo || "").toLowerCase().includes(busquedaAdmin) ||
      (p.subcategoria || "").toLowerCase().includes(busquedaAdmin) ||
      (p.descripcion || "").toLowerCase().includes(busquedaAdmin);
    return coincideCat && coincideTexto;
  });

  resultCountEl.textContent = `${filtrados.length} artículo${filtrados.length === 1 ? "" : "s"}`;

  if (filtrados.length === 0) {
    productsBody.innerHTML = `<tr><td colspan="7" style="text-align:center;color:var(--texto-suave);padding:1.5rem;">No se encontraron productos con ese criterio.</td></tr>`;
    return;
  }

  productsBody.innerHTML = filtrados
    .map(
      (p) => `
      <tr>
        <td><img src="${p.imagen}" class="admin-thumb" alt="${p.nombre}" loading="lazy" /></td>
        <td><code class="admin-sku-code">${p.codigo || "-"}</code></td>
        <td>
          <div class="admin-prod-name">${p.nombre}</div>
          ${p.en_oferta ? '<span class="admin-offer-pill">Oferta</span>' : ""}
        </td>
        <td>
          <span class="admin-cat-text">${p.categoria}</span>
          ${p.subcategoria ? `<div class="admin-subcat-text">${p.subcategoria}</div>` : ""}
        </td>
        <td><strong>$${Number(p.precio).toLocaleString("es-MX")}</strong></td>
        <td>
          <span class="status-pill ${Number(p.cantidad) <= 3 ? "status-off" : "status-on"}">
            ${p.cantidad}
          </span>
        </td>
        <td>
          <div class="admin-row-actions">
            <button class="btn btn-outline btn-xs" onclick="editarProducto(${p.id})">Editar</button>
            <button class="btn btn-danger btn-xs" onclick="eliminarProducto(${p.id})">Borrar</button>
          </div>
        </td>
      </tr>
    `
    )
    .join("");
}

function descargarJSON(nombreArchivo, datos) {
  const blob = new Blob([JSON.stringify(datos, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = nombreArchivo;
  a.click();
  URL.revokeObjectURL(url);
}

document.getElementById("export-prod-btn").addEventListener("click", () => {
  descargarJSON("productos.json", productos);
});

document.getElementById("export-cat-btn").addEventListener("click", () => {
  descargarJSON("catalogos.json", catalogos);
});

document.getElementById("reset-data-btn").addEventListener("click", async () => {
  if (!confirm("¿Restablecer productos y catálogos a los datos de ejemplo?")) return;
  localStorage.removeItem(CATALOGOS_KEY);
  localStorage.removeItem(PRODUCTOS_KEY);
  await cargarDatos();
});

verificarSesion();
