#!/bin/bash
echo "## Warming up the server..."
count=0
until [ "$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://localhost:3000)" -ne 000 ];
do
    sleep 5
    running="$(docker compose ps --status running --services 2>/dev/null | grep -c '^web$' || true)"
    if [ "${running}" = "1" ] && [ $count -lt 360 ];
    then
        echo -n "."
        count=$((count+1))
        sleep 1
    else
        echo
        echo "## Ending warm up because the server took too long or stopped unexpectedly."
        echo ""
        echo "## To debug, start the stack and open an issue with the output:"
        echo "docker compose up --build"
        echo ""
        echo "## Rebuild from scratch:"
        echo "docker compose down --volumes --remove-orphans"
        echo "docker compose build --no-cache"
        echo "docker compose up"
        exit $count
    fi
done
echo
echo "## Warm up is complete after ${count} seconds!"
echo "## Start browsing here: http://localhost:3000"
