const TELEFONO_TIENDA = "527716702732";

const CATALOGOS_KEY = "decorarte_catalogos";
const PRODUCTOS_KEY = "decorarte_productos";
const CARRITO_KEY = "decorarte_carrito";

let catalogos = [];
let productos = [];
let categoriaActual = "todos";
let subcategoriaActual = "todas";
let textoBusqueda = "";
let carrito = JSON.parse(localStorage.getItem(CARRITO_KEY) || "[]");

const catalogGrid = document.getElementById("catalog-grid");
const offersGrid = document.getElementById("offers-grid");
const searchInput = document.getElementById("search-input");
const filterButtonsContainer = document.getElementById("filter-buttons");
const subcategoryBar = document.getElementById("subcategory-bar");
const navidadSection = document.getElementById("temporada");
const navNavidadLink = document.getElementById("nav-navidad-link");
const navidadSubcatsContainer = document.getElementById("navidad-subcats");

const cartCount = document.getElementById("cart-count");
const cartDrawer = document.getElementById("cart-drawer");
const cartOverlay = document.getElementById("cart-overlay");
const cartItemsContainer = document.getElementById("cart-items");
const cartTotalEl = document.getElementById("cart-total");
const checkoutForm = document.getElementById("checkout-form");
const domicilioFields = document.getElementById("domicilio-fields");
const direccionInput = document.getElementById("cliente-direccion");
const orderModal = document.getElementById("order-modal");
const orderSummaryEl = document.getElementById("order-summary");
const whatsappOrderLink = document.getElementById("whatsapp-order-link");

async function cargarDatos() {
  const catGuardados = localStorage.getItem(CATALOGOS_KEY);
  const prodGuardados = localStorage.getItem(PRODUCTOS_KEY);

  if (catGuardados) {
    catalogos = JSON.parse(catGuardados);
  } else {
    try {
      const res = await fetch("data/catalogos.json");
      catalogos = await res.json();
    } catch {
      catalogos = [];
    }
  }

  if (prodGuardados) {
    productos = JSON.parse(prodGuardados);
  } else {
    try {
      const res = await fetch("data/productos.json");
      productos = await res.json();
    } catch {
      productos = [];
    }
  }

  inicializarVista();
}

function catalogosHabilitados() {
  return catalogos.filter((c) => c.habilitado !== false);
}

function esCategoriaHabilitada(slug) {
  return catalogosHabilitados().some((c) => c.slug === slug);
}

function formatearPrecio(monto) {
  return `$${Number(monto).toLocaleString("es-MX", { minimumFractionDigits: 2 })} MXN`;
}

function inicializarVista() {
  const navidadCat = catalogos.find((c) => c.slug === "navidad");
  const navidadActiva = navidadCat && navidadCat.habilitado !== false;

  navidadSection.classList.toggle("hidden", !navidadActiva);
  if (navNavidadLink) navNavidadLink.classList.toggle("hidden", !navidadActiva);

  if (navidadActiva && navidadCat.subcategorias?.length) {
    navidadSubcatsContainer.innerHTML = navidadCat.subcategorias
      .map(
        (sub) =>
          `<button class="subcat-pill" onclick="filtrarNavidadSubcat('${sub.replace(/'/g, "\\'")}')">${sub}</button>`
      )
      .join("");
  }

  renderBotonesFiltro();
  renderOfertas();
  renderCatalogo();
}

function renderBotonesFiltro() {
  const habilitados = catalogosHabilitados();
  const botones = [
    `<button class="filter-btn ${categoriaActual === "todos" ? "active" : ""}" data-category="todos">Todos</button>`,
    `<button class="filter-btn ${categoriaActual === "ofertas" ? "active" : ""}" data-category="ofertas">Ofertas</button>`,
    ...habilitados.map(
      (c) =>
        `<button class="filter-btn ${categoriaActual === c.slug ? "active" : ""}" data-category="${c.slug}">${c.nombre}</button>`
    ),
  ];

  filterButtonsContainer.innerHTML = botones.join("");
  filterButtonsContainer.querySelectorAll(".filter-btn").forEach((btn) => {
    btn.addEventListener("click", () => filtrarPorCategoria(btn.dataset.category));
  });
}

function renderSubcategoriasBar() {
  const catObj = catalogosHabilitados().find((c) => c.slug === categoriaActual);
  if (!catObj || !catObj.subcategorias || catObj.subcategorias.length === 0) {
    subcategoryBar.classList.add("hidden");
    subcategoryBar.innerHTML = "";
    return;
  }

  subcategoryBar.classList.remove("hidden");
  const pills = [
    `<span class="subcategory-bar-label">Catálogo interno de ${catObj.nombre}:</span>`,
    `<button class="subcat-pill ${subcategoriaActual === "todas" ? "active" : ""}" onclick="seleccionarSubcategoria('todas')">Todo</button>`,
    ...catObj.subcategorias.map(
      (sub) =>
        `<button class="subcat-pill ${subcategoriaActual === sub ? "active" : ""}" onclick="seleccionarSubcategoria('${sub.replace(/'/g, "\\'")}')">${sub}</button>`
    ),
  ];
  subcategoryBar.innerHTML = pills.join("");
}

