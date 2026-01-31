#!/usr/bin/env python
#encoding: UTF-8

# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

# connect to the database and create the infrastructure for the smart data tables.
#
# start by importing PyGreSQL

from pg import DB
db = DB(dbname='sensordata', host='imac.lan', port=5432, user='sensor_main', passwd='SuperSensor')


#if __name__ == "__main__":
#    print "Hello World"

# first drop all the tables
for f in db.get_tables():
    query="DROP TABLE "+f
    print query
    db.query(query)
    # this should drop all the tables in the sensordata database
    
datatables=['ehigh','elow','enow','gas']

# now create the datatables
for d in datatables:
    query="CREATE TABLE IF NOT EXISTS "+d
    query+=" (ts timestamp DEFAULT NULL, val NUMERIC(10,4))"
    print query
    db.query(query)

# now create the climate tables
climatetables=['climate']

for c in climatetables:
    query="CREATE TABLE IF NOT EXISTS "+c
    query+=" (ts timestamp DEFAULT NULL, temp NUMERIC(4,1), humidity NUMERIC(4,1), location VARCHAR(16)"
    print query
    db.query(query)
    
db.close()