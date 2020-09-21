#!/bin/bash -e
echo "## Running tests for seed cases..."

pass=0
fail=0

for i in sven-svensson janez-novak max-mustermann janina-kowalska chichiko-bendeliani mario-rossi;
do
    curl --fail --max-time 60 -sLk -o /dev/null \
        -w "%{time_total} %{num_redirects} %{http_code} %{url_effective}\n" \
        "http://localhost:3000/cases/${i}" \
        && pass=$((pass+1)) || fail=$((fail+1));
done

echo "## Tests for seed cases complete!"
echo "Pass: $pass"
echo "Fail: $fail"

if [ $fail -gt 0 ];
then
    exit $fail;
fi
