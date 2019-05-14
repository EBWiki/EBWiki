<p><a href="https://travis-ci.org/EBWiki/EBWiki"><img src="https://travis-ci.org/EBWiki/EBWiki.svg?branch=master" alt="Build Status" style="max-width:100%;"></a>  <a href="https://codeclimate.com/github/EBWiki/EBWiki"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/gpa.svg" /></a> <a href="https://codeclimate.com/github/EBWiki/EBWiki/coverage"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/coverage.svg" /></a> <a href="https://www.codetriage.com/ebwiki/ebwiki"><img src="https://www.codetriage.com/ebwiki/ebwiki/badges/users.svg" /></a></p>

# EBWiki

[EBWiki.org](http://ebwiki.org) is a site dedicated to documenting instances where people of color are killed by law enforcement officers during routine interactions.  

## Motivation

The release of the [Walter Scott body-cam video](https://ebwiki.org/cases/walter-scott) in 2015 showed the vast discrepancy between the official report of the encounter and the video.  After seeing the video, a group of Black technologists had the idea of a site where information on each encounter could be stored and recorded. This would help show both the frequency with which this occurs as well as the way bias affects the proceedings.

Our idea, EBWiki, is designed to highlight not only the original incident between law enforcement and victims but also what happens to the family, police officers, and communities afterwards. Our goal is to become the most comprehensive resource on people of color killed by law enforcement in the United States and Canada.  Our hope is that, by shedding light on these incidents, we will move and empower others to come together to create and enact solutions.

## Contributing

All developers are welcome to contribute to the codebase.  For general information on contributing, consult [this guide](docs/DEVELOPMENT.md) on developing for EBWiki.

We ask that, if possible, you address issues that are labelled `quick fix` first, followed by those marked as `high priority`.  

Additionally, take care to note when an issue is one of several (e.g., 1 of 7, 2 of 3, etc).  Those issues are part of a project or milestone (indicated on the right side under the label), and clicking on the project or milestone should take you to a list of all of the issues.  Please note that those must be completed and merged in order.   

If this is your first open source contribution, welcome!  We're glad that you chose to get started with us.  You can find some good first issues labelled exactly that, `good first issue`.

All contributors are expected to adhere to our code of conduct, which can be found [here](docs/CODE_OF_CONDUCT.md).  Thank you for your contribution - details on our stack can be found below.

### Development

Instructions on setting up a local development environment can be found [here](docs/SETUP_LOCALLY.md).  

In general, contributors will use the following languages, frameworks, and technologies:

* [Ruby 2.6.3](https://www.ruby-lang.org/en/downloads/)
* [Rails 4.2.10](http://rubyonrails.org/)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch)
* [Postgres 9.4](https://www.postgresql.org/) or higher
* [Redis](https://redis.io/)
* [AWS S3](https://aws.amazon.com/free/)
* [NodeJS](https://nodejs.org/en/)


### Testing

We use [RSpec](https://github.com/rspec/rspec-rails), [shoulda-matchers](http://matchers.shoulda.io/), and [FactoryBot](https://github.com/thoughtbot/factory_bot) for our tests.  You can run the tests locally with the following commands:

```
rspec spec/
```

More information on how to use RSpec, shoulda-matchers, and FactoryBot can be found at the links above.  

We also use [Rubocop](https://github.com/bbatsov/rubocop) as part of our continous integration process in Travis.  To run Rubocop locally, enter

```
rubocop
```

## Contributors

Thank you to all of our contributors.  Contributors to the codebase can be found [here](https://github.com/BOWiki/BOW/graphs/contributors).

## License

EBWiki is using the [Apache 2.0 License](LICENSE.txt).
