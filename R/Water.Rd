# check water data for double counting, or other influences


require("RPostgreSQL")

# load the PostgreSQL driver
if (!exists("drv")) {
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sensordata", host='localhost', port=5432, user='sensor_main', password='SuperSensor')
}

#

if (FALSE) {
	# select throughput as function of time unit
	#
	delta <- 10
	# create a complex query to get the amount of water consumed per unit of time
	sql <- sprintf("
	SELECT date_trunc('hour',ts) as ts, dval AS val FROM (
		SELECT ts,
		(lead(val,%s) OVER (ORDER BY ts)) - (lag(val,%s) OVER (ORDER BY ts)) AS dval 
		FROM water 
		WHERE ts>'2022-04-03'
		ORDER BY ts 
	) AS deltaw GROUP BY date_trunc('day',ts)  ORDER BY ts
	",delta,delta)
flow <- dbGetQuery(con,sql)
plot(flow,type='l',col='red',pch=20,  main='Max Flow', ylab="debiet",xlab="Datum")
	
}

if (TRUE) {
	# create new query and look across the flow by selecting the max values over a time period 
	sql <- "
		SELECT tg, (val-lag(val,1) OVER( ORDER BY tg)) AS dval FROM ( 
		SELECT date_trunc('minute',ts) AS tg,max(val)  AS val 
		FROM water
		WHERE ts > '2022-09-25' AND ts <'2022-10-30'
		GROUP BY tg 
		ORDER BY tg DESC
		) AS deltaV ORDER BY tg
	"
	flow <- dbGetQuery(con,sql)
plot(flow,type='l',col='green',pch=20,  main='Max Flow', ylab="Capaciteit m3/h",xlab="Datum", xaxt = "n")
# axis(1, flow$ts_time, format(flow$ts_time, "%y%m%d@%H"), cex.axis = .7)

	
}

if (FALSE) {
	# select data to display a maximum throughput
	#
# define the interval of ticks across which we are calculating the flow
lead <-12
lag <- lead

# a more complex query to get the max of each day
sql <- sprintf("
	select date_trunc('day',ts) as ts_time, max(flow) as max_flow FROM (
	select ts, tlead-tlag AS dt, vlead-vlag AS dv, (vlead-vlag)/(tlead-tlag)*3600 AS flow FROM (
		select ts, 
			EXTRACT(epoch FROM (lead(ts,%s) OVER (order by ts))) AS tlead, 
			EXTRACT(epoch FROM (lag(ts,%s) OVER ( order by ts))) AS tlag, 
			lead(val, %s) OVER (order by ts) AS vlead, 
			lag(val,%s) OVER (order by ts) as vlag 
		FROM water 
		WHERE ts> '2022-04-04' AND ts <'2022-06-23'
	) AS deltaw ORDER BY ts 
	)
	AS dflow GROUP BY ts_time ORDER BY ts_time
	", lead,lag,lead,lag)

flow <- dbGetQuery(con,sql)
plot(flow,type='l',col='green',pch=20, ylim=c(0,3.5), main='Max Flow', ylab="Capaciteit m3/h",xlab="Datum", xaxt = "n")
axis(1, flow$ts_time, format(flow$ts_time, "%y%m%d@%H"), cex.axis = .7)
}

if (FALSE) {
# now let's create a complex query to determine the consumption per unit of time
sql <- sprintf("
select date_trunc('hour',ts) AS td, max(val) AS mv FROM water WHERE ts>'2022-04-03' GROUP BY td ORDER BY td ASC 
")

val <- dbGetQuery(con,sql)
plot(val,type='l',col='red',pch=20, xlab="Datum", xaxt = "n")
axis(1, flow$ts_time, format(flow$ts_time, "%y%m%d@%H"), cex.axis = .7)
}

if(FALSE) {
# investigate the max elapsed time
sql <- sprintf("
select ts, EXTRACT(epoch FROM (ts - (lag(ts,1) OVER (order by ts)))) AS dt FROM water WHERE ts>'2022-06-13' ORDER BY ts ASC
")

val <- dbGetQuery(con,sql)
plot(val,type='l',col='blue',pch=20, xlab="Datum", xaxt = "n")
axis(1, flow$ts_time, format(flow$ts_time, "%y%m%d@%H"), cex.axis = .7)
}
# The idea is to combine multiple observations, across a set of values
step <- 15
# 
# nr <- nrow(enow)
# dt <- as.integer(enow[c((step+1):nr),1]-enow[c(1:(nr-step)),1])
# dw <- enow[c((step+1):nr),2]-enow[c(1:(nr-step)),2]
# tt <- enow[c(floor(step/2+1):floor(nr-step/2)),1]


# nr <- nrow(enow)
# dt <- as.integer(enow[c(2:nr),1]-enow[c(1:(nr-1)),1])
# dw <- enow[c(2:nr),2]-enow[c(1:(nr-1)),2]

# ct <- enow[c(2:nr),1]

# df <- data.frame(tt,dw/dt)

# plot(df, type='l',ylim=c(0,max(df[,2])))