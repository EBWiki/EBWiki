/* global L */
(function ($) {
  'use strict';

  var US_CENTER = [39.8283, -98.5795];
  var US_ZOOM = 4;
  var CASE_ZOOM = 11;
  var TILE_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  var TILE_ATTRIBUTION = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>';

  function parseCaseMapData() {
    var node = document.getElementById('case-map-data');
    if (!node || !node.textContent) {
      return [];
    }

    try {
      var parsed = JSON.parse(node.textContent);
      return Array.isArray(parsed) ? parsed : [];
    } catch (error) {
      return [];
    }
  }

  function addTileLayer(map) {
    L.tileLayer(TILE_URL, { attribution: TILE_ATTRIBUTION, maxZoom: 18 }).addTo(map);
  }

  function popupHtml(item) {
    var title = item.title || 'Untitled case';
    var city = item.city ? '<br>' + item.city : '';
    if (item.url) {
      return '<a href="' + item.url + '">' + title + '</a>' + city;
    }
    return title + city;
  }

  function addMarker(layer, item) {
    if (item.lat == null || item.lng == null) {
      return;
    }

    L.marker([item.lat, item.lng]).bindPopup(popupHtml(item)).addTo(layer);
  }

  function initCasesMap() {
    var container = document.getElementById('map-container');
    if (!container || typeof L === 'undefined') {
      return;
    }

    var cases = parseCaseMapData();
    var map = L.map(container).setView(US_CENTER, US_ZOOM);
    addTileLayer(map);

    var layer = L.markerClusterGroup ? L.markerClusterGroup() : L.layerGroup();
    cases.forEach(function (item) {
      addMarker(layer, item);
    });
    map.addLayer(layer);

    if (cases.length === 1 && cases[0].lat != null && cases[0].lng != null) {
      map.setView([cases[0].lat, cases[0].lng], CASE_ZOOM);
    } else if (cases.length > 1 && layer.getBounds && layer.getBounds().isValid()) {
      map.fitBounds(layer.getBounds().pad(0.15));
    }
  }

  function initCaseLocationMap() {
    var container = document.getElementById('case-location-map');
    if (!container || typeof L === 'undefined') {
      return;
    }

    var lat = parseFloat(container.getAttribute('data-lat'));
    var lng = parseFloat(container.getAttribute('data-lng'));
    if (Number.isNaN(lat) || Number.isNaN(lng)) {
      return;
    }

    var map = L.map(container).setView([lat, lng], CASE_ZOOM);
    addTileLayer(map);
    addMarker(map, {
      lat: lat,
      lng: lng,
      title: container.getAttribute('data-title'),
      city: container.getAttribute('data-city'),
      url: container.getAttribute('data-url')
    });
  }

  function initMaps() {
    initCasesMap();
    initCaseLocationMap();
  }

  window.EBWiki = window.EBWiki || {};
  window.EBWiki.initCaseMaps = initMaps;

  $(initMaps);
})(jQuery);
