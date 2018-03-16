<p><a href="https://travis-ci.org/EBWiki/EBWiki"><img src="https://travis-ci.org/EBWiki/EBWiki.svg?branch=master" alt="Build Status" style="max-width:100%;"></a>  <a href="https://codeclimate.com/github/EBWiki/EBWiki"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/gpa.svg" /></a> <a href="https://codeclimate.com/github/EBWiki/EBWiki/coverage"><img src="https://codeclimate.com/github/EBWiki/EBWiki/badges/coverage.svg" /></a> <a href="https://www.codetriage.com/ebwiki/ebwiki"><img src="https://www.codetriage.com/ebwiki/ebwiki/badges/users.svg" /></a></p>

## Synopsis

This is the codebase behind [EBWiki.org](http://ebwiki.org), a site dedicated to documenting instances where people of color are killed by Law Enforcement Officers during routine interactions.

## Example

* Current Site: [Production](http://ebwiki.org)
* Staging Site: (requires developer access)

## Motivation

After the Walter Scott video was released showing the vast discrepancy between the official report of the encounter and the video, a group of Black technologists had the idea of a site where information on each encounter could be stored and recorded. This would help show both the frequency with which this occurs as well as the way bias affects the proceedings.

## Contributing

All developers are welcome to contribute to the codebase.  We ask that, if possible, you address issues that are labelled `high priority` first, followed by those marked as `quick fix`.  All contributors are expected to adhere to our code of conduct, which can be found [here](docs/CODE_OF_CONDUCT.md).  Thank you for your contribution - details on our stack can be found below.

## Installation

### System Requirements

* [Git](https://git-scm.com/downloads)
* [Ruby 2.4.1 or higher](https://www.ruby-lang.org/en/downloads/)
* [Rails 4.2.9 or higher](http://rubyonrails.org/)

To work on EBWiki locally you will need to have PostgreSQL and Elasticsearch running on your local environment. You will also need to have an Amazon Web Services (AWS) account to use S3 for storage. Information on how to install and configure these programs and services is listed below:

* [Sign up for a free AWS account here](https://aws.amazon.com/free/) - Note that information on how to configure your account will be detailed further below.
* [PostGreSQL](https://www.postgresql.org/) - * Postgres 9.4 or higher
* [Elasticsearch](https://www.elastic.co/products/elasticsearch) for searching cases.
* [Redis](https://redis.io/) (currently for the [Split](https://github.com/splitrb/split) gem for A/B testing ).
* [NodeJS](https://nodejs.org/en/) - Note: if you are using Windows Subsystem for Linux, you will need to follow the instructions to install Node within Ubuntu, not the standalone Windows version.
* Sendgrid (for outbound email).
* SSL using [Let's Encrypt](letsencrypt.org) and [Substrakt](https://github.com/substrakt/letsencrypt-heroku) at [End Bias Certificate Manager](https://endbias-certificate-manager.herokuapp.com/).

It is generally recommended that you have PostGreSQL and Elasticsearch start at bootup.

## Configuration

Using your command line, navigate to the location where you will store your local copy of the codebase. Use the following command to clone a copy of the repo to your local environment:

``` git clone https://github.com/EBWiki/EBWiki.git ```

Once the git clone is complete, navigate into the `BOW` folder. Then, use the following command to install dependencies:

``` bundle install ```

## AWS

Login into your Amazon Web Services (AWS) account. Navigate to the IAM service using the products tab at the top left. Select the option to create a user. Set the name of the user to be EBWiki_user, or some other similar name. Choose the option for programmatic access. Click next. Select the policy for full access s3 permissions. Click next. After reviewing the details, select create user.
Once the user has been created, open the tab to view the access key and secret access key. Add these values as environment variables to your .bashrc file. Reboot your command line prompt. If necessary, update the following files with your specific environment variable names:

* ``` /config/initializers/s3.rb ```
* ``` /config/sitemap.rb ```

If you prefer, you can add these files to `.gitignore` so that your personal changes are not tracked.

## Postgres

### Linux
Start the postgres console using the following command:

``` psql -p 5432 -h localhost -U postgres ```

Next, create a user `blackops` with the password `ebwiki` or whatever password you prefer, using the following command:

``` CREATE USER blackops WITH PASSWORD 'ebwiki'; ```

Exit the console using the following command:

``` \q ```

Save your password as an environment variable by adding the following line to your `.bashrc`file:

``` export BLACKOPS_DATABASE_PASSWORD='ebwiki' ```

## Testing

We use [RSpec](https://relishapp.com/rspec) to test the business logic
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

Thank you to all of our contributors.  Contributors to the codebase can be found [here](https://github.com/BOWiki/BOW/graphs/contributors).

## License

EBWiki is using the [Apache 2.0 License](LICENSE.txt).
