# EBWiki.org Development Documentation

This contains notes, HOWTOs and other development related
information about the EBWiki.org project. This will supersede
any information available on the [wiki](https://github.com/BOWiki/BOW/wiki).

# [Definition of "Finished" ticket](https://github.com/BOWiki/BOW/wiki/Definition-of-%22Finished%22-Ticket)

In order for an issue on the BOW [issue](https://github.com/BOWiki/BOW/issues) tracking system, the following conditions must be met:

1. The latest code in the feature branch must build green on [TravisCI](https://travis-ci.org/BOWiki/BOW).
1. The latest merged code in master must build green on [TravisCI](https://travis-ci.org/BOWiki/BOW).
1. The person solving the ticket needs to show proof of fix working in production through movie, screenshot or other means (I think that there needs to be more clarity on this.
1. The code related to the ticket should be reviewed by at least one other developer. The other developer's stamp of approval should be on the ticket.
1. Any high level architectural design changes to the app should be outlined in DEVELOPMENT.md or another document within the Github repository.
