#!/usr/bin/env python3

import rospy
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
import os, cv2

#set rostopic URI to <hostname>/video
if os.environ["HOSTNAME"] is not None:
    URI = f"{os.environ['HOSTNAME']}/video"
else:
    URI = f"{os.uname()[1]}/video"

class CameraNode:
    def __init__(self):
        rospy.init_node('camera_node', anonymous=True)
        self.image_pub = rospy.Publisher(URI, Image, queue_size=10)
        self.cap = cv2.VideoCapture(0)  # Assuming the camera is at index 0
        self.bridge = CvBridge()

    def capture_and_publish(self):
        rate = rospy.Rate(100)  # Adjust the rate based on your requirement

        while not rospy.is_shutdown():
            ret, frame = self.cap.read()
            if ret:
                image_msg = self.bridge.cv2_to_imgmsg(frame, encoding="bgr8")
                self.image_pub.publish(image_msg)
            
            rate.sleep()
       
if __name__ == '__main__':
    try:
        camera_node = CameraNode()
        rospy.loginfo(f"\n#####[ROS CAMERA]#####\nvideo stream started on {URI}\n#####[ROS CAMERA]#####")
        camera_node.capture_and_publish()
    except rospy.ROSInterruptException as err:
        pass
        # rospy.logerr(err)