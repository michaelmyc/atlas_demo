#!/bin/bash

DB_PASS=password

docker kill atlas-demo-dev
sleep 1
docker run --rm -d --name atlas-demo-dev -p 3307:3306 -e MYSQL_ROOT_PASSWORD=${DB_PASS} mysql

while ! docker exec -i atlas-demo-dev mysql -u root -p${DB_PASS} -e "SHOW DATABASES;" >/dev/null 2>&1 > /dev/null; do
    sleep 1
done

docker exec -i atlas-demo-dev mysql -u root -p${DB_PASS} < schema/ddl/create_db.sql