// Initialize Firestore through the global 'db' variable defined in index.html
// No need to redeclare db if it's already in the <script> tag of index.html

// 1. Load Data from Firebase instead of data.json
function loadSiteData() {
  // .onSnapshot creates a real-time connection
  db.collection('site_content').doc('landing_page')
    .onSnapshot((doc) => {
      if (doc.exists) {
        const siteData = doc.data();
        renderSite(siteData);
      } else {
        console.error("No site data found in Firestore! Run migrate.js first.");
      }
    }, (err) => {
      console.error("Firebase listen failed:", err);
    });
}

// 2. Render the website content (Modified to accept data from Firestore)
function renderSite(siteData) {
  // Hero section
  document.getElementById("siteName").textContent = siteData.site.name;
  document.getElementById("tagline").textContent = siteData.site.tagline;
  document.getElementById("hero").style.backgroundImage = `url(${siteData.site.heroImage})`;

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

  // Populate booking selectors
  const serviceSelect = document.getElementById("bookingService");
  const durationSelect = document.getElementById("bookingDuration");
  const addonsSelect = document.getElementById("addons");

  // Default options
  serviceSelect.innerHTML = "<option value=''>Select Service</option>";
  durationSelect.innerHTML = "<option value=''>Select Duration</option>";
  addonsSelect.innerHTML = "<option value=''>Select Add ons</option>";

  // Populate services
  siteData.services.forEach((service, index) => {
    serviceSelect.innerHTML += `
    <option value="${index}">
      ${service.title} - ${service.price}
    </option>`;
  });

  // Event listener for dynamic dropdowns (Duration/Addons)
  // We use a named function or check to prevent multiple listeners if re-rendered
  serviceSelect.onchange = function () {
    const selectedIndex = this.value;

    durationSelect.innerHTML = "<option value=''>Select Duration</option>";
    addonsSelect.innerHTML = "<option value=''>Select Add ons</option>";

    if (selectedIndex !== "") {
      const selectedService = siteData.services[selectedIndex];

      selectedService.duration.forEach(duration => {
        durationSelect.innerHTML += `<option value="${duration}">${duration}</option>`;
      });

      selectedService.addons.forEach(addon => {
        addonsSelect.innerHTML += `
        <option value="${addon.name}">
          ${addon.name} - ${addon.price} 
        </option>`;
      });
    }
  };

  // Contact info
  document.getElementById("contactPhone").textContent = siteData.contact.phone;
  document.getElementById("contactEmail").textContent = siteData.contact.email;
  document.getElementById("contactAddress").textContent = siteData.contact.address;
}

// 3. Scroll function remains the same
function scrollToServices() {
  document.getElementById("servicesSection").scrollIntoView({ behavior: "smooth" });
}

// 4. Updated Booking form to save to FIREBASE
document.getElementById("bookingForm").addEventListener("submit", async function (e) {
  e.preventDefault();

  // 1. Get the select element
  const serviceSelect = document.getElementById("bookingService");
  const dateInput = document.getElementById("bookingDate").value;
  const timeInput = document.getElementById("bookingTime").value;

  // 2. Capture the Text (e.g., "Deep Tissue") instead of Value (e.g., "0")
  const serviceName = serviceSelect.options[serviceSelect.selectedIndex].text;
  const combinedDateTime = new Date(`${dateInput}T${timeInput}`);

  const booking = {
    service: serviceName, // Now saves the actual name (e.g., "Swedish Massage")
    duration: document.getElementById("bookingDuration").value,
    addon: document.getElementById("addons").value,
    customerName: document.getElementById("customerName").value,
    customerEmail: document.getElementById("customerEmail").value,
    customerPhone: document.getElementById("customerPhone").value,    
    scheduledDateTime: combinedDateTime,    
    date: dateInput,
    time: timeInput,
    notes: document.getElementById("bookingNotes").value,
    status: "new",
    timestamp: firebase.firestore.FieldValue.serverTimestamp()
  };

  try {
    // Save to the 'bookings' collection in Firestore
    await db.collection("bookings").add(booking);

    alert("Booking sent successfully! You will receive a confirmation soon.");
    this.reset();
  } catch (error) {
    console.error("Error saving booking:", error);
    alert("Failed to send booking. Please try again.");
  }
});

// Initialize the app
loadSiteData();