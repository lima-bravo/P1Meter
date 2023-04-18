# collect and plot data from the Gas meter

require("RPostgreSQL")

# load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sensordata", host='localhost', port=5432, user='sensor_main', password='SuperSensor')

sql <- "SELECT * FROM elow"
dlow <- dbGetQuery(con,sql)

sql <- "SELECT * FROM ehigh"
dhigh <- dbGetQuery(con,sql)


plot(dlow, type='p',col="blue",pch=20)
points(dhigh,col="red",pch="+")



sql <- "SELECT * FROM enow ORDER BY ts DESC LIMIT 3000"
enow <- dbGetQuery(con,sql)

plot(enow,type='l',col='green',pch=20)

sql <- "SELECT * FROM water ORDER BY ts DESC LIMIT 3000 "
enow <- dbGetQuery(con,sql)
plot(enow,type='l',col='green',pch=20)



sql <- "SELECT date(ts) as dts, avg(val) as val, min(val) as min, max(val) as max FROM enow GROUP BY date(ts) ORDER BY dts DESC  "
enow <- dbGetQuery(con,sql)



plot(enow$dts, enow$max,type='l',col='red',pch=20, ylim=c(0,max(enow$max)))
lines(enow$dts,enow$val,col='blue',pch=20)
lines(enow$dts,enow$min,col='green',pch=20)


sql <- "SELECT date(ts) as dts, (max(val)-min(val)) as val FROM water WHERE date(ts)>'2017-12-03' GROUP BY date(ts) ORDER BY dts "
enow <- dbGetQuery(con,sql)
plot(enow,type='l',col='green',pch=20)


sql <- "SELECT date(ts) as dts, (max(val)-min(val)) as val FROM ehigh WHERE date(ts)> '2016-10-31' GROUP BY date(ts) ORDER BY dts"
enow <- dbGetQuery(con,sql)

sql <- "SELECT date(ts) as dts, (max(val)-min(val)) as val FROM elow WHERE date(ts)> '2016-10-31' GROUP BY date(ts) ORDER BY dts"
elow <- dbGetQuery(con,sql)


plot(enow,type='l',col='green',pch=20)
lines(elow,col='blue', pch=20)


sql <- "SELECT date(ts) as dts, (max(val)-min(val)) as val FROM gas WHERE date(ts)> '2018-01-01' GROUP BY date(ts) ORDER BY dts"
gas <- dbGetQuery(con,sql)
plot(gas,type='l',col='green',pch=20)

sql <- "SELECT date_trunc('hour',ts) as dts, (max(val)-min(val)) as val FROM gas WHERE date(ts)> '2018-01-01' GROUP BY date_trunc('hour',ts) ORDER BY dts"
gas <- dbGetQuery(con,sql)
plot(gas,type='l',col='green',pch=20)



sql <- "SELECT * FROM gas WHERE date(ts)> '2016-10-31' ORDER BY ts"
gas <- dbGetQuery(con,sql)
plot(gas,type='l',col='green',pch=20)


sql <- "SELECT * FROM gas WHERE date(ts)> '2017-12-31' ORDER BY ts"
gas <- dbGetQuery(con,sql)
plot(gas,type='l',col='green',pch=20)




sql <- "SELECT date(ts) as dts, max(temperature) FROM netatmoTHC WHERE station=1 GROUP BY date(ts) ORDER BY dts"
celsius <- dbGetQuery(con,sql)
plot(celsius, type='l',col='green',pch=20)

sql <- "SELECT date(ts) as dts, avg(temperature) FROM netatmoTHC WHERE station=5 GROUP BY date(ts) ORDER BY dts"
celsius <- dbGetQuery(con,sql)
plot(celsius, type='l',col='green',pch=20)


sql <- "SELECT date(ts) as dts, avg(pressure) FROM netatmoPN WHERE station=2 GROUP BY date(ts) ORDER BY dts"
pressure <- dbGetQuery(con,sql)
plot(pressure, type='l',col='green',pch=20)



sql <- "SELECT min(date(ts)),max(date(ts)) FROM netatmoTHC WHERE station=5"
thc <- dbGetQuery(con,sql)

sql <- "SELECT min(date(ts)),max(date(ts)) FROM climate WHERE location='CellarLogger'"
clm <- dbGetQuery(con,sql)

mind <- max(thc['min'],clm['min'])
maxd <- min(thc['max'],clm['max'])



sql <- "SELECT date(ts) as dts, avg(temperature) FROM netatmoTHC WHERE station=5 AND date(ts)>'2015-12-05' AND date(ts)<'2017-03-09' GROUP BY date(ts) ORDER BY dts"
thc <- dbGetQuery(con,sql)

sql <- "SELECT date(ts) as dts, avg(temp) FROM climate WHERE location='GarageLogger' AND date(ts)>'2015-12-05' AND date(ts)<'2017-03-09' GROUP BY date(ts) ORDER BY dts"
clm <- dbGetQuery(con,sql)



# I suspect that there is some double counting going on. How to determine this?  Look at the miinimum time between cycles 

sql <- "SELECT * FROM water ORDER BY ts DESC LIMIT 7000 "
enow <- dbGetQuery(con,sql)
plot(enow,type='l',col='green',pch=20)


sql <- "SELECT date_trunc('hour',ts) as ts_hour, max(val)-min(val) as wat FROM water WHERE date(ts) > '2018-01-12' GROUP BY date_trunc('hour',ts) ORDER BY ts_hour"
enow <- dbGetQuery(con,sql)
plot(enow,type='l',col='green',pch=20)