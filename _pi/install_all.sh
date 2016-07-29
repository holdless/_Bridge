###################
## MANUALLY DOWNLOAD first!!!
###################
# <wiringPi>
#   (download file: http://www.uco.es/investiga/grupos/ava/node/40)

###################
### apt-get/pip ###
###################
# <RPi>
sudo rpi-update (then reboot)
# <RPi 2 -jessie: OpenGL error fix>
sudo apt-get install libgl1-mesa-dri and then sudo reboot

# <OpenCV>
sudo apt-get install libopencv-dev python-opencv opencv-doc
# <pi-camera: for OpenCV(python) to identify raspicam> 
sudo apt-get install python-picamera
# <python math-lib> 
sudo apt-get install python-numpy
# <cmake> 
sudo apt-get install cmake  
# <i2c> 
sudo apt-get install i2c-tools
# <telnet> 
sudo apt-get install telnet
# <text-editor>
sudo apt-get install kate
# <audio>
sudo apt-get install libasound2-dev
# (setup sound car)
alsamixer
# (choose your usb sound card, and setup amp & mic volume)
# for checking, enter:
aplay -l
# edit .asoundrc file
sudo nano ~/.asoundrc
# add: pcm.!default sysdefault:Device
# save

reboot

# then use aplay <filename>
sudo apt-get install espeak bison python-dev swig               
# <google speech API related>
sudo apt-get install flac python-pycurl
# <SpeechRecognition /python & related>
sudo apt-get install python-pyaudio
sudo pip install SpeechRecognition 
# (To quickly try it out, run python -m speech_recognition after installing)
#<fix bug: SpeechRecognition can’t work>
# (this problem is due to in the new version of SpeechRecognition3.4.x, it requires new version of PyAudio (0.2.9), 
# and if you only use: sudo pip pyaudio, it’ll tell you “Requirement already satisfied…”, so we need to add following “ --upgrade")
sudo pip install pyaudio --upgrade
# <pyttsx (espeak tts API) /python>
sudo pip install pyttsx
# <google translate tts API related>
sudo apt-get install mplayer
# <pyhton Wifi module>
sudo pip install wifi

############
### make ###
############ 
# <h264 & ffmpeg>
  cd /usr/src
  sudo git clone git://git.videolan.org/x264
  cd x264
  sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
  sudo make
  sudo make install

  cd /usr/src
  sudo git clone git://source.ffmpeg.org/ffmpeg.git
  cd ffmpeg
  sudo ./configure --arch=armel --target-os=linux --enable-gpl --enable-libx264 --enable-nonfree
  sudo make
  sudo make install
# <wiringPi>
  cd /usr/src
  git clone git://git.drogon.net/wiringPi
  cd wiringPi
  sudo ./build
  # (download file: http://www.uco.es/investiga/grupos/ava/node/40)
  unzip raspicam-0.1.3
  cd raspicam-0.1.3
  mkdir build
  cd build
  sudo cmake ..
  sudo make
  sudo make install
  sudo ldconfig
# <mjpg-streamer>
  cd /usr/src/
  sudo git clone https://github.com/jacksonliam/mjpg-streamer.git
  sudo apt-get install libv4l-dev libjpeg8-dev imagemagick build-essential cmake subversion
  sudo apt-get autoremove --purge
  cd mjpg-streamer/mjpg-streamer-experimental
  sudo make
  # <for "apt-get" OpenCV>
  #sudo apt-get install libopencv-dev  
  #(<—  install again (2.4.9)=> 因為 libjpeg8-dev and libopencv-dev 會互相把對方移除. libjpeg8若被移除則不能make mjpg-streamer, 
  # 而libopencv若被移除則raspicam相關的影像處理都會有問題 要重新安裝libopencv-dev並rebuild [ps. 跟是否灌 openCV 3 無關])
               
# <node.js>
  sudo apt-get remove nodejs                
