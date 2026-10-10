# Lesson 04 — Port a map without two apps

**Runtime:** 12 minutes  
**Pair with:** Rails `MapsController` / `MapsHelper` and Hanami `/maps`

## What Rails had

The Rails preview ran as its own Railway service (`ebwiki-maps`). It cached
geocoded rows for 12 hours, dumped them into a JSON script tag, and let
Leaflet + markercluster draw pins.

That meant two web processes: Rails wiki + Rails map.

## What Hanami does

Same JSON contract. Same Leaflet. Same US-centered default view. One process.

```ruby
# CaseRepo#map_locations
cases
  .select(:latitude, :longitude, :title, :slug, :city)
  .where(Sequel.~(latitude: nil) & Sequel.~(longitude: nil))
```

The template puts that array in `#case-map-data`. `app/assets/js/app.js`
reads it. No Redis cache yet — the query is cheap enough for staging.

## Teaching point

A JavaScript widget is not a reason to keep Rails alive. If the data is
already in Postgres, the port is a repo method and a template.

## Video beats

1. Show the old Railway URL `ebwiki-maps-production.up.railway.app/maps`.
2. Show Hanami `/maps` with the same Walter Scott pin.
3. Sleep the Rails map service. The Hanami pin stays.

## Exercise

Add a city filter query param to `/maps` using ROM, not ActiveRecord scopes.