function crearTarjetaProducto(p) {
  const agotado = Number(p.cantidad) <= 0;
  return `
    <article class="product-card">
      <div class="product-img-wrap">
        <img src="${p.imagen}" alt="${p.nombre}" loading="lazy" />
        <div class="tag-stack">
          ${p.en_oferta ? '<span class="offer-tag">Oferta</span>' : ""}
          ${p.temporada ? '<span class="season-tag">Temporada</span>' : ""}
        </div>
      </div>
      <div class="product-body">
        <div class="product-meta">
          <span class="product-cat">${p.subcategoria || p.categoria}</span>
          <span class="product-sku">${p.codigo || ""}</span>
        </div>
        <h3>${p.nombre}</h3>
        <p class="product-desc">${p.descripcion}</p>
        <p class="product-stock">${agotado ? "Agotado" : `Disponibles: ${p.cantidad}`}</p>
        <div class="product-footer">
          <div class="price-box">
            ${p.en_oferta && p.precio_anterior ? `<span class="price-old">${formatearPrecio(p.precio_anterior)}</span>` : ""}
            <span class="product-price">${formatearPrecio(p.precio)}</span>
          </div>
          <button class="add-btn" onclick="agregarAlCarrito(${p.id})" ${agotado ? "disabled" : ""}>
            ${agotado ? "Sin stock" : "Agregar"}
          </button>
        </div>
      </div>
    </article>
  `;
}

function renderOfertas() {
  const enOferta = productos.filter(
    (p) => p.en_oferta && esCategoriaHabilitada(p.categoria)
  );
  if (enOferta.length === 0) {
    offersGrid.innerHTML = `<p style="grid-column:1/-1;text-align:center;color:var(--texto-suave);">Por el momento no hay ofertas activas.</p>`;
    return;
  }
  offersGrid.innerHTML = enOferta.map(crearTarjetaProducto).join("");
}

function renderCatalogo() {
  renderSubcategoriasBar();

  const filtrados = productos.filter((p) => {
    if (!esCategoriaHabilitada(p.categoria)) return false;

    const coincideCat =
      categoriaActual === "todos" ||
      (categoriaActual === "ofertas" ? p.en_oferta : p.categoria === categoriaActual);

    const coincideSub =
      subcategoriaActual === "todas" || p.subcategoria === subcategoriaActual;

    const coincideTexto =
      p.nombre.toLowerCase().includes(textoBusqueda) ||
      p.descripcion.toLowerCase().includes(textoBusqueda) ||
      (p.codigo || "").toLowerCase().includes(textoBusqueda);

    return coincideCat && coincideSub && coincideTexto;
  });

  if (filtrados.length === 0) {
    catalogGrid.innerHTML = `<p style="grid-column:1/-1;text-align:center;color:var(--texto-suave);">No se encontraron artículos con ese filtro.</p>`;
    return;
  }

  catalogGrid.innerHTML = filtrados.map(crearTarjetaProducto).join("");
}

function filtrarPorCategoria(cat, hacerScroll = false) {
  categoriaActual = cat;
  subcategoriaActual = "todas";
  renderBotonesFiltro();
  renderCatalogo();
  if (hacerScroll) {
    document.getElementById("catalogo").scrollIntoView({ behavior: "smooth" });
  }
}

function seleccionarSubcategoria(sub) {
  subcategoriaActual = sub;
  renderCatalogo();
}

function filtrarNavidadSubcat(sub) {
  categoriaActual = "navidad";
  subcategoriaActual = sub;
  renderBotonesFiltro();
  renderCatalogo();
  document.getElementById("catalogo").scrollIntoView({ behavior: "smooth" });
}

searchInput.addEventListener("input", (e) => {
  textoBusqueda = e.target.value.trim().toLowerCase();
  renderCatalogo();
});

function guardarCarrito() {
  localStorage.setItem(CARRITO_KEY, JSON.stringify(carrito));
}

function agregarAlCarrito(id) {
  const prod = productos.find((p) => p.id === id);
  if (!prod || Number(prod.cantidad) <= 0) return;
  const existente = carrito.find((item) => item.id === id);
  if (existente) {
    if (existente.cantidad >= prod.cantidad) {
      alert("Has alcanzado la cantidad máxima disponible de este artículo.");
      return;
    }
    existente.cantidad += 1;
  } else {
    carrito.push({ ...prod, cantidad: 1 });
  }
  guardarCarrito();
  renderCarrito();
  abrirCarrito();
}

