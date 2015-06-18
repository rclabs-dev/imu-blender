#!/usr/bin/python

import os
import sys
sys.path.append(os.getcwd() + "/MPU6050")
import mpu6050
import time
import math
import csv
import socket
import smbus
from pycomms import PyComms

# Sensor initialization
mpu = mpu6050.MPU6050()
mpu.dmpInitialize()
mpu.setDMPEnabled(True)

# Send UDP Data
def send_data(msg):
    try:
        sock.sendto(msg, (REMOTE_IP, DST_PORT))
    except socket.error as err:
        sock.close()
        print "Connection err!"
    
# get expected DMP packet size for later comparison
packetSize = mpu.dmpGetFIFOPacketSize() 


# UDP socket instance
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Read configuration from file (csv file format)
with open("imu-blender.cfg", 'rb') as f:
    file = csv.DictReader(f)
    for rows in file:
        REMOTE_IP = rows['remote_ip']
	DST_PORT = int(rows['dst_port'])
	DEBUG = rows['debug']

print ("IMU Sensor started (CTRL-C to stop)!")

while True:
    # Get INT_STATUS byte
    mpuIntStatus = mpu.getIntStatus()
  
    # check for DMP data ready interrupt (this should happen frequently) 
    if mpuIntStatus >= 2:
        # get current FIFO count
        fifoCount = mpu.getFIFOCount()
        
        # check for overflow (this should never happen unless our code is too inefficient)
        if fifoCount == 1024:
            # reset so we can continue cleanly
            mpu.resetFIFO()
            print('FIFO overflow!')
            
            
        # wait for correct available data length, should be a VERY short wait
        fifoCount = mpu.getFIFOCount()
        while fifoCount < packetSize:
            fifoCount = mpu.getFIFOCount()
        
        result = mpu.getFIFOBytes(packetSize)
        # Get quaternio, q return y, x, z, w
        q = mpu.dmpGetQuaternion(result)

        x = "{0:.6f}".format(q['x'])
	y = "{0:.6f}".format(q['y'])
	z = "{0:.6f}".format(q['z'])
	w = "{0:.6f}".format(q['w'])

        if DEBUG == "1":
           print (x),
	   print (y),
	   print (z),
	   print (w)

	# Sends quaternion through UDP
        send_data(str(x) + "," + str(y) + "," + str(z) + "," + str(w))
        fifoCount -= packetSize  

