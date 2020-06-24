#!/usr/bin/env python
# coding: utf-8

# In[1]:


from mtcnn import MTCNN
import cv2


# In[2]:


IMG_PATH = "D:\\_hiroshi\\_dataset\\5-celebrity-faces-dataset\\val\\ben_afflek\\";
IMG_NAME = "httpbpblogspotcomedLMjVpRGkSWexgsXjkNIAAAAAAAADWgFFtAUqBlhAsjpg"
IMG_EXT = ".jpg"
image = cv2.cvtColor(cv2.imread( IMG_PATH+IMG_NAME+IMG_EXT ), cv2.COLOR_BGR2RGB)
detector = MTCNN()
result = detector.detect_faces(image)


# In[3]:


# Result is an array with all the bounding boxes detected. We know that for 'ivan.jpg' there is only one.
bounding_box = result[0]['box']
keypoints = result[0]['keypoints']

cv2.rectangle(image,
              (bounding_box[0], bounding_box[1]),
              (bounding_box[0]+bounding_box[2], bounding_box[1] + bounding_box[3]),
              (0,155,255),
              5)

cv2.circle(image,(keypoints['left_eye']), 10, (0,155,255), -1)
cv2.circle(image,(keypoints['right_eye']), 10, (0,155,255), -1)
cv2.circle(image,(keypoints['nose']), 20, (0,155,255), -1)
cv2.circle(image,(keypoints['mouth_left']), 10, (0,155,255), -1)
cv2.circle(image,(keypoints['mouth_right']), 10, (0,155,255), -1)

image_landmark = IMG_PATH+IMG_NAME+"_landmark"+IMG_EXT
cv2.imwrite( IMG_PATH+IMG_NAME+"_landmark"+IMG_EXT , cv2.cvtColor(image, cv2.COLOR_RGB2BGR))

print(result)


# In[4]:


result


# In[7]:


imPath = "D:\\_hiroshi\\_dataset\\5-celebrity-faces-dataset\\val\\ben_afflek\\httpbpblogspotcomedLMjVpRGkSWexgsXjkNIAAAAAAAADWgFFtAUqBlhAsjpg.jpg"

import matplotlib.pyplot as plt # plt 用于显示图片
import matplotlib.image as mpimg # mpimg 用于读取图片
import numpy as np

orgImg= mpimg.imread(imPath) # 读取和代码处于同一目录下的 lena.png
plt.imshow(orgImg) # 显示图片
#plt.axis('off') # 不显示坐标轴
#plt.show()

croppedImg = orgImg[bounding_box[1]:bounding_box[1] + bounding_box[3],bounding_box[0]:bounding_box[0]+bounding_box[2],:]
plt.imshow(croppedImg)

mpimg.imsave('test.jpg', croppedImg)


# In[ ]:




