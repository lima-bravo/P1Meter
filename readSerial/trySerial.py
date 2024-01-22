#!/usr/bin/python3

import os, serial, time
from serial.serialutil import SerialException

def tryRead(baudrate, bytesize, parity, stopbits):
	device = serial.Serial('/dev/ttyUSB0', baudrate=baudrate, bytesize=bytesize, parity=parity, stopbits=stopbits, timeout=4, xonxoff=0, rtscts=0)	
	count=10
	while count>0:
		try:
			line = device.readline()
			print count, line
		except SerialException as e:
			print "Error"
			parser.error(e)
		
		count-=1
	# close the device
	device.close()


#s = serial.Serial('/dev/ttyUSB0', baudrate=115200, bytesize=7, parity='E', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
# update voor Vondellaan 19
#s = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=7, parity='E', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
#s = serial.Serial('/dev/ttyUSB0', baudrate=115200, bytesize=serial.SEVENBITS, parity=serial.PARITY_EVEN, stopbits=1, timeout=2, xonxoff=0, rtscts=0)
tryRead(115200, serial.EIGHTBITS, serial.PARITY_NONE,1)
print "next"
tryRead(115200, serial.EIGHTBITS, serial.PARITY_EVEN,1)
print "next"
#tryRead(9600, serial.SEVENBITS, serial.PARITY_EVEN,1)
#print "next"
#tryRead(9600, serial.EIGHTBITS, serial.PARITY_EVEN,1)
#print "next"


