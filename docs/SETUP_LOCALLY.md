This guide will explain the process of setting up a local development environment for EBWiki.  The guide assumes that you are using a Linux based command line prompt and either a Mac, Windows, or Linux Operating System.

# Table of Contents
- [Prerequisites](#prerequisites)
- [Set Up](#setup)
- [Browse the Local Site](#browse)
- [Finish](#finish)

## Prerequisites
Before setting up your local development environment, make sure you have the following tools installed:
* [Git](https://git-scm.com/downloads)
* [Docker Desktop](https://docs.docker.com/engine/install/)
* [Make](https://www.gnu.org/software/make/)

Open a terminal and validate your environment with the following commands:
```
which git
git --version
which docker
docker --version
which make
make --version
```

Output from the commands should be error free and similar to the following:
```
$ which git
/usr/local/bin/git

$ git --version
git version 2.28.0

$ which docker
/usr/local/bin/docker

$ docker --version
Docker version 19.03.12, build 48a66213fe

$ which make
/usr/bin/make

$ make --version
GNU Make 4.3
...
```

## Set Up
Once your tools are in place, follow these steps to download and run the EBWiki application on your local system:

1. Clone the EBWiki repository and `cd` into the directory.
```
git clone git@github.com:EBWiki/EBWiki.git
cd EBWiki
```

1. Download the latest `ebwiki` docker image:
```
docker pull ebwiki/ebwiki
```

1. Start a locally running application with the following command:
```
make run logs
```
This starts EBWiki and follows the logs of the server running the process.  Once you see output similar to the following, the application is running successfully:
```
#########################################################
##  Environment Summary
#########################################################
rails   = Rails 5.0.7.2
ruby    = ruby 2.6.5p114 (2019-10-01 revision 67812) [x86_64-linux]
node    = v10.21.0
npm     = 5.8.0
java    = openjdk version "11.0.8" 2020-07-14
psql    = psql (PostgreSQL) 11.7 (Debian 11.7-0+deb10u1)
redis   = v=5.0.3
elastic = {
  "name" : "B7V3I3w",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "YNzzm9I7QIyeR8pBRadlAw",
  "version" : {
    "number" : "6.8.12",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "7a15d2a",
    "build_date" : "2020-08-12T07:27:20.804867Z",
    "build_snapshot" : false,
    "lucene_version" : "7.7.3",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
#########################################################
## Starting the server...
```

## Browse the Local Site
With the application running, you can access the application locally.

Open the following link in your browser:  http://localhost:3000

## Finish
Now you're ready to start contributing!

Next: [Development Documentation](docs/DEVELOPMENT.md).
