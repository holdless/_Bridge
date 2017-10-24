# import the necessary packages
from imutils.video import FPS
import numpy as np
#import argparse
from imutils.video import FileVideoStream
from imutils.video import FPS
import imutils
import numpy as np
import time
import cv2

videoPath = "D:/Users/changyht/Videos/1. Smoov & Curly's Bogus Journey Videos/29 - Back to the Future.mp4";

# open a pointer to the video stream and start the FPS timer
print("[INFO] starting video file thread...")
fvs = FileVideoStream(videoPath).start() # start thread for capturing
time.sleep(1.0)
fps = FPS().start()

# loop over frames from the video file stream
while fvs.more():
    frame = fvs.read()
    frame = imutils.resize(frame, width=450)
#   frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
#   frame = np.dstack([frame, frame, frame])
 
    # display the size of the queue on the frame
    cv2.putText(frame, "Queue Size: {}".format(fvs.Q.qsize()),
		(10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)	 
    # show the frame and update the FPS counter
    cv2.imshow("Frame", frame)
    cv2.waitKey(1)
    fps.update()

# stop the timer and display FPS information
fps.stop()
print("[INFO] elasped time: {:.2f}".format(fps.elapsed()))
print("[INFO] approx. FPS: {:.2f}".format(fps.fps()))
 
cv2.destroyAllWindows()
