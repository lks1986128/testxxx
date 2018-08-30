#!/bin/bash

cd microservice1-app/;
mvn -Prd dockerfile:build;
docker tag microservice1-app:1.0 dtr.yourdomain.com/app/microservice1-app:1.0;
docker rmi microservice1-app:1.0;

docker login dtr.yourdomain.com --username admin --password dtrpassword;
docker push dtr.yourdomain.com/app/microservice1-app:1.0;

if [ "$(docker service ls -f 'name=microservice1-app' | grep microservice1-app)" ];
then
    docker service update --image dtr.yourdomain.com/app/microservice1-app:1.0 microservice1-app;
    echo 'updated service for microservice1-app.';
else
    docker service create --name microservice1-app --replicas 1 --network your-overlay --constraint node.labels.node.type==worker --constraint node.labels.node.env==dev --env SPRING_PROFILES_ACTIVE=dev,zipkin,swagger --publish 
8081:8081 dtr.yourdomain.com/app/microservice1-app:1.0;
    echo 'created service for microservice1-app.';
fi
