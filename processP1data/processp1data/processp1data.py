# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

from pg import DB

try:
	db = DB(dbname='sensordata', host='imac.lan', port=5432, user='sensor_main', passwd='SuperSensor')
except Exception:
	import sys
	print( "Error accessing database")
	sys.exit(1)



DT=0 # timestamp
E1=0 # current draw
E2=0 # current production
G1=0 # gas


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
        print( query)
        db.query(query)
        # now create the index -- not needed, primary key added
        # query="CREATE INDEX IF NOT EXISTS %s_idx_ts ON %s (ts)" % (d,d)
        # print query
        # db.query(query)


def insertValue(table,ts,val):
    sql="INSERT INTO %s VALUES(to_timestamp(%i),%s)" % (table,ts,val)
    # print sql
    try:
        db.query(sql)
    except Exception:
        # print "Constraints violation on "+sql
        pass

def processFile(filename):
    # initialize the basic values
    global DT
    # start processing the file
    print(filename)
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
        elif fields[0]=='E2':
            insertValue('enow',DT,"-"+fields[1]) 
        elif fields[0]=='G1':
            insertValue('gas',DT,fields[1])
        line=f.readline()
    f.close()
            
            
    
    
## now let's start processing the directory and process all the rec files.
import os
basedir="/home/pi/Programming/SmartMeter/data/"
for f in os.listdir(basedir):
    if f.startswith("p1data."):
        # processRecFile(basedir+f)
        filename=os.path.join(basedir,f)
        newfile=filename.replace("p1data","p1proc")
        # check if the newfile exists, if so, skip
        if os.path.isfile(newfile):
            print( "Skipping "+filename+", already processed")
        else:
            # check if the filesize is greater than 100 bytes
            if os.path.getsize(filename)>100:
                processFile(filename)
                # now rename the file so we don't process it again
                print(filename,newfile)
                os.rename(filename,newfile)
            else:
                print("File too small : skipping "+filename) 
            

    
db.close()
print("Done")

