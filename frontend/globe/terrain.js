// Adapted from God's Eye View (MIT License, Copyright (c) 2026 Bilawal Sidhu)
// https://github.com/bilawalsidhu/gods-eye-view — src/maps/terrain.js
import * as Cesium from 'cesium';

export const KEYLESS_TERRAIN_URL =
  'https://terrain.reearth.land/cesium-mesh/ellipsoid';

export async function createKeylessTerrain() {
  try {
    return {
      provider: await Cesium.CesiumTerrainProvider.fromUrl(
        new Cesium.Resource({ url: KEYLESS_TERRAIN_URL }),
      ),
    };
  } catch (error) {
    console.warn('[EBWiki globe] Keyless terrain unavailable; using ellipsoid.', error);
    return { provider: new Cesium.EllipsoidTerrainProvider() };
  }
}
