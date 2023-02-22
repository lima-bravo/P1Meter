# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

# This utility reprocesses the collected data to compensate for missing data when uploading from the raspberry pi


from pg import DB
db = DB(dbname='sensordata', host='imac.lan', port=5432, user='sensor_main', passwd='SuperSensor')


DT=0 # timestamp
E1=0 # eLow - nachttarief
E2=0 # eHigh - dagtarief
G1=0 # gas
Exc=0
Tot=0


def createDBtables():
    datatables=['ehigh','elow','enow','gas']
    # now create the datatables
    for d in datatables:
        # drop table for now
        #query="DROP TABLE %s" % (d)
        #db.query(query)
        #
        query="CREATE TABLE IF NOT EXISTS "+d
        query+=" (ts timestamp PRIMARY KEY UNIQUE, val NUMERIC(10,4))"
        print query
        db.query(query)
        # now create the index -- not needed, primary key added
        # query="CREATE INDEX IF NOT EXISTS %s_idx_ts ON %s (ts)" % (d,d)
        # print query
        # db.query(query)


def insertValue(table,ts,val):
    global Exc,Tot
    sql="INSERT INTO %s VALUES(to_timestamp(%i),%s)" % (table,ts,val)
    # print sql
    try:
        Tot+=1
        db.query(sql)
    except Exception:
        # print "\tConstraints violation on "+sql
        Exc+=1
        pass

def processFile(filename):
    # initialize the basic values
    global DT
    # start processing the file
    print filename
    f=open(filename,'r') # open the file, read only
    line=f.readline()
    ## now enter the loop
    while line:
        fields=line.strip().split(" ")
        ## now check the values
        if fields[0]=='DT':
            DT=int(fields[1])
        elif fields[0]=='T1':
            insertValue('elow',DT,fields[1])
        elif fields[0]=='T2':
            insertValue('ehigh',DT,fields[1])
        elif fields[0]=='E1':
            insertValue('enow',DT,fields[1])
        elif fields[0]=='G1':
            insertValue('gas',DT,fields[1])
        line=f.readline()
    f.close()
            
            
    
    
## now let's start processing the directory and process all the rec files.
import os
basedir="/Users/lodewijk/Programming/SmartMeter/data/"
for f in os.listdir(basedir):
    if f.startswith("p1"):
        # processRecFile(basedir+f)
        filename=os.path.join(basedir,f)
        Exc=0
        Tot=0
        print ("Processing "),
        processFile(filename)
        print ("Total %d, Exceptions %d\n") % (Tot,Exc)
        # now rename the file so we don't process it again
    
            

    
db.close()
print "Done"
