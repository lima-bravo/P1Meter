# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

# This utility reprocesses the collected data to compensate for missing data when uploading from the raspberry pi

import os, sys
import psycopg2
from psycopg2 import sql

try:
    # db = DB(dbname='sensordata', host='imac.lan', port=5432, user='sensor_main', passwd='SuperSensor')
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(
        host="imac.lan",
        port="5432",
        dbname="sensordata",
        user="sensor_main",
        password="SuperSensor"
    )
    cur = conn.cursor()
except psycopg2.Error as e:
    # Handle specific PostgreSQL errors if needed
    # For now, print a generic error message
    print("Error connecting to the database:", e)
    sys.exit()


DT=0 # timestamp
E1=0 # eLow - nachttarief
E2=0 # eHigh - dagtarief
G1=0 # gas
Add=0
Tot=0


def createDBtables():
    datatables=['ehigh','elow','enow','gas']
    # now create the datatables
    for d in datatables:
        query = sql.SQL("""
        CREATE TABLE IF NOT EXISTS {} (
            ts timestamp PRIMARY KEY UNIQUE, 
            val NUMERIC(10,4)
            )
        """).format(sql.Identifier(d))
        print(query)
        cur.execute(query)


def insertValue(table,ts,val):
    global Add,Tot
    query = sql.SQL("""
               INSERT INTO {} VALUES(to_timestamp(%s),%s)
               ON CONFLICT (ts) DO NOTHING
               """).format(sql.Identifier(table))
    try:
        Tot += 1
        ts_rounded = round(ts, 3)
        cur.execute(query, (ts_rounded, val))
        if cur.rowcount > 0: # something was inserted into the database
            Add+=cur.rowcount
    except psycopg2.Error as e:
        print(query, (ts, val))
        print("Error:", e)


def processFile(filename):
    # initialize the basic values
    global DT
    # start processing the file
    # print(filename, end='')
    f=open(filename,'r') # open the file, read only
    line=f.readline()
    ## now enter the loop
    while line:
        fields=line.strip().split(" ")
        ## now check the values
        if fields[0] == 'DT':
            DT = int(fields[1])
        elif fields[0] == 'T1':
            insertValue('elow', DT, fields[1])
        elif fields[0] == 'T2':
            insertValue('ehigh', DT, fields[1])
        elif fields[0] == 'E1':
            insertValue('enow', DT, fields[1])
        elif fields[0] == 'E2':
            insertValue('enow', DT, "-" + fields[1])
        elif fields[0] == 'G1':
            insertValue('gas', DT, fields[1])
        line=f.readline()
    f.close()
            
            
    
    
## now let's start processing the directory and process all the rec files.
import os
basedir="/zfs/lodewijk/Programming/HomeAutomation/SmartMeter/data/"
fileset = os.listdir(basedir)
sorted_fileset = sorted(fileset)
for f in sorted_fileset:
    if f.startswith("p1"):
        # processRecFile(basedir+f)
        filename=os.path.join(basedir,f)
        Add=0
        Tot=0
        processFile(filename)
        if Add>0:
            print(f"{filename} - Total {Tot} , Added {Add}")
            # conn.commit()  # commit the transaction
            cur.connection.commit()
        # now rename the file so we don't process it again

    

conn.commit()
cur.close()
conn.close()
#
print("Done")
