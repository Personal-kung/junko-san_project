// Global variable to store site data
let siteData = null;

// Load JSON data
async function loadSiteData() {
  try {
    const res = await fetch("data.json"); // static JSON file
    siteData = await res.json();
    renderSite();
  } catch (err) {
    console.error("Failed to load site data:", err);
    alert("Could not load site data.");
  }
}

// Render the website content
function renderSite() {
  // Hero section
  document.getElementById("siteName").textContent = siteData.site.name;
  document.getElementById("tagline").textContent = siteData.site.tagline;
  document.getElementById("hero").style.backgroundImage =
    `url(${siteData.site.heroImage})`;

  // Services section
  const container = document.getElementById("servicesContainer");
  container.innerHTML = "";
  siteData.services.forEach(service => {
    container.innerHTML += `
      <div class="card">
        <img src="${service.image}" alt="${service.title}">
        <h3>${service.title}</h3>
        <p>${service.description}</p>
        <strong>${service.price}</strong>
      </div>`;
  });

  // Populate booking service options
  const select = document.getElementById("bookingService");
  select.innerHTML = "<option value=''>Select Service</option>";
  siteData.services.forEach(s => {
    select.innerHTML += `<option value="${s.title}">${s.title} - ${s.price}</option>`;
  });

  // Contact info
  document.getElementById("contactPhone").textContent = siteData.contact.phone;
  document.getElementById("contactEmail").textContent = siteData.contact.email;
  document.getElementById("contactAddress").textContent = siteData.contact.address;
}

// Scroll to services
function scrollToServices() {
  document.getElementById("servicesSection").scrollIntoView({ behavior: "smooth" });
}

// Booking form
document.getElementById("bookingForm").addEventListener("submit", function (e) {
  e.preventDefault();

  // Since it's static, we cannot save bookings on server
  const booking = {
    service: document.getElementById("bookingService").value,
    name: document.getElementById("customerName").value,
    email: document.getElementById("customerEmail").value,
    phone: document.getElementById("customerPhone").value,
    date: document.getElementById("bookingDate").value,
    time: document.getElementById("bookingTime").value,
    notes: document.getElementById("bookingNotes").value
  };

  // Save in localStorage (temporary, per user)
  let bookings = JSON.parse(localStorage.getItem("bookings") || "[]");
  bookings.push(booking);
  localStorage.setItem("bookings", JSON.stringify(bookings));

  alert("Booking saved locally! For real booking, integrate an email or backend service.");
  this.reset();
});

// Initialize
loadSiteData();