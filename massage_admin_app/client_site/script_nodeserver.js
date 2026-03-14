let siteData = null;

async function loadSiteData() {
  const res = await fetch("/api/data");
  siteData = await res.json();
  renderSite();
}

function renderSite() {
  document.getElementById("siteName").textContent = siteData.site.name;
  document.getElementById("tagline").textContent = siteData.site.tagline;
  document.getElementById("hero").style.backgroundImage =
    `url(${siteData.site.heroImage})`;

  const container = document.getElementById("servicesContainer");
  container.innerHTML = "";
  siteData.services.forEach(s => {
    container.innerHTML += `
      <div class="card">
        <img src="${s.image}">
        <h3>${s.title}</h3>
        <p>${s.description}</p>
        <strong>${s.price}</strong>
      </div>`;
  });

  populateBookingServices();

  document.getElementById("contactPhone").textContent = siteData.contact.phone;
  document.getElementById("contactEmail").textContent = siteData.contact.email;
  document.getElementById("contactAddress").textContent = siteData.contact.address;
}

function populateBookingServices() {
  const select = document.getElementById("bookingService");
  select.innerHTML = "<option value=''>Select Service</option>";
  siteData.services.forEach(s => {
    select.innerHTML += `<option value="${s.title}">${s.title} - ${s.price}</option>`;
  });
}

document.getElementById("bookingForm").addEventListener("submit", async function (e) {
  e.preventDefault();
  const booking = {
    service: bookingService.value,
    name: customerName.value,
    email: customerEmail.value,
    phone: customerPhone.value,
    date: bookingDate.value,
    time: bookingTime.value,
    notes: bookingNotes.value
  };
  const res = await fetch("/api/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(booking)
  });
  const result = await res.json();
  alert(result.message);
  this.reset();
});

function scrollToServices() {
  document.getElementById("servicesSection").scrollIntoView({ behavior: "smooth" });
}

loadSiteData();