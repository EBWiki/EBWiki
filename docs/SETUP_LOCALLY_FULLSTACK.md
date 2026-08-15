```diff
- NOTE: This document contains steps for the legacy method for setting up a local development environment.
- Please refer to [the latest documentation](docs/SETUP_LOCALLY.md) for the current method using Docker.
```

This guide will explain the process of setting up a local development environment for EBWiki.  The guide assumes that you are using a Linux based command line prompt and either a Linux or Windows Operating System.  If you are using a different command line prompt and/or operating system, note that the order and exact nature of the installation and configuration may vary.

# Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [App Configuration](#app-configuration)
4. [Environment Variables](#environment-variables)
5. [Postgres Setup](#postgres-setup)
   * [Linux](#linux)
   * [Windows](#windows)
6. [Local Database Setup](#local-database-setup)
7. [AWS Configuration](#aws-configuration)
8. [Finish](#finish)

## Prerequisites
Before beginning the installation and configuration of your environment, ensure that you have a copy of git, Ruby, and Rails on your computer.  You can find installation instructions at the links below:
* [Git](https://git-scm.com/downloads)
* [Ruby v3.4.2](https://www.ruby-lang.org/en/downloads/)
* [Rails v8.1](http://rubyonrails.org/)

## Installation
To work on EBWiki locally you will need PostgreSQL and Redis running. Case search uses Postgres full-text search (`pg_search`); Elasticsearch is no longer required.
* [PostGreSQL](https://www.postgresql.org/) 12 or higher (17 in CI)
* [Redis](https://redis.io/)

It is generally recommended that you have PostgreSQL start at bootup.

## App Configuration
Using your command line, navigate to the location where you will store your local copy of the codebase.  Create your own personal fork of our repo, and then clone a copy of your fork to your local environment:

Once the git clone is complete, navigate into the `EBWiki` folder.  Then, use the following command to install dependencies:

`bundle install`

![Screenshot](https://i.imgur.com/Udjb0sD.jpg)

![Screenshot](https://i.imgur.com//vN5xlOt.jpg)

![Screenshot](https://i.imgur.com/vY46FOe.jpg)

With that, you'll have your own copy of the latest version of EBWiki on your local machine.  However, there are still a couple fo steps to take before you can run the site locally.

## Environment Variables

EBWiki uses environment variables to run with different configurations in
different environments through the [dotenv](https://github.com/bkeepers/dotenv)
gem. A sample file named
`.env.example` has already been provided at the top level of the project.  You can use this sample file to create your own `.env` file.  All of the variables listed in the sample file are optional.
The only required variable that you will need to add is the database password, as described in further detail below.

## Postgres Setup
Choose the appropriate instruction set based on the operating system of your local environment.

### Linux
First, create the file `config/database.yml` by copying `config/database.example.yml`.  Then, start the postgres console using the following command:

`psql -p 5432 -h localhost -U postgres`

Next, create a user `blackops` with the password `ebwiki` or whatever password you prefer, using the following command:

`CREATE USER blackops WITH PASSWORD 'ebwiki';`

Exit the console using the following command:

 `\q`

Add the password as an environment variable in your `.env` file:

`BLACKOPS_DATABASE_PASSWORD='ebwiki'`

Within `config/database.yml`, uncomment the following lines in the blocks for `development` and `test`:

```
username: blackops
password:<%= ENV['BLACKOPS_DATABASE_PASSWORD'] %>
```

### Windows
First, create the file `config/database.yml` by copying `config/database.example.yml`.  Then, start the postgres console using the following command:

`psql -p 5432 -h localhost -U postgres`

Next, create a user `blackops` with the password `ebwiki` or whatever password you prefer, using the following command:

`CREATE USER blackops WITH PASSWORD 'ebwiki';`

Exit the console using the following command:

`\q`

Add the password as an environment variable in your `.env` file:

`BLACKOPS_DATABASE_PASSWORD='ebwiki'`

Within `config/database.yml`, uncomment the following lines in the blocks for `development` and `test`:

```
username: blackops
password:<%= ENV['BLACKOPS_DATABASE_PASSWORD'] %>
host: localhost
port:5432
```

![Screenshot](https://i.imgur.com/XJADAoj.jpg)

![Screenshot](https://imgur.com/EGbEdvg.jpg)

![Screenshot](https://i.imgur.com/CdOnsI7.jpg)

## Local Database Setup
Let's complete our local database setup.  First, create the development and test databases using the following command:

`rails db:create`

Then, recreate the schema from **structure.sql** using the following command:

`rails db:structure:load`

Finally, seed the database using:

`rails db:seed`

## AWS Configuration
In production, EBWiki stores uploaded case photos with Active Storage on AWS S3 when `S3_BUCKET` is set. In development and test, Active Storage uses the local disk service.

To use S3 in development, set `S3_BUCKET`, `S3_KEY`, `S3_SECRET`, and `S3_REGION` in your `.env` file (see `config/storage.yml`) and point `config.active_storage.service` at `:amazon`.

## Finish
Now, everything should be completely set up!  Run the app locally on your computer using the following command:

`rails s`

You should be to view and interact with the site on http://localhost:3000.  Now you're ready to get start contributing!
