#Contributing To EBWiki

##Install Project
After forking and cloning the latest repo follow these steps:

Add remote upstream repo to your local repo with     
```$ git remote add upstream https://github.com/BOWiki/BOW```   
Keep your local repo up to date with the upstream repo with     
```$ git fetch upstream```      
```$ git merge upstream/master```    

[Install Heroku Toolbelt and configure your account](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up) if you haven't already.  

Request access to the blackops-staging database on Heroku from an EBWiki/BOWiki admin.  
Clone blackops-staging to local machine:   
```$ heroku git:clone -a blackops-staging```

Get database information using    
```$ heroku config -a blackops-staging```    
Copy and paste the proper information from that into a new `.env` file in the your BOW root folder with the following:
```
AWS_ACCESS_KEY_ID=[from database info]
AWS_SECRET_KEY_ID=[from database info]
BONSAI_URL=[from database info]
S3_BUCKET=blackops-staging
```
Make sure to include `/.env` in your `.gitignore` file so the keys aren't added to the git repo.

[Install Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html).    
If you have a Mac and Homebrew, you can use:   
```$ brew install elasticsearch```    
Note: If you don't have java installed you will have to do that as well.  

[Install PostgreSQL](http://www.postgresql.org/download/).  
If you have a Mac and Homebrew, you can use:    
```$ brew install postgresql```    
Create your own user account(these are backticks, not single quotes):    
```$ createdb `whoami` ```    
Create blackops-development and blackops-test database:   
```$ createdb blackops_development
$ createdb blackops_test```

From local blackops-staging directory run the following commands to import the staging data into your local databases:     
```$ heroku pg:backups capture
$ curl -o latest.dump `heroku pg:backups public-url`
$ pg_restore --verbose --clean --no-acl --no-owner -h localhost -U [local username] -d blackops_development latest.dump
$ pg_restore --verbose --clean --no-acl --no-owner -h localhost -U [local username] -d blackops_test latest.dump```     

Back in your BOW root folder run:    
```$ bundle exec rake db:migrate```

Build elasticsearch indexes for the Article and State classes with:    
```$ bundle exec rake searchkick:reindex CLASS=Article
$ bundle exec rake searchkick:reindex CLASS=State```

You should be good to go now for local development and tests. Just make sure to keep your local repo up to date with the upstream repo.









