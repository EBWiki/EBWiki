#!/bin/bash
echo "## Warming up the server..."
count=0
until [ $(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://localhost:3000) -ne 000 ] | [ ${count} -gt 360 ];
do
    echo -n ".${count}";
    count=$((count+1))
    sleep 1;
done
echo
if [ $count -gt 360 ];
then
    echo "## Ending warm up because the server took too long.  There might be a problem with the server. :("
    exit $count
else
    echo "## Warm up is complete!"
fi
