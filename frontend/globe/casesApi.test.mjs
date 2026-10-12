import assert from 'node:assert/strict';
import test from 'node:test';
import { loadCases } from './casesApi.js';

test('loadCases returns parsed JSON for a successful response', async () => {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async () => ({
    ok: true,
    async json() {
      return [{ id: 1, name: 'Example', lat: 1, lng: 2 }];
    },
  });

  try {
    const payload = await loadCases('/maps/cases.json');
    assert.equal(payload.length, 1);
    assert.equal(payload[0].name, 'Example');
  } finally {
    globalThis.fetch = originalFetch;
  }
});
