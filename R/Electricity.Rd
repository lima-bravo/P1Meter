# 
# Electricity consumption
#
# Calculate peak power consumption based on the meter.
#

#
require("RPostgreSQL")


# load the PostgreSQL driver
if (!exists("drv")) {
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sensordata", host='localhost', port=5432, user='sensor_main', password='SuperSensor')
}


if(TRUE) {
	#
	# first start with analyzing gaps between consecutive data entries.
	#
	# Use advanced query skills
	sql <- "
	SELECT ts, t1-ts AS dt FROM (
		SELECT ts, lead(ts,1) OVER (ORDER BY ts) AS t1 FROM  ehigh WHERE ts> '2021-04-03'
	) AS deltat ORDER BY ts
	"
	
	flow <- dbGetQuery(con,sql)
	plot(flow,type='l',col='red',pch=20,  main='ts', ylab="diff",xlab="Datum")


}