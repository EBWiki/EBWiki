#!/bin/bash -e

echo "## Running tests for seed cases..."
for i in sven-svensson janez-novak max-mustermann janina-kowalska chichiko-bendeliani mario-rossi;
do
    curl --max-time 60 -sLk -o /dev/null \
        -w "%{time_total} %{num_redirects} %{http_code} %{url_effective}\n" \
        "http://localhost:3000/cases/${i}" | grep 200;
done
echo "## Tests for seed cases complete!"