function cambiarCantidad(id, delta) {
  const item = carrito.find((i) => i.id === id);
  if (!item) return;
  item.cantidad += delta;
  if (item.cantidad <= 0) {
    carrito = carrito.filter((i) => i.id !== id);
  }
  guardarCarrito();
  renderCarrito();
}

function renderCarrito() {
  const totalItems = carrito.reduce((acc, i) => acc + i.cantidad, 0);
  cartCount.textContent = totalItems;

  if (carrito.length === 0) {
    cartItemsContainer.innerHTML = `<p style="color:var(--texto-suave);text-align:center;margin-top:2rem;">Tu carrito está vacío.</p>`;
    cartTotalEl.textContent = formatearPrecio(0);
    return;
  }

  let total = 0;
  cartItemsContainer.innerHTML = carrito
    .map((item) => {
      total += item.precio * item.cantidad;
      return `
        <div class="cart-item">
          <div class="cart-item-info">
            <h4>${item.nombre}</h4>
            <p>${formatearPrecio(item.precio)} c/u</p>
          </div>
          <div class="qty-controls">
            <button class="qty-btn" onclick="cambiarCantidad(${item.id}, -1)">-</button>
            <span>${item.cantidad}</span>
            <button class="qty-btn" onclick="cambiarCantidad(${item.id}, 1)">+</button>
          </div>
        </div>
      `;
    })
    .join("");

  cartTotalEl.textContent = formatearPrecio(total);
}

function abrirCarrito() {
  cartDrawer.classList.remove("hidden");
  cartOverlay.classList.remove("hidden");
}

function cerrarCarrito() {
  cartDrawer.classList.add("hidden");
  cartOverlay.classList.add("hidden");
}

document.getElementById("open-cart-btn").addEventListener("click", abrirCarrito);
document.getElementById("close-cart-btn").addEventListener("click", cerrarCarrito);
cartOverlay.addEventListener("click", cerrarCarrito);

document.querySelectorAll('input[name="tipo_entrega"]').forEach((radio) => {
  radio.addEventListener("change", (e) => {
    const esDomicilio = e.target.value === "domicilio";
    domicilioFields.classList.toggle("hidden", !esDomicilio);
    direccionInput.required = esDomicilio;
  });
});

checkoutForm.addEventListener("submit", (e) => {
  e.preventDefault();
  if (carrito.length === 0) {
    alert("Agrega al menos un artículo a tu carrito antes de confirmar.");
    return;
  }

  const nombre = document.getElementById("cliente-nombre").value.trim();
  const telefono = document.getElementById("cliente-telefono").value.trim();
  const tipoEntrega = document.querySelector('input[name="tipo_entrega"]:checked').value;
  const direccion = direccionInput.value.trim();
  const referencias = document.getElementById("cliente-referencias").value.trim();
  const metodoPago = document.getElementById("metodo-pago").value;

  const total = carrito.reduce((acc, i) => acc + i.precio * i.cantidad, 0);
  const listaProductos = carrito
    .map((i) => `• ${i.cantidad}x [${i.codigo || i.id}] ${i.nombre} (${formatearPrecio(i.precio * i.cantidad)})`)
    .join("\n");

  const textoEntrega =
    tipoEntrega === "tienda"
      ? "Recoger en tienda"
      : `Entrega a domicilio: ${direccion}${referencias ? ` (${referencias})` : ""}`;

  const textoPago =
    metodoPago === "mercadopago_terminal"
      ? "Terminal Mercado Pago (en tienda / contra entrega)"
      : "Pago en línea con Mercado Pago";

  const resumen = `Cliente: ${nombre}\nTeléfono: ${telefono}\nEntrega: ${textoEntrega}\nPago: ${textoPago}\n\nArtículos:\n${listaProductos}\n\nTotal: ${formatearPrecio(total)}`;

  orderSummaryEl.textContent = resumen;
  whatsappOrderLink.href = `https://wa.me/${TELEFONO_TIENDA}?text=${encodeURIComponent(
    `Hola DecorArte, acabo de realizar este pedido:\n\n${resumen}`
  )}`;

  cerrarCarrito();
  orderModal.classList.remove("hidden");

  carrito = [];
  guardarCarrito();
  renderCarrito();
  checkoutForm.reset();
  domicilioFields.classList.add("hidden");
});

document.getElementById("close-modal-btn").addEventListener("click", () => {
  orderModal.classList.add("hidden");
});

cargarDatos();
renderCarrito();
