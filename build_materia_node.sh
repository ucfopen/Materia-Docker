#!/bin/bash

docker build -t materia-node:latest -f dockerfiles/materia-node .

echo "==================================================="
echo "to tag the latest build as a specific version, use:"
echo "$ docker tag materia-node:latest ***REMOVED***/materia-node:latest"
echo "$ docker tag materia-node:latest ***REMOVED***/materia-node:X.X.X"
echo "to publish the 'latest' container:"
echo "$ docker push ***REMOVED***/materia-node:latest"
echo "$ docker push ***REMOVED***/materia-node:X.X.X"
