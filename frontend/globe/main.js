// EBWiki cases globe — Cesium viewer with keyless imagery (Esri, then OSM).
// Map stack patterns adapted from God's Eye View (MIT License, Copyright (c) 2026 Bilawal Sidhu)
// https://github.com/bilawalsidhu/gods-eye-view
import { applyKeylessImageryStack } from './mapStack.js';

async function loadCases(url) {
  const response = await fetch(url, {
    headers: { Accept: 'application/json' },
    credentials: 'same-origin',
  });
  if (!response.ok) {
    throw new Error(`Cases request failed (${response.status})`);
  }
  return response.json();
}

function readConfig() {
  const node = document.getElementById('globe-config');
  if (!node) return {};
  try {
    return JSON.parse(node.textContent || '{}');
  } catch {
    return {};
  }
}

function webglAvailable() {
  try {
    const canvas = document.createElement('canvas');
    return Boolean(
      window.WebGLRenderingContext &&
        (canvas.getContext('webgl') || canvas.getContext('experimental-webgl')),
    );
  } catch {
    return false;
  }
}

function showFlatMapFallback(config) {
  const notice = document.getElementById('globe-no-webgl');
  const viewport = document.getElementById('globe-viewport');
  if (notice) notice.hidden = false;
  if (viewport) viewport.hidden = true;
  const link = document.getElementById('globe-flat-map-link');
  if (link && config.flatMapUrl) {
    link.href = config.flatMapUrl;
  }
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function formatDate(isoDate) {
  if (!isoDate) return '';
  const parsed = new Date(isoDate);
  if (Number.isNaN(parsed.getTime())) return isoDate;
  return parsed.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

function locationLabel(point) {
  const parts = [point.city, point.state].filter(Boolean);
  return parts.join(', ');
}

async function addCaseEntities(viewer, cases) {
  const dataSource = new Cesium.CustomDataSource('ebwiki-cases');
  dataSource.clustering.enabled = true;
  dataSource.clustering.pixelRange = 50;
  dataSource.clustering.minimumClusterSize = 2;

  for (const point of cases) {
    dataSource.entities.add({
      id: String(point.id),
      position: Cesium.Cartesian3.fromDegrees(point.lng, point.lat),
      point: {
        pixelSize: 12,
        color: Cesium.Color.fromCssColorString('#F65732'),
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 2,
        disableDepthTestDistance: Number.POSITIVE_INFINITY,
      },
      description: `
        <div class="globe-case-info">
          <strong>${escapeHtml(point.name)}</strong><br/>
          ${escapeHtml(formatDate(point.date))}<br/>
          ${escapeHtml(locationLabel(point))}<br/>
          <a href="${escapeHtml(point.url)}">Open case</a>
        </div>
      `,
      properties: {
        caseUrl: point.url,
        caseName: point.name,
      },
    });
  }

  await viewer.dataSources.add(dataSource);

  dataSource.clustering.clusterEvent.addEventListener((clusteredEntities, cluster) => {
    cluster.label.show = true;
    cluster.label.text = String(clusteredEntities.length);
    cluster.label.font = '14px sans-serif';
    cluster.label.fillColor = Cesium.Color.WHITE;
    cluster.label.outlineColor = Cesium.Color.BLACK;
    cluster.label.outlineWidth = 2;
    cluster.label.style = Cesium.LabelStyle.FILL_AND_OUTLINE;
    cluster.label.verticalOrigin = Cesium.VerticalOrigin.CENTER;
    cluster.label.horizontalOrigin = Cesium.HorizontalOrigin.CENTER;
    cluster.billboard.show = false;
    cluster.point.pixelSize = 28;
    cluster.point.color = Cesium.Color.fromCssColorString('#F65732').withAlpha(0.9);
    cluster.point.outlineColor = Cesium.Color.WHITE;
    cluster.point.outlineWidth = 2;
    cluster.point.disableDepthTestDistance = Number.POSITIVE_INFINITY;
  });

  return dataSource;
}

async function bootGlobe() {
  const config = readConfig();
  const viewport = document.getElementById('globe-viewport');
  if (!viewport) return;

  if (!webglAvailable()) {
    showFlatMapFallback(config);
    return;
  }

  Cesium.Ion.defaultAccessToken = '';

  const viewer = new Cesium.Viewer(viewport, {
    animation: false,
    timeline: false,
    geocoder: false,
    homeButton: true,
    sceneModePicker: true,
    baseLayerPicker: false,
    navigationHelpButton: false,
    fullscreenButton: true,
    infoBox: true,
    selectionIndicator: true,
    baseLayer: false,
    terrainProvider: new Cesium.EllipsoidTerrainProvider(),
  });

  await applyKeylessImageryStack(viewer);

  const cases = await loadCases(config.casesUrl);
  const dataSource = await addCaseEntities(viewer, cases);
  const entityCount = dataSource.entities.values.length;

  window.__ebwikiGlobeViewer = viewer;
  window.__ebwikiGlobeEntityCount = entityCount;
  window.__ebwikiGlobeReady = true;
  viewport.dataset.caseCount = String(entityCount);

  if (entityCount > 0) {
    const positions = dataSource.entities.values.map((entity) => entity.position.getValue(Cesium.JulianDate.now()));
    const boundingSphere = Cesium.BoundingSphere.fromPoints(positions);
    viewer.camera.flyToBoundingSphere(boundingSphere, {
      duration: 0,
      offset: new Cesium.HeadingPitchRange(0, Cesium.Math.toRadians(-35), boundingSphere.radius * 2.5),
    });
  } else {
    viewer.camera.setView({
      destination: Cesium.Cartesian3.fromDegrees(-98.58333, 39.83333, 8_000_000),
    });
  }

  if (config.openFirstCase && entityCount > 0) {
    viewer.selectedEntity = dataSource.entities.values[0];
  }
}

bootGlobe().catch((error) => {
  console.error('[EBWiki globe] boot failed', error);
  window.__ebwikiGlobeReady = false;
  window.__ebwikiGlobeError = String(error);
  showFlatMapFallback(readConfig());
});
