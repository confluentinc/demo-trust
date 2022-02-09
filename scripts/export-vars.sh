#!/bin/bash

echo "exporting environment variables"

if [ -f ~/demo-trust/scripts/.env ]; then
    echo "exporting $(echo $(cat ~/demo-trust/scripts/.env | sed 's/#.*//g'| xargs) | envsubst)"
    export $(echo $(cat ~/demo-trust/scripts/.env | sed 's/#.*//g'| xargs) | envsubst)
else
    echo "this script assumes demo-trust has been cloned to your home folder. Try again."
fi