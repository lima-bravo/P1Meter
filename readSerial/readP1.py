#!/usr/bin/python
#
# Most of this file copied from https://github.com/gejanssen/slimmemeter-rpi/
#
# DSMR P1 uitlezen
# (c) 10-2012 - GJ - gratis te kopieren en te plakken
__version__ = "1.0"
import sys
import serial
import logging
import time
from datetime import datetime
import re


###########
# Copy the code from smeterd
# and update where necessary
###########

log = logging.getLogger(__name__)


class SmartMeter(object):

    def __init__(self, *args, **kwargs):
        try:
            #Set COM port config
#            self.serial = serial.Serial()
#            self.serial.baudrate = 115200 #9600
#            self.serial.bytesize=serial.SEVENBITS
#            self.serial.parity=serial.PARITY_EVEN
#            self.serial.stopbits=serial.STOPBITS_ONE
#            self.serial.xonxoff=0
#            self.serial.rtscts=0
#            self.serial.timeout=20
#            self.serial.port="/dev/ttyUSB0"
            self.serial=serial.Serial('/dev/ttyUSB0', baudrate=115200, bytesize=7, parity='E', stopbits=1, timeout=None, xonxoff=0, rtscts=0)

        except (serial.SerialException,OSError) as e:
            raise SmartMeterError(e)
        else:
            #self.serial.setRTS(False)
            self.port = self.serial.name

        log.info('New serial connection opened to %s', self.port)


    def connect(self):
        if not self.serial.isOpen():
            log.info('Opening connection to `%s`', self.serial.name)
            self.serial.open()
            #self.serial.setRTS(False)
        else:
            log.debug('`%s` was already open.', self.serial.name)


    def disconnect(self):
        if self.serial.isOpen():
            log.info('Closing connection to `%s`.', self.serial.name)
            self.serial.close()
        else:
            log.debug('`%s` was already closed.', self.serial.name)


    def connected(self):
        return self.serial.isOpen()


    def read_one_packet(self):
        lines = []
        lines_read = 0
        complete_packet = False
        max_lines = 35 #largest known telegram has 35 lines

        log.info('Start reading lines')

        while not complete_packet:
            # print "*",
            # sys.stdout.flush()
            line = ''
            try:
                line = self.serial.readline().strip()
                if not isinstance(line, str):
                    line = line.decode('utf-8')
            except Exception as e:
                log.error(e)
                log.error('Read a total of %d lines', lines_read)
                raise SmartMeterError(e)
            else:
                lines_read += 1
                # print lines_read,
                # sys.stdout.flush()
                if line.startswith('/ISk5'):
                    if line.endswith('1003'):
                        max_lines = 13
                    if line.endswith('1004'):
                        max_lines = 19
                    lines = [line]
                elif line.startswith('/KFM5'):
                    max_lines = 25
                    lines = [line]
                else:
                    lines.append(line)
                if line.startswith('!') and len(lines) > max_lines:
                    complete_packet = True
                    # print "!",
                    # sys.stdout.flush()

                if len(lines) > max_lines * 2 + 2:
                    raise SmartMeterError('Received %d lines, we seem to be stuck in a loop, quitting.' % len(lines))
            finally:
                log.debug('>> %s', line)

        log.info('Done reading one packet (containing %d lines)' % len(lines))
        log.debug('Total lines read from serial port: %d', lines_read)
        log.debug('Constructing P1Packet from raw data')

        return P1Packet('\n'.join(lines))



class SmartMeterError(Exception):
    pass



