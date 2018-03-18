This guide will explain the process of setting up a local development environment for EBWiki.  The guide assumes that you are using a Linux based command line prompt and either a Linux or Windows Operating System.  If you are using a different command line prompt and/or operating system, note that the order and exact nature of the installation and configuration may vary.

# Table of Contents
1. [Prerequisites](##Prerequisites)
2. [Installation](##Installation)
3. [Configuration](##Configuration)
4. [AWS](##AWS)
5. [Postgres](##Postgres)
   * [Linux](###Linux)
   * [Windows](###Windows)
6. [Database](##Database)
7. [Finish](##Finish)

## Prerequisites
Before beginning the installation and configuration of your environment, ensure that you have a copy of git, Ruby, and Rails on your computer.  You can find installation instructions at the links below:
* [Git](https://git-scm.com/downloads)
* [Ruby v2.4.1](https://www.ruby-lang.org/en/downloads/)
* [Rails v4.2.9](http://rubyonrails.org/)

## Installation
To work on EBWiki locally you will need to have PostgreSQL and Elasticsearch running on your local environment.  You will also need to have an Amazon Web Services (AWS) account to use S3 for storage.  Information on how to install and configure these programs and services is listed below:
* [Sign up for a free AWS account here](https://aws.amazon.com/free/) - Note that information on how to configure your account will be detailed further below.
* [PostGreSQL](https://www.postgresql.org/)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch) - Keep in mind that Elasticsearch requires Java to run properly.  The latest Java Development Kit can be found [here](http://www.oracle.com/technetwork/java/javase/downloads/index.html).
* [NodeJS](https://nodejs.org/en/) - Note: if you are using Windows Subsystem for Linux, you will need to follow the instructions to install Node within Ubuntu, not the standalone Windows version.
* [Redis](https://redis.io/)


It is generally recommended that you have PostGreSQL and Elasticsearch start at bootup.

## Configuration
Using your command line, navigate to the location where you will store your local copy of the codebase.  Use the following command to clone a copy of the repo to your local environment:

`git clone https://github.com/EBWiki/EBWiki.git`

Once the git clone is complete, navigate into the `BOW` folder.  Then, use the following command to install dependencies:

`bundle install`

## AWS
Login into your Amazon Web Services (AWS) account.  Navigate to the IAM service using the products tab at the top left.  Select the option to create a user.  Set the name of the user to be EBWiki_user, or some other similar name.  Choose the option for programmatic access.  Click next. Select the policy for full access s3 permissions.  Click next.  After reviewing the details, select create user.

Once the user has been created, open the tab to view the access key and secret access key.  Add these values as environment variables to your .bashrc file.  Reboot your command line prompt.  If necessary, update the following files with your specific environment variable names:
* `/config/initializers/s3.rb`
* `/config/sitemap.rb`

If you prefer, you can add these files to `.gitignore` so that your personal changes are not tracked.

## Postgres
Choose the appropriate instruction set based on the operating system of your local environment.

### Linux
Start the postgres console using the following command:

`psql -p 5432 -h localhost -U postgres`

Next, create a user `blackops` with the password `ebwiki` or whatever password you prefer, using the following command:

`CREATE USER blackops WITH PASSWORD 'ebwiki';`

Exit the console using the following command:

 `\q`

Save your password as an environment variable by adding the following line to your `.bashrc` file:

`export BLACKOPS_DATABASE_PASSWORD='ebwiki'`

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

## Database 
Let's complete our local database setup.  First, create the development and test databases using the following command:

`rake db:create`

Then, apply the schema and migrations to the databases using the following command:

`rake db:migrate`

Finally, seed the database using:

`rake db:seed`

## Finish
Now, everything should be completely set up!  Run the app locally on your computer using the following command:

`rails s`

You should be to view and interact with the site on http://localhost:3000.  Now you're ready to get start contributing!
