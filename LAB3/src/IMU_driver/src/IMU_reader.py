#!/usr/bin/env python
# -*- coding: utf-8 -*-

import utm
import string
import rospy
import serial
from math import sin, pi
from std_msgs.msg import Float64
# from imu_driver.msg import IMU_msg
from sensor_msgs.msg import Imu as Imu_msg
from sensor_msgs.msg import MagneticField as Mag_msg
import tf



if __name__ == '__main__':
    SENSOR_NAME = "VN100"
    rospy.init_node('IMU_reader')
#    serial_port = rospy.get_param('~port','/dev/ttyUSB0')
    serial_port = rospy.get_param('~port','/dev/ttyUSB0')
    serial_baud = rospy.get_param('~baudrate',115200) 
    port = serial.Serial(serial_port, serial_baud, timeout=3.)
    print("Using IMU sensor on port "+serial_port+" at "+str(serial_baud))
    imu_pub = rospy.Publisher(SENSOR_NAME+'/Imu', Imu_msg, queue_size=5)
    mag_pub = rospy.Publisher(SENSOR_NAME+'/Mag', Mag_msg, queue_size=5)

    rospy.sleep(0.2)        
    line = port.readline()
    
    IMU_msg = Imu_msg()
    IMU_msg.header.frame_id = "IMU"
    IMU_msg.header.seq=0

    MAG_msg = Mag_msg()
    MAG_msg.header.frame_id = "MagneticField"
    MAG_msg.header.seq=0
    

    
    print("Node start")
    
   
    try:
        while not rospy.is_shutdown():
            line = port.readline()
            line=line.decode("utf-8")
        
            if line.startswith('$VNYMR'):
                IMUdata=line.split(',')
                print(IMUdata)
                if IMUdata[2] == '':
                    print("No Data")
                else:
                    yaw = float(IMUdata[1])
                    #print("Yaw:",yaw)

                    pitch = float(IMUdata[2])
                    #print("Pitch:",pitch)

                    roll = float(IMUdata[3])
                    #print("Roll:",roll)

                    quaternion = tf.transformations.quaternion_from_euler(roll, pitch, yaw)

                    print("quaternion",quaternion)
                    #type(pose) = geometry_msgs.msg.Pose
                    IMU_msg.orientation.x = quaternion[0]
                    IMU_msg.orientation.y = quaternion[1]
                    IMU_msg.orientation.z = quaternion[2]
                    IMU_msg.orientation.w = quaternion[3]

                    MAG_msg.magnetic_field.x = float(IMUdata[4])
                    MAG_msg.magnetic_field.y = float(IMUdata[5])
                    MAG_msg.magnetic_field.z = float(IMUdata[6])

                    IMU_msg.angular_velocity.x    = float(IMUdata[7])
                    IMU_msg.angular_velocity.y    = float(IMUdata[8])
                    IMU_msg.angular_velocity.z    = float(IMUdata[9])
                    IMU_msg.linear_acceleration.x = float(IMUdata[10])
                    IMU_msg.linear_acceleration.y = float(IMUdata[11])
                    IMU_msg.linear_acceleration.z = float(IMUdata[12].split('*')[0])
                    #print(IMUdata[12].split('*'))
                    
                    
            imu_pub.publish(IMU_msg)
            mag_pub.publish(MAG_msg)
                
            
    except rospy.ROSInterruptException:
        port.close()
    