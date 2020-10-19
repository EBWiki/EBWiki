# EBWiki Maps:

## Purpose

The purpose of this document is to describe the re-implementation of 
mapping cases on [EBWIki.org](https://ebwiki.org). We'll discuss the
considerations behind the decisions made for the current implementation. The next
section outlines all parts of the maps deliverable, in order to help people who
wants to understand how all parts of the solution fit together. Finally, notable
information and gotchas are reviewed.

### Motivations

EBWiki once used Google Maps for a mapping solution, but the Gmaps4Rails plugin
we had been using was no longer being maintained. While looking at mapping
solutions, we decided to try [HERE Maps](https://developer.here.com) as a
provider of mapping services. We also wanted to remove the reliance on a gem as 
an interface to mapping solutions, having been affected by the lack of 
maintenance on the [Gmaps4Rails](https://github.com/apneadiving/Google-Maps-for-Rails).
While there does exist a viable alternative in [google-maps-services-ruby](https://github.com/edwardsamuel/google-maps-services-ruby) for those who want to use Google Maps, the exploration of 
alternate mapping providers does fulfill other reqirements.

### Mapping Solution

#### HERE Maps

We incorporated the [HERE JavaScript SDK](https://developer.here.com/documentation/maps/3.1.19.0/dev_guide/index.html)
mapping, ui and marker clustering libraries. HERE Technologies has a suite of
mapping and geo services available that we can use if needed.

#### Maps Cache

The Cases cache is a JSON of latitude & longitude for all cases that had
coordinate information. Cases without that data won't be included in the JSON
document, with a 2 hour [Time To Live (TTL)](https://en.wikipedia.org/wiki/Time_to_live). 

#### Maps Controller

The controller gets cases from either the database or cache and then sends
a string of coordinates that is interpreted in maps.js in order to
display a map centered on the United States with cases clustered and numbered. The
map also has a zoom control that changes and updates the number in the
cluster based upon how many cases fit in the area.

#### Maps Helper

Contains `fetch_cases`, the method to get cases from the db or cache and
creates a JSON of the case latitude & longitude. 

#### maps.js

This contains code that gets the list of case coordinates from the cases index
template as well as the HERE Maps API Key. The coordinates are turned into
DataPoints which can be put into a Cluster which is then used in the Layer
that is added to the map.

### Notes & Gotchas

- The MAPS API Key is stored in a Rails ENV Variable ("HERE_MAPS_API_KEY") that
  is attached to the window object when the application template is rendered.

- The logic for parsing JSON sent from the controller could be improved, and 
  I am looking into making improvements to that.

- We should define a cache purging strategy and figure out whether the TTL
  should be improved. A dyno restart will suffice to empty the cache, so 
  the barrier to reset the cache is not high.