class P1Packet(object):


    _raw = ''

    def __init__(self, data):
        if type(data) == list:
            self._raw = '\n'.join(data)
        else:
            self._raw = data

        keys = {}
        keys['header'] = self.get(r'^(/.*)$', '')

        keys['kwh'] = {}
        keys['kwh']['eid'] = self.get(r'^0-0:96\.1\.1\(([^)]+)\)$')
        keys['kwh']['tariff'] = self.get_int(r'^0-0:96\.14\.0\(([0-9]+)\)$')
        keys['kwh']['switch'] = self.get_int(r'^0-0:96\.3\.10\((\d)\)$')
        keys['kwh']['treshold'] = self.get_float(r'^0-0:17\.0\.0\(([0-9]{4}\.[0-9]{2})\*kW\)$')

        keys['kwh']['low'] = {}
        keys['kwh']['low']['consumed'] = self.get_float(r'^1-0:1\.8\.1\(([0-9]+\.[0-9]+)\*kWh\)$')
        keys['kwh']['low']['produced'] = self.get_float(r'^1-0:2\.8\.1\(([0-9]+\.[0-9]+)\*kWh\)$')

        keys['kwh']['high'] = {}
        keys['kwh']['high']['consumed'] = self.get_float(r'^1-0:1\.8\.2\(([0-9]+\.[0-9]+)\*kWh\)$')
        keys['kwh']['high']['produced'] = self.get_float(r'^1-0:2\.8\.2\(([0-9]+\.[0-9]+)\*kWh\)$')

        keys['kwh']['current_consumed'] = self.get_float(r'^1-0:1\.7\.0\(([0-9]+\.[0-9]+)\*kW\)$')
        keys['kwh']['current_produced'] = self.get_float(r'^1-0:2\.7\.0\(([0-9]+\.[0-9]+)\*kW\)$')

        keys['gas'] = {}
        keys['gas']['eid'] = self.get(r'^0-1:96\.1\.0\(([^)]+)\)$')
        keys['gas']['device_type'] = self.get_int(r'^0-1:24\.1\.0\((\d)+\)$')
	# the W and S represent time in summer or winter time.
        keys['gas']['total'] = self.get_float(r'^(?:0-1:24\.2\.1(?:\(\d+[SW]\))?)?\(([0-9]{5}\.[0-9]{3})(?:\*m3)?\)$', 0)
        keys['gas']['valve'] = self.get_int(r'^0-1:24\.4\.0\((\d)\)$')

        keys['msg'] = {}
        keys['msg']['code'] = self.get(r'^0-0:96\.13\.1\((\d+)\)$')
        keys['msg']['text'] = self.get(r'^0-0:96\.13\.0\((.+)\)$')

        self._keys = keys

    def __getitem__(self, key):
        return self._keys[key]

    def get_float(self, regex, default=None):
        result = self.get(regex, None)
        if not result:
            return default
        return float(self.get(regex, default))

    def get_int(self, regex, default=None):
        result = self.get(regex, None)
        if not result:
            return default
        return int(result)

    def get(self, regex, default=None):
        results = re.search(regex, self._raw, re.MULTILINE)
        if not results:
            return default
        return results.group(1)

    def __str__(self):
        return self._raw



def printIfChanged(name,var1,var2,file):
    if var1!=var2:
        print '{} {}'.format(name, var1)
        file.write('{} {}\n'.format(name, var1))

    return var1

##############################################################################
#Main program
##############################################################################
# print ("DSMR P1 uitlezen",  versie)
# print ("Control-C om te stoppen")
# print ("Pas eventueel de waarde ser.port aan in het python script")

from serial.serialutil import SerialException
import os
# use debug level DEBUG to get output, comment out the line to prevent loggging
#logging.basicConfig(filename='readP1.log', level=logging.DEBUG)

meter=SmartMeter()
meter.connect()

#Initialize
T1=0; dT1=0 # total electricity consumed Tarif 1
T2=0; dT2=0 # total electricity consumed Tarif 2
P1=0; dP1=0 # total electricity produced Tarif 1
P2=0; dP2=0 # total electricity produced Tarif 2
E1=0; dE1=0 # current electricity consumption
E2=0; dE2=0 # current electricicty production
G1=0; dG1=0 # total gas consumed
#
measure=True
while measure:
    # run endless loop
    # create new file for saving the data,
    filename="p1data."+str(int(time.time()))
    #
    # now open the file ready for writing
    f = open(filename,'w',0)  # open unbuffered
    # the file is now open.
    #
    # reset the standard values and their history values
    dG1=0
    # Start reading the port for 1000 times
    file_counter=1000
    while file_counter>0:
        # now start reading the data from the port
        try:
            packet = meter.read_one_packet()
        except SerialException as e:
            parser.error(e)
            measure=False
            meter.disconnect()


        ## now print changing data
        T1=packet['kwh']['high']['consumed']
        T2=packet['kwh']['low']['consumed']
	P1=packet['kwh']['high']['produced']
        P2=packet['kwh']['low']['produced']
        E1=packet['kwh']['current_consumed']
	E2=packet['kwh']['current_produced']
        # G1=packet['gas']['total']

        #
        printIfChanged("DT",int(time.time()),0,f)
        dT1=printIfChanged("T1",T1,dT1,f)
        dT2=printIfChanged("T2",T2,dT2,f)
	dP1=printIfChanged("P1",P1,dP1,f)
        dP2=printIfChanged("P2",P2,dP2,f)
        dE1=printIfChanged("E1",E1,0,f)
	dE2=printIfChanged("E2",E2,0,f)
        # dG1=printIfChanged("G1",G1,dG1,f)



#
#        data = [
#            ('Time', datetime.now()),
#            ('Total kWh High consumed', int(packet['kwh']['high']['consumed']*1000)),
#            ('Total kWh Low consumed', int(packet['kwh']['low']['consumed']*1000)),
#            ('Current kWh consumption', int(packet['kwh']['current_consumed']*1000)),
#            ('Total gas consumed', int(packet['gas']['total']*1000)),
#            ('Current kWh tariff', packet['kwh']['tariff'])
#        ]
#
#
#        print('\n'.join(['%-25s %s' % (k,d) for k,d in data]))
#
        file_counter-=1
    ##
    f.close()
    # close the file and move it to the data location
    dataname=os.path.join("../data/",filename)
    os.rename(filename,dataname)
    ## now make a new file
