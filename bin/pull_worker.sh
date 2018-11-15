#!/bin/bash

TAG=$(grep -e 'mumuki/mumuki-html-worker:[0-9]*\.[0-9]*' ./lib/html_runner.rb -o | tail -n 1)

echo "Pulling $TAG..."
docker pull $TAG
