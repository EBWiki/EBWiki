import "../css/app.css";

function initCaseMap() {
  const container = document.getElementById("map-container");
  const dataNode = document.getElementById("case-map-data");
  if (!container || !dataNode || typeof L === "undefined") return;

  const locations = JSON.parse(dataNode.textContent || "[]");
  const map = L.map(container).setView([39.8, -98.5], 4);
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "&copy; OpenStreetMap contributors"
  }).addTo(map);

  const cluster = L.markerClusterGroup();
  locations.forEach((location) => {
    const marker = L.marker([location.lat, location.lng]);
    const city = location.city ? ` (${location.city})` : "";
    marker.bindPopup(`<a href="${location.url}">${location.title}</a>${city}`);
    cluster.addLayer(marker);
  });
  map.addLayer(cluster);
  if (locations.length > 0) {
    map.fitBounds(cluster.getBounds().pad(0.15), { maxZoom: 6 });
  }
}

document.addEventListener("DOMContentLoaded", initCaseMap);

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-add]");
  if (!button) return;

  const container = document.getElementById(button.dataset.add);
  if (!container) return;

  const prototype = container.querySelector(".repeatable");
  if (!prototype) return;

  const clone = prototype.cloneNode(true);
  clone.querySelectorAll("input").forEach((input) => {
    input.value = "";
  });
  container.appendChild(clone);
});
