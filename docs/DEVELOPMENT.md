# EBWiki.org Development Documentation

This contains notes, HOWTOs and other development related
information about the EBWiki.org project. This will supersede
any information available on the [wiki](https://github.com/EBWiki/EBWiki).

# [Definition of "Finished" ticket](https://github.com/EBWiki/EBWiki/Definition-of-%22Finished%22-Ticket)

In order for an issue on the EBWiki [issue](https://github.com/EBWiki/EBW/issues) tracking system, the following conditions must be met:

1. The latest code in the feature branch must build green on [TravisCI](https://travis-ci.org/EBWiki/EBWiki).
1. The latest merged code in master must build green on [TravisCI](https://travis-ci.org/EBWiki/EBWiki).
1. The person solving the ticket needs to show proof of fix working in production through movie, screenshot or other means (I think that there needs to be more clarity on this.
1. The code related to the ticket should be reviewed by at least one other developer. The other developer's stamp of approval should be on the ticket.
1. Any high level architectural design changes to the app should be outlined in DEVELOPMENT.md or another document within the Github repository.

# Precompiled Assets
Currently, EBWiki assets are precompiled in development and pushed up to
different hosts through version control. While this occurred because of a
Heroku error, this is not an optimal situation.

# Third party services
* Elasticsearch for searching cases
* Postgres 9.4 or higher
* Redis (currently for the [Split](https://github.com/splitrb/split) gem for A/B testing )