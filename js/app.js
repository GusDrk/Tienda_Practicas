const TELEFONO_TIENDA = "520000000000"; // Reemplazar con el número real de DecorArte

const PRODUCTOS_FALLBACK = [
  {
    id: 1,
    nombre: "Cuadro Abstracto Dorado & Mármol",
    categoria: "cuadros",
    precio: 1850,
    temporada: false,
    imagen: "https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&w=600&q=80",
    descripcion: "Lienzo enmarcado en acabado dorado cepillado, ideal para sala o recibidor."
  },
  {
    id: 2,
    nombre: "Espejo Circular Marco Dorado",
    categoria: "espejos",
    precio: 2400,
    temporada: false,
    imagen: "https://images.unsplash.com/photo-1618220179428-22790b461013?auto=format&fit=crop&w=600&q=80",
    descripcion: "Espejo de 80 cm con marco metálico en tono champagne dorado."
  },
  {
    id: 3,
    nombre: "Mesa Auxiliar de Cristal y Latón",
    categoria: "mesas",
    precio: 3200,
    temporada: false,
    imagen: "https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?auto=format&fit=crop&w=600&q=80",
    descripcion: "Mesa pequeña con cubierta de cristal templado y base dorada minimalista."
  },
  {
    id: 4,
    nombre: "Figura de Cerámica Orgánica Beige",
    categoria: "ceramica",
    precio: 680,
    temporada: false,
    imagen: "https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=600&q=80",
    descripcion: "Escultura decorativa de cerámica mate en tono arena, hecha a mano."
  },
  {
    id: 5,
    nombre: "Set de 3 Jarrones Cerámica Minimal",
    categoria: "ceramica",
    precio: 950,
    temporada: false,
    imagen: "https://images.unsplash.com/photo-1578500494198-246f612d3b3d?auto=format&fit=crop&w=600&q=80",
    descripcion: "Trío de piezas en cerámica beige y blanco hueso para centro de mesa."
  },
  {
    id: 6,
    nombre: "Corona Navideña Dorada & Pino",
    categoria: "navidad",
    precio: 1150,
    temporada: true,
    imagen: "https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=600&q=80",
    descripcion: "Corona artesanal de temporada con detalles dorados y bayas invernales."
  },
  {
    id: 7,
    nombre: "Esferas de Cristal y Hoja de Oro (Set x6)",
    categoria: "navidad",
    precio: 790,
    temporada: true,
    imagen: "https://images.unsplash.com/photo-1543589077-47d81606c1bf?auto=format&fit=crop&w=600&q=80",
    descripcion: "Juego de 6 esferas navideñas elegantes en cristal transparente y dorado."
  },
  {
    id: 8,
    nombre: "Espejo Arco de Cuerpo Completo",
    categoria: "espejos",
    precio: 4100,
    temporada: false,
    imagen: "https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=600&q=80",
    descripcion: "Espejo estilo arco con borde fino dorado, perfecto para recámara o vestidor."
  }
];

let productos = [];
let categoriaActual = "todos";
let textoBusqueda = "";
let carrito = JSON.parse(localStorage.getItem("decorarte_carrito") || "[]");

const catalogGrid = document.getElementById("catalog-grid");
const searchInput = document.getElementById("search-input");
const filterButtons = document.querySelectorAll(".filter-btn");
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

async function cargarProductos() {
  try {
    const res = await fetch("data/productos.json");
    if (!res.ok) throw new Error("No se pudo cargar JSON");
    productos = await res.json();
  } catch {
    productos = PRODUCTOS_FALLBACK;
  }
  renderCatalogo();
}

function formatearPrecio(monto) {
  return `$${monto.toLocaleString("es-MX", { minimumFractionDigits: 2 })} MXN`;
}

function renderCatalogo() {
  const filtrados = productos.filter((p) => {
    const coincideCat = categoriaActual === "todos" || p.categoria === categoriaActual;
    const coincideTexto =
      p.nombre.toLowerCase().includes(textoBusqueda) ||
      p.descripcion.toLowerCase().includes(textoBusqueda);
    return coincideCat && coincideTexto;
  });

  if (filtrados.length === 0) {
    catalogGrid.innerHTML = `<p style="grid-column:1/-1;text-align:center;color:var(--texto-suave);">No se encontraron artículos con ese filtro.</p>`;
    return;
  }

  catalogGrid.innerHTML = filtrados
    .map(
      (p) => `
      <article class="product-card">
        <div class="product-img-wrap">
          <img src="${p.imagen}" alt="${p.nombre}" loading="lazy" />
          ${p.temporada ? '<span class="season-tag">Navidad</span>' : ""}
        </div>
        <div class="product-body">
          <span class="product-cat">${p.categoria}</span>
          <h3>${p.nombre}</h3>
          <p class="product-desc">${p.descripcion}</p>
          <div class="product-footer">
            <span class="product-price">${formatearPrecio(p.precio)}</span>
            <button class="add-btn" onclick="agregarAlCarrito(${p.id})">Agregar</button>
          </div>
        </div>
      </article>
    `
    )
    .join("");
}

function filtrarPorCategoria(cat, hacerScroll = false) {
  categoriaActual = cat;
  filterButtons.forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.category === cat);
  });
  renderCatalogo();
  if (hacerScroll) {
    document.getElementById("catalogo").scrollIntoView({ behavior: "smooth" });
  }
}

filterButtons.forEach((btn) => {
  btn.addEventListener("click", () => filtrarPorCategoria(btn.dataset.category));
});

searchInput.addEventListener("input", (e) => {
  textoBusqueda = e.target.value.trim().toLowerCase();
  renderCatalogo();
});

function guardarCarrito() {
  localStorage.setItem("decorarte_carrito", JSON.stringify(carrito));
}

function agregarAlCarrito(id) {
  const prod = productos.find((p) => p.id === id);
  if (!prod) return;
  const existente = carrito.find((item) => item.id === id);
  if (existente) {
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
    .map((i) => `• ${i.cantidad}x ${i.nombre} (${formatearPrecio(i.precio * i.cantidad)})`)
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

cargarProductos();
renderCarrito();
