# 
# Vondellaan.RD
#
# Create a comprehensive overview of Water and Electricity consumption of a past period of days and/or hours.
#
#
# NOTES
#
# P1 format reports kW and kWh for the electricity - divide by 230V to get Ampere.
#
require("RPostgreSQL")
require("ggplot2")

# load the PostgreSQL driver
if (!exists("drv")) {
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sensordata", host='localhost', port=5432, user='sensor_main', password='SuperSensor')
}

##
# Database connectivity has now been determined.
#
#

buildQuery <- function(date,table, unit='day', limit=-1) {
	
	sql <- sprintf("
	 	SELECT date_trunc('%s',ts) as ts_time, max(val) as maxval, min(val) as minval 
	 	FROM %s 
	 	WHERE date(ts) > '%s' 
	 	GROUP BY date_trunc('%s',ts) 
	 	ORDER BY ts_time
	 	",unit,table,date,unit)	# cat(sql)
	
	if (limit>10) {
		sql <- sprintf("%s LIMIT %d",sql,limit)
	}
	
	dbf <- dbGetQuery(con,sql)
	
	return(dbf)
	}
	
	
processFlowData <- function(dbf,table) {
	names(dbf) <- c('ts_time',sprintf("max_%s",table),sprintf("min_%s",table))
	
	return(dbf)
}

processMeterData <- function(dbf,table) {
	# define the ranges to use
	nr <- nrow(dbf)
	br <- c(1:(nr-1)) # begin range - starts at 1
	er <- c(2:nr) # end range - starts at 2
	
	# determine the delta
	dx <- dbf[er,2]-dbf[br,2]
	# determine the elapsed time
	dt <- as.numeric(difftime(dbf[er,1],dbf[br,1]),unit="secs")
	# determine the velocity
	vx <- 1000*dx/dt # transform the scale of the metric
	# determine the median timestamp
	ts <- dbf[br,1]+floor((dbf[er,1]-dbf[br,1])/2)
	
	
	df <- data.frame(ts=ts,dx=dx,vx=vx)
	
	names(df) <- c('ts_time',table,sprintf("v_%s",table))
	
	return(df)
}



buildNestedQuery<- function(date,table, unit='day', limit=-1) {
	
	sql <- sprintf("
		SELECT 
			tg AS ts_time, 
			(val-lag(val,1) OVER( ORDER BY tg)) AS dval,
			(tg-lag(tg,1) OVER ( ORDER BY tg)) AS dt			 
		FROM ( 
		SELECT date_trunc('%s',ts) AS tg, max(val)  AS val 
		FROM %s
		WHERE date(ts) > '%s'
		GROUP BY tg 
		ORDER BY tg DESC
		) AS deltaV ORDER BY tg
	",unit,table,date)

	# cat(sql)
	if (limit>10) {
		sql <- sprintf("%s LIMIT %d",sql,limit)
	}
	
	dbf <- dbGetQuery(con,sql)
	
	if (nrow(dbf)<1) {
		echo("ERROR - dataframe does not contain data - no data present for requested time period")
	}
	
	return(dbf)
	}

processNestedMeterData <- function(dbf,table) {
	# define the ranges to use
	# print(dbf)
	nr <- nrow(dbf)
	br <- c(1:(nr-1)) # begin range - starts at 1
	er <- c(2:nr) # end range - starts at 2
	
	# determine the delta
	dx <- dbf[er,2]-dbf[br,2]
	# determine the elapsed time
	dt <- as.numeric(difftime(dbf[er,1],dbf[br,1]),unit="secs")
	# determine the velocity
	vx <- 1000*dx/dt # transform the scale of the metric
	# determine the median timestamp
	ts <- dbf[er,1]
	dx <- dbf[er,2]
	vx <- dbf[er,2]/as.numeric(as.difftime(dbf[er,3],units="secs"))
	
	df <- data.frame(ts=ts,dx=dx,vx=vx)
	
	names(df) <- c('ts_time',table,sprintf("v_%s",table))
	
	return(df)
}


addVelocityColumn <- function(dbf) {
	nr <- nrow(dbf)
	br <- c(1:(nr-1)) # begin range - starts at 1
	er <- c(2:nr) # end range - starts at 2

	dt <- as.numeric(difftime(dbf[br,1],dbf[er,1]),units="secs")
	dx <- dbf[er,2]-dbf[br,2]
	
	vx <- 3600000/230*dx/dt # go from kWh to Ampere
	
	df <- data.frame(ts=dbf[,1],dx=dbf[,2],vx=vx)

}


# 1 : minute 2: hour, 3: day, 4: week, 5: month, 6: quarter, 7: year
unitset <-c('minute','hour','day','week','month','quarter','year')


unit <- unitset[7]


targetDate <- Sys.Date()

switch(unit,
		'minute' = targetDate <- targetDate - 4,
		'hour' = targetDate <- targetDate - 5,
		'day' = targetDate <- targetDate - 90,
		'week' = targetDate <- '2021-04-01',
		'month' = targetDate <- '2021-04-01',
		'year' = targetDate <- '2021-04-01',
		targetDate <- '2021-04-01'
		)



cat(sprintf("Measuring by unit of %s, starting %s\n",unit, targetDate))

dbwater <- buildNestedQuery(targetDate,'water',unit=unit)
water <- processNestedMeterData(dbwater,'water')
ehigh <- processNestedMeterData(buildNestedQuery(targetDate,'ehigh',unit=unit),'ehigh')
elow <- processNestedMeterData(buildNestedQuery(targetDate,'elow',unit=unit),'elow')
# enow <- processFlowData(buildQuery(targetDate,'enow',unit=unit),'enow')


dataE <- merge(ehigh,elow, by='ts_time',all=TRUE)
elec <- transform(dataE[,1], elec = rowSums(dataE[,c(2,4)],na.rm=TRUE), ampere = rowSums(3600/230*dataE[,c(3,5)],na.rm=TRUE))

colnames(elec) <- c("ts_time","elec","ampere")

maxwater <- max(water$water,na.rm=TRUE)
maxvwater <- max(water$v_water,na.rm=TRUE)
maxelec <- max(elec$elec,na.rm=TRUE)
maxvelec <- max(elec$ampere,na.rm=TRUE)
# maxenow <- max(enow$enow, na.rm=TRUE)


scalef <- 1.2

total <- merge(water, elec, by='ts_time',all=TRUE)

cat(sprintf("Data collected, last time unit %s",max(total[,"ts_time"])))

old.par <- par(mfrow=c(3,1))

barplot(total$water,col='blue',border=NA,pch=20, ylim=c(0,scalef*maxwater),main="water")
#barplot(total$v_water,col='blue',border=NA,pch=20, ylim=c(0,scalef*maxvwater),main="water")

bars=barplot(total$elec,col='red',pch=20, border=NA, ylim=c(0,scalef*maxelec), main="Elec", xlab="Time")
barplot(total$ampere,col='red',pch=20, border=NA, ylim=c(0,scalef*maxvelec), main="Ampere", xlab="Time")

#barplot(enow$enow,col='orange',pch=20, border=NA, ylim=c(0,scalef*maxenow), main="Max(elec)", xlab="Time")
#
# now make min/max plot for the electricity range
#ggplot(enow) + 
#	geom_segment(aes(x=ts_time, xend=ts_time, y=min_enow, yend=max_enow), size=2, color='orange') +
#	theme_bw() +
#	theme(axis.text.x=element_text(angle=90))
	
# remove the dbConnection
# rm(con)
