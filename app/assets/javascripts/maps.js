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
      '<p class="alert alert-warning">The flat map needs a HERE Maps API key. ' +
      'You can still use the <a href="/maps/globe">3D globe</a>, which does not require one.</p>';
    return;
  }

  var platform = new H.service.Platform({ apikey: window.API_KEY });
  var defaultLayers = platform.createDefaultLayers();
  var map = new H.Map(container, defaultLayers.vector.normal.map, {
    zoom: 4,
    center: { lat: 39.83333, lng: -98.58333 }
  });

  var coordinates = [];
  try {
    coordinates = JSON.parse(window.CASES || '[]');
  } catch (e) {
    coordinates = [];
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
