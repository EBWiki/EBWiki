This guide will explain the process of deploying the latest version of EBWiki to production.  

**Important Note: If you are on a computer with the Windows Operating System, you must execute the following commands within the Windows Powershell or Command Prompt terminals, even if Windows Subsytem for Linux is installed.**

# Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deploy to Heroku](#deploy-to-heroku)
3. [Handling the Database](#handling-the-database)
4. [Reindex for Search](#reindex-for-search)

## Prerequisites
Before getting started, install a copy of the Heroku CLI on your computer.  You can find the installation instructions at the link below:

[Heroku CLI](https://devcenter.heroku.com/categories/command-line)

Once you've installed the CLI, login in the terminal using the following command:

```
heroku login
```

Enter the email and password associated with your Heroku account when prompted.  Next, either create a new ssh key or upload an existing one when prompted.

## Deploy to Heroku
In your terminal, navigate to the EBWiki directory, and pull the latest version of the main branch.

If you need to add a remote to your local repository , use the following command:

```
heroku git:remote -a ebwiki
```

Deploy your app to Heroku using the following command:

```
git push heroku main
```

## Handling the Database
Now that you've successfully pushed your main branch to the remote, migrate the database:

```
heroku run rake db:migrate
```

If there are any changes to the database, then it's a good time to refresh the production backup stored on the repo.  To create a new backup and download it, use the following commands:

```
heroku pg:backups:capture
heroku pg:backups:download
```

In another terminal, delete the old production backup and rename the latest one from `latest.dump` to `MM_YYYY.dump`, with the appropriate values filled in. 

## Reindex for Search

Finally, let's redo the indexes we use for searching in the app:

```
heroku run rake searchkick:reindex:all  --app ebwiki
```

And with that, we're done!