// EBWiki cases globe — Cesium viewer with keyless imagery (Esri, then OSM).
// Map stack patterns adapted from God's Eye View (MIT License, Copyright (c) 2026 Bilawal Sidhu)
// https://github.com/bilawalsidhu/gods-eye-view
import * as Cesium from 'cesium';
import { applyKeylessImageryStack, tryGooglePhotoreal3D } from './mapStack.js';

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

function showFlatMapFallback() {
  const notice = document.getElementById('globe-no-webgl');
  const viewport = document.getElementById('globe-viewport');
  const fallbackMap = document.getElementById('globe-fallback-map');
  if (notice) notice.hidden = false;
  if (viewport) viewport.hidden = true;
  if (fallbackMap) fallbackMap.hidden = false;
  if (typeof window.initEbwikiFlatMap === 'function') {
    window.initEbwikiFlatMap();
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
        pixelSize: 10,
        color: Cesium.Color.fromCssColorString('#F65732'),
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 1,
      },
      label: {
        text: point.name,
        font: '12px sans-serif',
        fillColor: Cesium.Color.WHITE,
        outlineColor: Cesium.Color.BLACK,
        outlineWidth: 2,
        style: Cesium.LabelStyle.FILL_AND_OUTLINE,
        show: false,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        pixelOffset: new Cesium.Cartesian2(0, -12),
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
    cluster.billboard.show = true;
    cluster.billboard.image = undefined;
    cluster.point.pixelSize = 28;
    cluster.point.color = Cesium.Color.fromCssColorString('#F65732').withAlpha(0.85);
    cluster.point.outlineColor = Cesium.Color.WHITE;
    cluster.point.outlineWidth = 2;
  });

  return dataSource;
}

async function bootGlobe() {
  const config = readConfig();
  const viewport = document.getElementById('globe-viewport');
  if (!viewport) return;

  if (!webglAvailable()) {
    showFlatMapFallback();
    return;
  }

  Cesium.Ion.defaultAccessToken = config.cesiumIonToken || '';

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
  });

  await applyKeylessImageryStack(viewer, { cesiumIonToken: config.cesiumIonToken });
  await tryGooglePhotoreal3D(viewer, config.google3dApiKey);

  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(-98.58333, 39.83333, 12_000_000),
  });

  try {
    const cases = await loadCases(config.casesUrl);
    await addCaseEntities(viewer, cases);
  } catch (error) {
    console.error('[EBWiki globe]', error);
  }

  viewer.selectedEntityChanged.addEventListener((entity) => {
    if (!entity || !entity.properties?.caseUrl) return;
    const url = entity.properties.caseUrl.getValue();
    if (url) {
      viewer.infoBox.viewModel.description = entity.description;
    }
  });
}

bootGlobe().catch((error) => {
  console.error('[EBWiki globe] boot failed', error);
  showFlatMapFallback();
});
