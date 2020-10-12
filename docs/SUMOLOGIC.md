# Sumo Logic & EBWiki
## Sumo Logic

[Sumo Logic](<https://www.sumologic.com/> "Sumo Logic") is the industry's leading, secure, cloud-based service for logs & metrics management
for modern apps, providing real-time analytics and insights. We can use Sumo Logic for a variety of functions, but the impetus
for adding Sumo Logic came from a desire to investigate and debug app activity.
## How to Access Sumo Logic
Sumo Logic was set up using guidance from a [Heroku DevCenter](<https://devcenter.heroku.com/articles/sumologic> "Sumo Logic") article. Once set up,
the Sumo Logic admin is available through the Heroku admin interface. Select the specific dynamo, then "Sumo Logic" under resources.

## Viewing Heroku Logs in Sumo Logic
In order to view server logs, open a new Log Search and use `_sourceCategory=heroku` as the query parameter. This is available for staging & production.

![Sumo Logic Search Log](<images/sumo_logic_staging.png> "Sumo Logic Log Search")

Whereas running `heroku logs` on an instance would only return info level logging, this log search encompasses all log levels, which makes
investigating debug output on staging possible.

This also provides one interface for looking into logs over long periods of time.
![Sumo Logic Search Log](<images/sumo_logic_ga last_month.png> "Sumo Logic Log Search Over Past Month")
