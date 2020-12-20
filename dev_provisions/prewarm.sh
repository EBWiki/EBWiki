#!/bin/bash
echo "## Warming up the server..."
count=0
until [ "$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://localhost:3000)" -ne 000 ];
do
    sleep 5;
    CURRENT_CONTAINERS=`docker container inspect -f '{{.State.Running}}' ebwiki`
    echo "Container inspection status: $CURRENT_CONTAINERS"
    if [ "$( docker container inspect -f '{{.State.Running}}' ebwiki )" == "true" ] && [ $count -lt 360 ];
    then
        echo -n ".";
	echo "Docker images";
	docker images
        count=$((count+1))
        sleep 1;
    else
        echo
        echo "## Ending warm up because the server took too long or stopped unexpectedly."
        echo ""
        echo "## To debug, start the server with the following commands and open an issue with the output:"
        echo "docker run --volume .:/usr/src/ebwiki --publish 3000:3000 --name ebwiki ebwiki/ebwiki"
        echo ""
        echo "## You can also use these commands to build the server image from scratch and then run it:"
        echo "docker container rm ebwiki"
        echo "docker image rm ebwiki/ebwiki:latest"
        echo "docker build --tag ebwiki/ebwiki ."
        echo "docker run --volume .:/usr/src/ebwiki --publish 3000:3000 --name ebwiki ebwiki/ebwiki"
        exit $count
    fi
done
echo
echo "## Warm up is complete after ${count} seconds!"
echo "## Start browsing here: http://localhost:3000"
