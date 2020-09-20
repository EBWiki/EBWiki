#!/bin/bash
echo "## Warming up the server..."
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://localhost:3000) -ne 000 ];
do
    echo -n ".";
    sleep 1;
done
echo
echo "## Prewarm is complete!"
