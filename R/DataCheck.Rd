# Provide a quick check on the most recent data collected
# Present Electricity, Gas and Water data in a single graph
#
#

require("RPostgreSQL")

# load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sensordata", host='localhost', port=5432, user='sensor_main', password='SuperSensor')



buildQuery <- function(date,table, unit='day') {
	#sql <- sprintf("SELECT date_trunc('hour',ts) as ts_hour, max(val) as val FROM %s WHERE date(ts) > '%s' GROUP BY date_trunc('hour',ts) ORDER BY ts_hour",table,date)
	#sql <- sprintf("SELECT date_trunc('day',ts) as ts_hour, max(val) as val FROM %s WHERE date(ts) > '%s' GROUP BY date_trunc('day',ts) ORDER BY ts_hour",table,date)	
	#sql <- sprintf("SELECT date_trunc('week',ts) as ts_hour, max(val) as val FROM %s WHERE date(ts) > '%s' GROUP BY date_trunc('week',ts) ORDER BY ts_hour",table,date)
	#sql <- sprintf("SELECT date_trunc('month',ts) as ts_hour, max(val) as val FROM %s WHERE date(ts) > '%s' GROUP BY date_trunc('month',ts) ORDER BY ts_hour",table,date)
	sql <- sprintf("SELECT date_trunc('%s',ts) as ts_hour, max(val) as val FROM %s WHERE date(ts) > '%s' GROUP BY date_trunc('%s',ts) ORDER BY ts_hour",unit,table,date,unit)
	
	cat(sql)
	
	dbf <- dbGetQuery(con,sql)
	
	
	
	nr <- nrow(dbf)
	dt <- dbf[c(2:nr),2]-dbf[c(1:(nr-1)),2]
	ts <- dbf[c(2:nr),1]
	
	
	df <- data.frame(ts=ts,dt=dt)
	
	names(df) <- c('ts_hour',table)
	
	return(df)
}

targetDate <- '2009-11-01'
targetDate <- '2019-10-01'
targetDate <- '2020-10-01'


# hour, day, week, month, quarter, year
unit <- 'week'
# unit <- 'day'
# unit <- 'month'
# unit <- 'year'
unit <- 'hour' # does not work anymore


switch(unit,
		'hour' = targetDate <- '2021-03-01',
		'day' = targetDate <- '2020-10-01',
		'week' = targetDate <- '2020-01-01',
		'month' = targetDate <- '2016-01-01',
		'year' = targetDate <- '2009-11-01',
		targetDate <- '2019-01-01'
		)



cat(sprintf("Measuring by unit of %s, starting %s\n",unit, targetDate))

water <- buildQuery(targetDate,'water',unit=unit)
ehigh <- buildQuery(targetDate,'ehigh',unit=unit)
elow <- buildQuery(targetDate,'elow',unit=unit)
gas <- buildQuery(targetDate,'gas',unit=unit)

dataE <- merge(ehigh,elow, by='ts_hour',all=TRUE)
elec <- transform(dataE[,1], elec = rowSums(dataE[,2:3],na.rm=TRUE))
colnames(elec) <- c("ts_hour","elec")

maxwater <- 3*median(water$water,na.rm=TRUE)
# maxgas <- 4*median(gas$gas,na.rm=TRUE)
maxgas <- 1.2*sort(gas$gas,TRUE)[3]
maxelec <- 3*median(elec$elec,na.rm=TRUE)


total <- merge(water, elec, by='ts_hour',all=TRUE)
## total <- merge(total, elow, by='ts_hour', all=TRUE)
total <- merge(total, gas, by='ts_hour', all=TRUE)

cat(sprintf("Data collected, last time unit %s",max(total[,"ts_hour"])))

old.par <- par(mfrow=c(3,1))

barplot(total$water,col='blue',border=NA,pch=20, ylim=c(0,maxwater),main="water")
barplot(total$elec,col='red',pch=20, border=NA, ylim=c(0,maxelec), main="elec")
## barplot(total$elow,col='green',pch=20, main="elow")
barplot(total$gas,col='brown',pch=20, border=NA, ylim=c(0,maxgas),main="gas")


