#!/bin/bash

docker build -t materia-node:latest -f dockerfiles/materia-node .

echo "==================================================="
echo "to tag the latest build as a specific version, use:"
echo "$ docker tag materia-web:latest ***REMOVED***/materia-web:X.X.X"
echo "to publish the 'latest' container:"
echo "$ docker push ***REMOVED***/materia-web:latest"
echo "and"
echo "$ docker push ***REMOVED***/materia-web:X.X.X"