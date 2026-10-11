// Adapted from God's Eye View (MIT License, Copyright (c) 2026 Bilawal Sidhu)
// https://github.com/bilawalsidhu/gods-eye-view — src/maps/defaultSources.js (simplified)
import * as Cesium from 'cesium';
import { createEsriImagery, createOsmImagery } from './imagery.js';
import { createKeylessTerrain, createWorldTerrain } from './terrain.js';

async function applyImagery(viewer, imageryProvider) {
  viewer.imageryLayers.removeAll();
  viewer.imageryLayers.addImageryProvider(await imageryProvider);
}

export async function applyKeylessImageryStack(viewer, { cesiumIonToken = '' } = {}) {
  const ionToken = String(cesiumIonToken || '').trim();
  const terrainResult = ionToken
    ? await createWorldTerrain(ionToken)
    : await createKeylessTerrain();
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
}

export async function tryGooglePhotoreal3D(viewer, googleApiKey) {
  const key = String(googleApiKey || '').trim();
  if (!key) return false;

  try {
    const tileset = await Cesium.createGooglePhotorealistic3DTileset(
      { key, onlyUsingWithGoogleGeocoder: true },
      { asynchronouslyLoadImagery: true },
    );
    viewer.scene.primitives.add(tileset);
    return true;
  } catch (error) {
    console.warn('[EBWiki globe] Google 3D tiles unavailable.', error);
    return false;
  }
}
