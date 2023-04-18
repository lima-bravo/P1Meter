# Provide a graph for electricity use on an immediate basis
#
require("RPostgreSQL")

# load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sensordata", host='localhost', port=5432, user='sensor_main', password='SuperSensor')


sql <- "SELECT * FROM enow ORDER BY ts DESC LIMIT 10000"
sql <- "SELECT * FROM enow WHERE ts> '2022-01-01 00:00:00' ORDER BY ts "
sql <- "SELECT * FROM enow WHERE val>15 ORDER BY ts "
#sql <- "SELECT  DATE(ts) as dt  FROM enow WHERE val>14 GROUP BY dt ORDER BY dt"
#sql <- "SELECT  DATE(ts) as dt, max(val)  FROM enow WHERE val>14 GROUP BY dt ORDER BY dt"


dbf <- dbGetQuery(con,sql)

# plot(dbf, col="red",pch=20)

minE <- min(dbf[,"val"])
maxE <- max(dbf[,"val"])

deltaE <- maxE - minE

breakCount <- ceiling(deltaE*10)

# now create the histogram,

H <- hist(dbf[,"val"], freq=TRUE, breaks=breakCount, ylim=c(0,100))

cat(sprintf("Min %f, Max %f, breaks %d\n",minE,maxE, breakCount))


val <- which(dbf[,"val"]>14)
dbf[val,]

rm(con)