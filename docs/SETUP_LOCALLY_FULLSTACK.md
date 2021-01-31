```diff
- NOTE: This document contains steps for the legacy method for setting up a local development environment.
- Please refer to [the latest documentation](docs/SETUP_LOCALLY.md) for the current method using Docker.
```

This guide will explain the process of setting up a local development environment for EBWiki.  The guide assumes that you are using a Linux based command line prompt and either a Linux or Windows Operating System.  If you are using a different command line prompt and/or operating system, note that the order and exact nature of the installation and configuration may vary.

# Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [App Configuration](#app-configuration)
4. [AWS Configuration](#aws-configuration)
5. [Postgres Setup](#postgres-setup)
   * [Linux](#linux)
   * [Windows](#windows)
6. [Local Database Setup](#local-database-setup)
7. [Finish](#finish)

## Prerequisites
Before beginning the installation and configuration of your environment, ensure that you have a copy of git, Ruby, and Rails on your computer.  You can find installation instructions at the links below:
* [Git](https://git-scm.com/downloads)
* [Ruby v2.6.6](https://www.ruby-lang.org/en/downloads/)
* [Rails v5.0.7](http://rubyonrails.org/)

## Installation
To work on EBWiki locally you will need to have PostgreSQL and Elasticsearch running on your local environment.  You will also need to have an Amazon Web Services (AWS) account to use S3 for storage.  Information on how to install and configure these programs and services is listed below:
* [Sign up for a free AWS account here](https://aws.amazon.com/free/) - Note that information on how to configure your account will be detailed further below.
* [PostGreSQL](https://www.postgresql.org/)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch) - Keep in mind that Elasticsearch requires Java to run properly.  The latest Java Development Kit can be found [here](http://www.oracle.com/technetwork/java/javase/downloads/index.html).
* [NodeJS](https://nodejs.org/en/) - Note: if you are using Windows Subsystem for Linux, you will need to follow the instructions to install Node within Ubuntu, not the standalone Windows version.
* [Redis](https://redis.io/)


It is generally recommended that you have PostGreSQL and Elasticsearch start at bootup.

## App Configuration
Using your command line, navigate to the location where you will store your local copy of the codebase.  Use the following command to clone a copy of the repo to your local environment:

`git clone https://github.com/EBWiki/EBWiki.git`

**Important Note: You must clone a copy of the repo from the EBWiki organization.  If you try to fork the repo, then Travis, our continuous integration service, will error out when you submit your PR.**

Once the git clone is complete, navigate into the `EBWiki` folder.  Then, use the following command to install dependencies:

`bundle install`

![Screenshot](https://i.imgur.com/Udjb0sD.jpg)

![Screenshot](https://i.imgur.com//vN5xlOt.jpg)

![Screenshot](https://i.imgur.com/vY46FOe.jpg)

Finally, contact us at rlgreen91@gmail.com so that we can add you as a contributor to the repo - please include your Github username.  This will allow you push access to the repo so you can avoid issues with Travis.

## AWS Configuration
Login into your Amazon Web Services (AWS) account.  Navigate to the IAM service using the products tab at the top left.  Select the option to create a user.  Set the name of the user to be EBWiki_user, or some other similar name.  Choose the option for programmatic access.  Click next. Select the policy for full access s3 permissions.  Click next.  After reviewing the details, select create user.

Once the user has been created, open the tab to view the access key and secret access key.  Add these values as environment variables to your .bashrc file.  Reboot your command line prompt.  If necessary, update the following files with your specific environment variable names:
* `/config/initializers/s3.rb`
* `/config/sitemap.rb`

If you prefer, you can add these files to `.gitignore` so that your personal changes are not tracked.

![Screenshot](https://i.imgur.com/AjfaJLd.jpg)

![Screenshot](https://i.imgur.com/KFvdZgx.jpg)

![Screenshot](https://i.imgur.com/2UAsjDy.jpg)

![Screenshot](https://i.imgur.com/RKkiuXV.jpg)

![Screenshot](https://i.imgur.com/TyHKkPI.jpg)

![Screenshot](https://i.imgur.com/TyHKkPI.jpg)

![Screenshot](https://i.imgur.com/89XU1nF.jpg)


## Postgres Setup
Choose the appropriate instruction set based on the operating system of your local environment.

### Linux
Start the postgres console using the following command:

`psql -p 5432 -h localhost -U postgres`

Next, create a user `blackops` with the password `ebwiki` or whatever password you prefer, using the following command:

`CREATE USER blackops WITH PASSWORD 'ebwiki';`

Exit the console using the following command:

 `\q`

## Recaptcha & Local Development

While in production we use [reCAPTCHA](https://www.google.com/recaptcha) to
prevent bots from sigining up for this service, in order to simplify
development, reCAPTCHA is disabled in development by default.  In order
to re-enable reCAPTCHA in development, remove the `config/initializers/recaptcha.rb`
file or comment out the following line:
```
config.skip_verify_env.push('development')
```

### Environmental Variables

EBWiki uses environmental variables to run with different configurations in
different environments through the [dotenv](https://github.com/bkeepers/dotenv)
gem. For more information, consult the dotenv documentation, but in the meantime,
to set the variables, create a file named
`.env` at the top level of the project and fill in data for the following:
In order to fill in this credentials, you'll have to get:
* AWs Credentials from Amazon.com
* Mailchimp Credentials from Mailchimp.com. Failing that, get the configuration
from an EBWiki team member


```
AWS_ACCESS_KEY_ID=<AWS Credentials>
AWS_SECRET_KEY_ID=<AWS Credentials>
MAILCHIMP_API_KEY=<Mailchimp Credentials>
MAILCHIMP_LINK=<Mailchimp Credentials>
MAILCHIMP_LIST_ID=<Mailchimp Credentials>
SEARCHBOX_URL=<Elasticsearch URL>
CODECLIMATE_REPO_TOKEN=<Codeclimate API>
AUTOBUS_SNAPSHOT_URL=<Autobus URL>
BLACKOPS_DATABASE_PASSWORD=<local database password>
```

### Windows
Start the postgres console using the following command:

`psql -p 5432 -h localhost -U postgres`

Next, create a user `blackops` with the password `ebwiki` or whatever password you prefer, using the following command:

`CREATE USER blackops WITH PASSWORD 'ebwiki';`

Exit the console using the following command:

`\q`

Save your password as an environment variable by adding the following line to your `.bashrc` file:

`export BLACKOPS_DATABASE_PASSWORD='ebwiki'`

Within `config/database.yml`, uncomment the following lines in the blocks for `development`, `test`, and `production`:

`username: blackops`

`password:<%= ENV['BLACKOPS_DATABASE_PASSWORD'] %>`


`host: localhost`

`port:5432`

![Screenshot](https://i.imgur.com/XJADAoj.jpg)

![Screenshot](https://imgur.com/EGbEdvg.jpg)

![Screenshot](https://i.imgur.com/CdOnsI7.jpg)

## Local Database Setup
Let's complete our local database setup.  First, create a copy of config/database.example.yml to config/database.yml using:

`cp config/database.example.yml config/database.yml`

You may need to change the username and/or password to the ones you used during postgres setup before proceeding. You don't need to change anything if you used `ebwiki` as the password.

Now, create the development and test databases using the following command:

`rake db:create`

Then, apply the schema and migrations to the databases using the following command:

`rake db:migrate`

Finally, seed the database using:

`rake db:seed`

## Finish
Now, everything should be completely set up!  Run the app locally on your computer using the following command:

`rails s`

You should be to view and interact with the site on http://localhost:3000.  Now you're ready to get start contributing!
