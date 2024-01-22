#!/usr/bin/python3

import os, serial, time

#s = serial.Serial('/dev/ttyUSB0', baudrate=115200, bytesize=7, parity='E', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
# update voor Vondellaan 19
#s = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=7, parity='E', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
s = serial.Serial('/dev/ttyUSB0', baudrate=115200, bytesize=serial.SEVENBITS, parity=serial.PARITY_EVEN, stopbits=1, timeout=20, xonxoff=0, rtscts=0)
while True:
    line = s.readline()
    if "clear\n" == line:
        os.system('clear')
    else:
        print line
