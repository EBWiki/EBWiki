// Adapted from God's Eye View (MIT License, Copyright (c) 2026 Bilawal Sidhu)
// https://github.com/bilawalsidhu/gods-eye-view — src/maps/defaultSources.js (simplified)
import * as Cesium from 'cesium';
import { createEsriImagery, createOsmImagery, ESRI_ATTRIBUTION_HTML } from './imagery.js';
import { createKeylessTerrain } from './terrain.js';

async function applyImagery(viewer, imageryProvider) {
  viewer.imageryLayers.removeAll();
  viewer.imageryLayers.addImageryProvider(await imageryProvider);
}

export async function applyKeylessImageryStack(viewer) {
  const terrainResult = await createKeylessTerrain();
  viewer.terrainProvider = terrainResult.provider;

  try {
    await applyImagery(viewer, createEsriImagery());
  } catch (error) {
    console.warn('[EBWiki globe] Esri imagery failed; using OSM.', error);
    await applyImagery(viewer, createOsmImagery());
  }

  const esriLayer = viewer.imageryLayers.get(0);
  if (esriLayer) {
    esriLayer.errorEvent.addEventListener(async () => {
      if (viewer.isDestroyed()) return;
      await applyImagery(viewer, createOsmImagery());
    });
  }

  viewer.creditDisplay.addStaticCredit(
    new Cesium.Credit(ESRI_ATTRIBUTION_HTML, true),
  );
  viewer.creditDisplay.addStaticCredit(
    new Cesium.Credit('© OpenStreetMap contributors', true),
  );

  stripDefaultIonCredits(viewer);
}

function stripDefaultIonCredits(viewer) {
  const container = viewer.cesiumWidget.creditContainer;
  const removeIonNodes = () => {
    container.querySelectorAll('a[href*="cesium.com"], .cesium-credit-logoContainer').forEach((node) => {
      node.remove();
    });
  };

  removeIonNodes();
  viewer.scene.postRender.addEventListener(removeIonNodes);
}
