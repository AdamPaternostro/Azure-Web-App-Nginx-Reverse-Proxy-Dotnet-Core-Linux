#!/bin/bash
 
# Start .net core app in background
dotnet /publish/nginxproxy.dll &
 
# Test with curl that our site is up and is running (all warmed up)
echo "Site test"
while true;
do
    result=`curl http://localhost:5000/Home/Index -k -s -f -o /dev/null && echo "UP" || echo "DOWN"`
    if [ "$result" = "UP" ]
    then
        break
    else
        echo "Site not up"
        sleep 1
    fi
done
echo "Site ready"
 
# Start nginx (foreground so the process does not end, we need our container to keep running in Azure)
nginx -g 'daemon off;'

