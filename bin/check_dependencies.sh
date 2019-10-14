#!/bin/bash

set -e

for package in elasticsearch postgresql redis-server ; do
  apt-cache show $package 2>&1 >/dev/null
done
