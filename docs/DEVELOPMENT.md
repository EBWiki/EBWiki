# EBWiki.org Development Documentation

Welcome to our developer documentation for EBWiki!  Thank you for committing to work with us on tackling police brutality, racial bias in criminal justice systems, and other related topics through EBWiki. Below, you'll find links, notes, HOWTOs and other useful information about developing for EBWiki.org. 

# Table of Contents
* [General Timeline for Contributing to EBWiki](#general-timeline-for-contributing-to-ebwiki)
* [Getting EBWiki Up and Running Locally](#getting-ebwiki-up-and-running-locally)
* [Restoring Local Database from Production Backup](#restoring-local-database-from-production-backup)
* [Third-Party Services](#third-party-services)

## General Timeline for Contributing to EBWiki

Here's a general overview of the process for contributing to EBWiki, outlining specifically what you do and what we do:

1. **You: Choose an issue to work on**  
You're welcome to any issue that isn't assigned to someone else.  Be sure to check if the issue is part of a milestone or project - if that's the case, then this might be one of multiple issues that need to be performed in a certain order.  
2. **You: Start working**
Once you've selected an issue, assign it to yourself and get started!  Be sure to start your work on a different branch - you won't be able to push to the main branch.
3. **You: Submit a pull request**  
Once you're finished with your work, push it up and open a pull request (PR).  Note that in each PR, there's a checklist of things you need to do before submitting.  Not all of them will be applicable every time, but you should be able to check off at least the first two each time. (Hint: put an "X" in the brackets to check off an item).
4. **You: Pass automated testing and linting**  
Once you submit your PR for review, CodeClimate and Travis will automatically run on the code in your PR.  CodeClimate will run Rubocop to analyze the code style, complexity, and quality of your code.  Travis will run all of the tests for the code.  If everything passes, great!  You'll see a nice green check mark.  If one or more things fail, it'll have a red mark next to it, along with a link for "Details" that explains what exactly is failing.  Give that a look and make changes as needed.  If something unrelated to the changes you've made is failing, just note that in a comment on the PR.
5.  **We: Review the pull request**  
Within two weeks, one of the maintainers of repo will review your PR themselves.  We'll provide some general suggestions on improving the code, ask what your motivations are behind certain changes, that type of thing.  At that point, there will be some back and forth as we put the finishing touches on your PR.
6.  **We: Merge the pull request**  
Once the code is ready to go, one of the maintainers will merge your PR and delete the branch.  And that's it!  Your portion of the work is done, and if one of the maintainers hasn't closed your issue you can go ahead and do so.  
7. **We: Check the changes on staging**  
Whenever the main branch of the repo is updated, the latest changes are deployed to the staging version of the website.  We'll use staging to do one last check to make sure everything is still working.  If we don't like the changes shown on staging, or there's some weird unanticipated side effect, we'll create a new issue and assign it to you so you can get a first crack at it.
8. **We: deploy to production**  
If everything looks great on staging, then we'll push the code to production within two weeks.  And with that, your code is be running live on [EBWiki](ebwiki.org)!

## Getting EBWiki Up and Running Locally

There are a number of guides available for running EBWiki in your local environment:
* [Running locally using a text editor and terminal](SETUP_LOCALLY.md)
* [Running in a Cloud9 workspace](https://github.com/EBWiki/EBWiki/wiki/Running-EB-Wiki-development-environment-on-Cloud9-(WIP))

## Restoring Local Database from Production Backup

The EBWiki repo has a `db/seeds.rb` file that you can use to add some basic data to your local database for development purposes.  However, there are times when you want your local database to have data similar to what you'd see in production (e.g, when working on analytics or search).  To address that, the repo also contains a recent backup of the production database, named `MM_YYYY.dump`.  To restore the backup dump into your local database, use the following command:

```
pg_restore --verbose --clean --no-acl --no-owner -p 5432 -h localhost -U blackops -d blackops_development MM_YYYY.dump
```

## Third-Party Services
* Elasticsearch for searching cases
* Postgres 9.4 or higher
* Redis 
* Sumologic
