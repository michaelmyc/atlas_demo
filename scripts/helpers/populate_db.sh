#!/bin/bash

DB_PASS=password

docker exec -i $1 mysql -u root -p${DB_PASS} < schema/ddl/populate_db.sql