This guide sets up a local EBWiki environment with Docker Compose. Postgres 17 and Redis 7 run as sidecars. Case search is `pg_search` — there is no Elasticsearch container.

# Table of Contents
- [Prerequisites](#prerequisites)
- [Set Up](#setup)
- [Browse the Local Site](#browse)
- [Compose services cannot reach each other](#compose-services-cannot-reach-each-other)
- [Finish](#finish)

## Prerequisites
Before setting up your local development environment, make sure you have the following tools installed:
* Bash
  * Windows: [Install Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install)
  * MacOS: [Install Homebrew](https://brew.sh/) and then `brew install bash`
* Git
  * Windows: [Download and install git](https://git-scm.com/downloads)
  * MacOS: [Install Homebrew](https://brew.sh/) and then `brew install git`
* [Docker Engine or Docker Desktop](https://docs.docker.com/engine/install/) (Compose V2: `docker compose`; Buildx: `docker buildx`)
* [Make](https://www.gnu.org/software/make/)

Open a terminal and validate your environment with the following commands:
```
which bash
bash --version
which git
git --version
which docker
docker --version
docker compose version
docker buildx version
which make
make --version
```

Output from the commands will vary based on your operating system but should be error free and similar to the following:
```
$ docker --version
Docker version 29.1.3

$ docker compose version
Docker Compose version v2.40.3

$ docker buildx version
github.com/docker/buildx 0.30.1
```

## Set Up
Once your tools are in place, follow these steps to download and run the EBWiki application on your local system:

1. Clone the EBWiki repository and `cd` into the directory.
    ```
    git clone git@github.com:EBWiki/EBWiki.git
    cd EBWiki
    ```
1. Build and start the stack (app image, Postgres 17, Redis 7):
    ```
    make run
    ```

    `make run` is `docker compose build` plus `docker compose up --detach`. The first build compiles native gems and takes several minutes.

    To pull a previously published image instead of building:
    ```
    docker pull ebwiki/ebwiki
    docker compose up --detach
    ```

    The published `ebwiki/ebwiki` image is the Rails app only. It does **not** include Postgres or Redis; those come from `compose.yaml`.

Once you see output similar to the following, the application is running successfully:
```
## Warming up the server...
## Warm up is complete! Start browsing here: http://localhost:3000
```

Useful targets:

```
make logs    # follow compose logs
make exec    # shell in the web container
make rspec   # RSpec against Compose Postgres
make stop    # docker compose down
```

## Browse the Local Site
With the application running, you can access the application locally.

Open the following link in your browser:  http://localhost:3000

## Compose services cannot reach each other

If `web` times out talking to Postgres (`pg_isready` from another container on the same Compose network has 100% loss), the host is likely sending bridge traffic through `iptables-legacy` while Docker 29 programs `nft`. Check with `sudo iptables-legacy -L FORWARD -n` (policy `DROP` and no live Docker rules) and:

```
sudo sysctl -w net.bridge.bridge-nf-call-iptables=0
sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=0
```

Then retry `make run`. This does not change the image; it only lets the bridge forward container-to-container packets.

## Finish
Now you're ready to start contributing!

Next: [Development Documentation](DEVELOPMENT.md).
