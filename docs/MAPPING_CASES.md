# EBWiki Maps

## Purpose

This document describes mapping cases on [EBWiki.org](https://ebwiki.org):
the `/maps` case map and the location map on individual case pages.

### Motivations

EBWiki once used Google Maps via Gmaps4Rails, then explored
[HERE Maps](https://developer.here.com) after that gem went unmaintained.
The current implementation uses [Leaflet](https://leafletjs.com) with
OpenStreetMap tiles so the map can render without a vendor API key or a
mapping gem.

## Mapping Solution

### Leaflet + OpenStreetMap

`app/assets/javascripts/case_map.js` reads case coordinates from the page
and draws markers. On `/maps`, markers are clustered. Clicking a pin opens
a popup that links to the case. Case pages with latitude and longitude show
a smaller map centered on that incident.

### Maps Cache

`MapsHelper#fetch_cases` caches latitude, longitude, title, slug, city, and
case URL for every geocoded case. The cache key is `case_map_locations_v2`
with a 12 hour TTL. Cases without coordinates are omitted. A dyno or process
restart clears the in-memory cache; Redis-backed caches expire after the TTL.

### Maps Controller

`MapsController#index` (and `#show`, which reuses the same template) loads
cached case locations and renders a United States-centered map.

### Maps Helper

`fetch_cases` reads from cache or the database. `case_has_location?` decides
whether a case page should render its location map.

## HTTP Basic Auth

Staging and preview apps can require HTTP Basic Auth without locking
production:

- Set `HTTP_BASIC_AUTH_USERNAME` and `HTTP_BASIC_AUTH_PASSWORD`
  (`STAGING_USERNAME` / `STAGING_PASSWORD` still work as fallbacks).
- Auth is on automatically in the `staging` environment, or when
  `HOST=ebwiki-newstack.herokuapp.com`.
- To enable it elsewhere (including production-like preview apps), also set
  `HTTP_BASIC_AUTH_ENABLED=true`.

Production remains public unless that flag is set.

## Notes & Gotchas

- Leaflet and MarkerCluster are loaded from the unpkg CDN on map pages only.
- Cache the richer location payload under `case_map_locations_v2` so older
  flattened coordinate strings are not reused.
- A dyno restart or TTL expiry is enough to refresh the cache after new
  geocoded cases are added.
