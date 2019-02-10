The first step is to get [AWS Cloud9](https://docs.aws.amazon.com/cloud9/latest/user-guide/setup-express.html) running with an Amazon account. Once I logged in, I created a new environment using the Cloud9 interface. I selected the t2.micro EC2 option as EBWiki can run in under 1GB. When the environment is created, the Cloud9 page is available, with a console in the lower right, navigation on the upper left and editor windows on the upper right.

![AWS Cloud9 Environment](https://i.imgur.com/tKuc69A.png)

## Create authentication credentials for Github access
The new instance needs credentials to be able to retrieve the repository from Github. In order to create an SSH key to attach to the developer's Github account, do the following:
1. Create an SSH Key using the `ssh-keygen -t rsa -b 4096` command. Follow the prompts to create a public/private key pair.
2. Copy the public key to the clipboard. The public key is located in `~/.ssh/id_rsa.pub`. Typing `less ~/.ssh/id_rsa.pub` shows the public key. Copy all the text from "ssh" to the "ec2-X-X-X-X" string.
![Public Key](https://i.imgur.com/0HQWOJ4.png)
3. Login to Github.
4. Click on your profile image in the upper right, then select "Settings".
5. Click on "SSH & GPG Keys" on the left navigation.
6. Click on the green "New SSH Key" button.
7. On the following page, enter an alias for the key in the input and paste the key into the textarea.
8. Save the key.
9. Go back to the AWS Cloud9 Browser window and clone the EBWiki repo with `git clone git@github.com:EBWiki/EBWiki.git`. The results should look like the following:
![git clone](https://i.imgur.com/fyCTkvX.png)

Now the repository is on the instance. The next step is to install software needed for EBWiki to run.

## Install system requirements
### Ruby

As of this writing, Ruby 2.4.1 is installed with RVM. As this is the version that works with EBWiki, there's no more to do.

### Postgres

Follow the installation instructions for installing & setting up PostgreSQL. This [article](http://imperialwicket.com/aws-install-postgresql-90-on-amazon-linux/) as well as a couple of sources contributed to the sequence of commands outlined below:
1. `sudo yum update` 
1. `wget https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-ami201503-96-9.6-2.noarch.rpm`
1. `sudo rpm -ivh pgdg-ami201503-96-9.6-2.noarch.rpm`
1. `sudo vim /etc/yum.repos.d/pgdg-96-ami201503.repo`
1. At the bottom of the `"[amzn-main]"` section, after `enabled=1`, add `exclude=postgresql*` and exit `vim` 
1. `sudo vim /etc/yum.repos.d/amzn-updates.repo`
1. At the bottom of the `"[amzn-updates]"` section, after `enabled=1`, add `exclude=postgresql*` and exit `vim`
1. `sudo yum install postgresql postgresql-contrib postgresql-devel postgresql-server postgresql-docs`
1. `sudo service postgresql-9.6 initdb`
1. `sudo sed -i.bak -e 's/ident$/md5/' -e 's/peer$/md5/' /var/lib/pgsql/9.6/data/pg_hba.conf`
1. `sudo /sbin/chkconfig --levels 235 postgresql-9.6 on`
1. `sudo service postgresql-9.6 start`
1. `sudo -u postgres createuser ec2-user`

### Redis
Redis can be installed easily with the following command:
`sudo yum install redis`

### Elasticsearch
1. `sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch`
1. `sudo emacs /etc/yum.repos.d/elasticsearch.repo`
1. Put the following information in the file:
```
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```
4. `sudo yum install elasticsearch`
5. `sudo yum install java-1.8.0-openjdk-devel`
6. `sudo /usr/sbin/alternatives --config java`
7. Select "1.8.0"
8. `sudo /usr/sbin/alternatives --config javac`
9. Select "1.8.0"
10. `sudo emacs /etc/elasticsearch/jvm.options` 
11. Set heap space
```
# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space

-Xms256m
-Xmx256m
``` 
12. `sudo service elasticsearch start`

### Install & Configure Rails & Postgres to bring configuration together

1. `sudo su - postgres`
1. `psql`
1. `ALTER USER "ec2-user" WITH SUPERUSER;`
1. `\q`
1. `exit`
1. create `.env` and fill in data for the following:
```
AWS_ACCESS_KEY_ID=<AWS Credentials>
AWS_SECRET_KEY_ID=<AWS Credentials>
MAILCHIMP_API_KEY=<Mailchimp Credentials>
MAILCHIMP_LINK=<Mailchimp Credentials>
MAILCHIMP_LIST_ID=<Mailchimp Credentials>
SEARCHBOX_URL=<Elasticsearch URL>
CODECLIMATE_REPO_TOKEN=<Codeclimate API>
AUTOBUS_SNAPSHOT_URL=<Autobus URL>
```
1. `bundle exec rake db:setup`
1. `bundle exec rails server -b 0.0.0.0 -p 8080`

