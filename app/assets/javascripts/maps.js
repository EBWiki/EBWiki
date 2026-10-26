// HERE Maps clustering for EBWiki cases (flat map view).
function initEbwikiFlatMap() {
  var container = document.getElementById('map-container');
  if (!container || typeof H === 'undefined') {
    return;
  }
  if (container.dataset.mapInitialized === 'true') {
    return;
  }
  container.dataset.mapInitialized = 'true';

  if (!window.API_KEY) {
    container.innerHTML =
      '<p class="alert alert-warning">The flat map needs a HERE Maps API key in HERE_MAPS_API_KEY.</p>';
    return;
  }

  var platform = new H.service.Platform({ apikey: window.API_KEY });
  var defaultLayers = platform.createDefaultLayers();
  var map = new H.Map(container, defaultLayers.vector.normal.map, {
    zoom: 4,
    center: { lat: 39.83333, lng: -98.58333 }
  });

  var coordinates = [];
  if (Array.isArray(window.CASES)) {
    coordinates = window.CASES;
  } else if (typeof window.CASES === 'string') {
    try {
      coordinates = JSON.parse(window.CASES);
    } catch (e) {
      if (window.Sentry && typeof window.Sentry.captureException === 'function') {
        window.Sentry.captureException(e);
      }
      coordinates = [];
    }
  }

  var pairs = [];
  for (var i = 0; i + 1 < coordinates.length; i += 2) {
    pairs.push(new H.clustering.DataPoint(coordinates[i], coordinates[i + 1]));
  }

  var clusteredDataProvider = new H.clustering.Provider(pairs);
  var layer = new H.map.layer.ObjectLayer(clusteredDataProvider);
  map.addLayer(layer);

  window.addEventListener('resize', function () {
    map.getViewPort().resize();
  });

  new H.mapevents.Behavior(new H.mapevents.MapEvents(map));
}

window.initEbwikiFlatMap = initEbwikiFlatMap;

document.addEventListener('DOMContentLoaded', function () {
  initEbwikiFlatMap();
});
