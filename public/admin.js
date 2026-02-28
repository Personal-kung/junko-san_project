const ADMIN_USER = "admin";
const ADMIN_PASS = "1234";
let siteData = null;

// Placeholder images (use Unsplash random images)
const placeholderImages = [
  "https://images.unsplash.com/photo-1556228578-dd6a0e5e6b52",
  "https://images.unsplash.com/photo-1544161515-4ab6ce6db874",
  "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6",
  "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2"
];

async function loadData() {
  const res = await fetch("/api/data");
  siteData = await res.json();
  renderServices();
}

function renderServices() {
  const list = document.getElementById("servicesList");
  list.innerHTML = "";

  siteData.services.forEach((s, index) => {
    const div = document.createElement("div");
    div.className = "service-item";
    div.dataset.index = index;
    div.innerHTML = `
      <input type="text" class="service-title" placeholder="Title" value="${s.title}">
      <input type="text" class="service-price" placeholder="Price" value="${s.price}">
      <input type="text" class="service-desc" placeholder="Description" value="${s.description}">
      <input type="text" class="service-image" placeholder="Image URL" value="${s.image || ''}">
      <button onclick="removeService(${index})">Remove</button>
    `;
    list.appendChild(div);
  });
}

// Add a new empty service
document.getElementById("addServiceBtn").addEventListener("click", () => {
  siteData.services.push({ title: "", price: "", description: "", image: "" });
  renderServices();
});

// Remove service
function removeService(index) {
  siteData.services.splice(index, 1);
  renderServices();
}

// Save all services to server
async function saveChanges() {
  const serviceDivs = document.querySelectorAll(".service-item");
  siteData.services = Array.from(serviceDivs).map((div, i) => {
    const title = div.querySelector(".service-title").value.trim();
    const price = div.querySelector(".service-price").value.trim();
    const description = div.querySelector(".service-desc").value.trim();
    let image = div.querySelector(".service-image").value.trim();
    if (!image) {
      // Assign a placeholder image if none provided
      image = placeholderImages[i % placeholderImages.length];
    }
    return { title, price, description, image };
  });

  const res = await fetch("/api/data", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(siteData)
  });
  const result = await res.json();
  alert(result.message);
}

// Admin login
function adminLogin() {
  if (adminUser.value === ADMIN_USER && adminPass.value === ADMIN_PASS) {
    document.getElementById("loginSection").classList.add("hidden");
    document.getElementById("dashboardSection").classList.remove("hidden");
    loadData();
  } else {
    alert("Wrong credentials");
  }
}