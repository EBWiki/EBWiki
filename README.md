<p><a href="https://github.com/EBWiki/EBWiki/actions/workflows/ci.yml/badge.svg"></a> <a href="https://codeclimate.com/github/EBWiki/EBWiki"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/gpa.svg" /></a> <a href="https://codeclimate.com/github/EBWiki/EBWiki/coverage"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/coverage.svg" /></a></p>

# EBWiki

[EBWiki.org](http://ebwiki.org) is a site dedicated to documenting when people of color are killed by law enforcement officers during routine interactions.

## Motivation

The release of the [Walter Scott body-cam video](https://ebwiki.org/cases/walter-scott) in 2015 showed the vast discrepancy between the official report of the encounter and the video.  After seeing the video, a group of Black technologists had the idea of a site where information on each encounter could be stored and recorded. This would help show both the frequency with which this occurs as well as the way bias affects the proceedings.

Our idea, EBWiki, is designed to highlight not only the original incident between law enforcement and victims but also what happens to the family, police officers, and communities afterwards. Our goal is to become the most comprehensive resource on people of color killed by law enforcement in the United States and Canada.  Our hope is that, by shedding light on these incidents, we will move and empower others to come together to create and enact solutions.

## Contributing

Any and all developers are welcome to contribute to the codebase.  For general information on contributing, please read [this guide](docs/DEVELOPMENT.md) on developing for EBWiki before selecting your first issue.

If this is your first open source contribution, welcome!  We're glad that you chose to get started with us.  You can find some good first issues labelled exactly that, `good first issue`.

We ask that, if possible, you address issues that are labelled `quick fix` first, followed by those marked as `high priority`.  Otherwise, you're free to select any issue that seems interesting to you.  There are times when we may ask you to switch to another issue, as we match dev work against our internal roadmap, but that's not something you need to worry about.  In that case, we'll just let you know and provide another issue you might be interested in.

All contributors are expected to adhere to our code of conduct, which can be found [here](docs/CODE_OF_CONDUCT.md).  Thank you for your contribution - details on our stack and setting up a local environment can be found below.

### Development

Instructions on setting up a local development environment can be found in the following documents:
* [Set Up Locally with Docker](docs/SETUP_LOCALLY.md).
* [Set Up Locally with All Services (Full Stack)](docs/SETUP_LOCALLY_FULLSTACK.md).

In general, contributors will use the following languages, frameworks, and technologies:

* [Ruby 2.6.6](https://www.ruby-lang.org/en/downloads/)
* [Rails 5.0.7](http://rubyonrails.org/)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch)
* [Postgres 12](https://www.postgresql.org/) or higher
* [Redis](https://redis.io/)
* [AWS S3](https://aws.amazon.com/free/)
* [NodeJS](https://nodejs.org/en/)


### Testing

We use [RSpec](https://github.com/rspec/rspec-rails), [shoulda-matchers](http://matchers.shoulda.io/), and [FactoryBot](https://github.com/thoughtbot/factory_bot) for our tests.  You can run the tests locally with the following commands:

```
rspec spec/
```

More information on how to use RSpec, shoulda-matchers, and FactoryBot can be found at the links above.

We also use [Rubocop](https://github.com/bbatsov/rubocop) as part of our continous integration process in Github Actions.  To run Rubocop locally, enter

```
rubocop
```

### Continuous Integration (CI)
EBWiki uses Github Actions for continuous integration (CI).  Each time a ull request (PR) is opened or updated, our actions workflow will automatically perform four checks.

The full test suite will be run, to ensure that submitted changes do not break functionality elsewhere in the app.  Brakeman, Rubocop, and a link checker will also be run on the submitted changes.

As noted in our development guide, your PR is expected to pass all checks before a maintainer will merge it.  If your PR is failing one of the checks, refer to our development guide for tips on how to address the failure(s).

### Deployment
EBWiki is currently hosted on Heroku.  We have two environments - staging and production.  If you're interested in contributing but are more of a DevOps person than a developer, feel free to send us a message at info@ebwiki.org to see how you can get involved.

The staging app does require credentials to access the app.  If you need to access the staging app send us a message at info@ebwiki.org to get a copy of the credentials.

## Found a Bug?
Want to report a bug you found?  Feel free to create a new issue for it!  Please be sure to use the bug template we've created for issues.  Additionally, check our docs here and the guides on [EBWiki](https://ebwiki.org) first to see if your issue has already been addressed.

## Questions
Have any questions not covered in our docs?  Feel free to send us a message at info@ebwiki.org.

## Contributors

Thank you to all of our contributors.  Contributors to the codebase can be found [here](https://github.com/BOWiki/BOW/graphs/contributors).

## License

EBWiki is using the [Apache 2.0 License](LICENSE.txt).
