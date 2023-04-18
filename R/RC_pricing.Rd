#
# investigate pricing model for Reynen Court, based on exponential functions.
#
# Simple approach:

basePrice <- 100
decayRate <- 0.99

price <- function(x) {
	return(basePrice*decayRate^x)
}

N <- 4000
Sum <- c()
Price <- c()
dPrice <- c()

oP <- price(0)
dP <-basePrice
sum <- 0
for(i in c(0:N)) {
	p <- price(i)
	sum <- sum + p
	dP <- p-oP
	oP <- p
	#
	Sum <- c(Sum,sum)
	Price <- c(Price,p)
	dPrice <- c(dPrice,dP)
}


par(mfrow=c(1,3))
x <-c(0:N)
plot(x,Sum)
plot(x,Price)
plot(x,dPrice)
