<p><a href="https://travis-ci.org/EBWiki/EBWiki"><img src="https://travis-ci.org/EBWiki/EBWiki.svg?branch=master" alt="Build Status" style="max-width:100%;"></a>  <a href="https://codeclimate.com/github/EBWiki/EBWiki"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/gpa.svg" /></a> <a href="https://codeclimate.com/github/EBWiki/EBWiki/coverage"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/coverage.svg" /></a></p>

## Synopsis

This is the codebase behind [EBWiki.org](http://ebwiki.org), a site dedicated to documenting instances where people of color are killed by Law Enforcement Officers during routine interactions.

## Example

* Current Site: [Production](http://ebwiki.org)
* Staging Site: (requires developer access)

## Motivation

After the Walter Scott video was released showing the vast discrepancy between the official report of the encounter and the video, a group of Black technologists had the idea of a site where information on each encounter could be stored and recorded. This would help show both the frequency with which this occurs as well as the way bias affects the proceedings.

## Installation

### System Requirements

* Ruby 2.4.1 or higher
* Rails 4.2.9 or higher
* Elasticsearch for searching cases
* Postgres 9.4 or higher
* Redis (currently for the [Split](https://github.com/splitrb/split) gem for A/B testing )
* Sendgrid (for outbound email)
* SSL using [Let's Encrypt](letsencrypt.org) and [Substrakt](https://github.com/substrakt/letsencrypt-heroku) at [End Bias Certificate Manager](https://endbias-certificate-manager.herokuapp.com/)

## Testing

We use [RSpec](https://relishapp.com/rspec) to test the business logic.
In addition, we use [Travis](https://travis-ci.org/BOWiki/BOW/) as a Continuous
Integration (CI) Server and
[Code Climate](https://codeclimate.com/github/BOWiki/BOW) to monitor code quality.
We also use [bullet](https://github.com/flyerhzm/bullet) to detect an N+1 query
and raise an exception and fail the build, whether local or in CI.

## Services

EBWiki uses the following 3rd party services:
* Trello for business project management
* Monitis for system monitoring
* Heroku for hosting
* AWS S3 for file uploads

## Contributors

Contributors to this project can be found [here](https://github.com/BOWiki/BOW/graphs/contributors).

## License

EBWiki is using the [Apache 2.0 License](LICENSE.txt).

## Code of Conduct

Our code of conduct can be found [here](docs/CODE_OF_CONDUCT.md).
