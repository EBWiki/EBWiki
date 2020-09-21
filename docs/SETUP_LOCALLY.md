This guide will explain the process of setting up a local development environment for EBWiki.  The guide assumes that you are using a Linux based command line prompt and either a Mac, Windows, or Linux Operating System.

# Table of Contents
- [Prerequisites](#prerequisites)
- [Set Up](#setup)
- [Browse the Local Site](#browse)
- [Finish](#finish)

## Prerequisites
Before setting up your local development environment, make sure you have the following tools installed:
* Bash
  * Windows: [Install Windows Subsystem for Linux](https://www.windowscentral.com/install-windows-subsystem-linux-windows-10)
  * MacOS: [Install homebrew](https://brew.sh/) and then `brew install bash`
* Git
  * Windows: [Download and install git](https://git-scm.com/downloads)
  * MacOS: [Install homebrew](https://brew.sh/) and then `brew install make`
* [Docker Desktop](https://docs.docker.com/engine/install/)
* [Make](https://www.gnu.org/software/make/)

Open a terminal and validate your environment with the following commands:
```
which bash
bash --version
which git
git --version
which docker
docker --version
which make
make --version
```

Output from the commands will vary based on your operating system but should be error free and similar to the following:
```
$ which bash
/usr/local/bin/bash

$ bash --version
GNU bash, version 5.0.18(1)-release (x86_64-apple-darwin18.7.0)
...

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
    make run
    ```

Note that it will take about 3-5 minutes for the server to boot up.  This is normal.

Once you see output similar to the following, the application is running successfully:
```
## Warming up the server...
## Warm up is complete! Start browsing here: http://localhost:3000
```

## Browse the Local Site
With the application running, you can access the application locally.

Open the following link in your browser:  http://localhost:3000

## Finish
Now you're ready to start contributing!

Next: [Development Documentation](docs/DEVELOPMENT.md).
