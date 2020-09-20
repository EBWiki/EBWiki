This guide will explain the process of setting up a local development environment for EBWiki.  The guide assumes that you are using a Linux based command line prompt and either a Mac, Windows, or Linux Operating System.  If you are using a different command line prompt and/or operating system, note that the order and exact nature of the installation and configuration may vary.

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

You can validate your environment with the following commands:
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
Once your tools are in place, follow these steps to get set up:

1. Clone the EBWiki repository and `cd` into the directory.
```
git clone git@github.com:EBWiki/EBWiki.git
cd EBWiki
```

1. Download the latest `ebwiki` docker image:
```
docker pull ebwiki/ebwiki
```

1. Start a locally running EBwiki process:
```
make run
```

## Browse the Local Site
With the application running, you can access the site locally.

Open the following link in your browser:  http://localhost:3000

## Finish
Now you're ready to get start contributing!  Move on to the [Development Documentation](docs/DEVELOPMENT.md).
