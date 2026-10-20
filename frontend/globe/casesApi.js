export async function loadCases(url) {
  const response = await fetch(url, {
    headers: { Accept: 'application/json' },
    credentials: 'same-origin',
  });
  if (!response.ok) {
    throw new Error(`Cases request failed (${response.status})`);
  }
  return response.json();
}
