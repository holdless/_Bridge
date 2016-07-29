###################
## MANUALLY DOWNLOAD first!!!
###################
# <wiringPi>
#   (download file: http://www.uco.es/investiga/grupos/ava/node/40)

###################
### apt-get/pip ###
###################
### <RPi>
sudo rpi-update (then reboot)
# <RPi 2 -jessie: OpenGL error fix>
sudo apt-get install libgl1-mesa-dri and then sudo reboot

### <OpenCV>
sudo apt-get install libopencv-dev python-opencv opencv-doc
### <pi-camera: for OpenCV(python) to identify raspicam> 
sudo apt-get install python-picamera
### <python math-lib> 
sudo apt-get install python-numpy
### <cmake, i2c, telnet, kate> 
sudo apt-get install cmake i2c-tools telnet kate
### <audio>
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

########
reboot
########

# then use aplay <filename>
sudo apt-get install espeak bison python-dev swig               
### <google speech API related>
sudo apt-get install flac python-pycurl
### <SpeechRecognition /python & related>
sudo apt-get install python-pyaudio
sudo pip install SpeechRecognition 
# (To quickly try it out, run python -m speech_recognition after installing)
#<fix bug: SpeechRecognition can’t work>
# (this problem is due to in the new version of SpeechRecognition3.4.x, it requires new version of PyAudio (0.2.9), 
# and if you only use: sudo pip pyaudio, it’ll tell you “Requirement already satisfied…”, so we need to add following “ --upgrade")
sudo pip install pyaudio --upgrade
### <pyttsx (espeak tts API) /python>
sudo pip install pyttsx
### <google translate tts API related>
sudo apt-get install mplayer
### <pyhton Wifi module>
sudo pip install wifi

### <node.js>
sudo apt-get remove nodejs                

############
### make ###
############ 
###### <h264 & ffmpeg>
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
### <wiringPi>
cd /usr/src
git clone git://git.drogon.net/wiringPi
cd wiringPi
sudo ./build

##### <raspicam: for opencv(c++) recognise pi-cam>
# (download file: http://www.uco.es/investiga/grupos/ava/node/40)
unzip raspicam-0.1.3
cd raspicam-0.1.3
##
## if MMAL RGB/BGR bug has been fixed (RPi after 2016/7 version)
cd src/private
sudo nano private_impl.cpp
# L750~730
# int Private_Impl::convertFormat ( RASPICAM_FORMAT fmt ) {
#  switch ( fmt ) {
#    case RASPICAM_FORMAT_RGB:
#      return MMAL_ENCODING_BGR24; <--- MMAL_ENCODING_RBG24
#    case RASPICAM_FORMAT_BGR:
#      return MMAL_ENCODING_RGB24; <--- MMAL_ENCODING_BGR24
#      ....
#  }
# }
##
mkdir build
cd build
sudo cmake ..
sudo make
sudo make install
sudo ldconfig

##### <mjpg-streamer>
cd /usr/src/
# download from git
sudo git clone https://github.com/jacksonliam/mjpg-streamer.git
#sudo apt-get install libv4l-dev imagemagick build-essential cmake subversion

cd mjpg-streamer/mjpg-streamer-experimental

# revise CMakeLists.txt: 
sudo nano CMakeLists.txt
# mark down "add_subdirectory(plugins/input_opencv)"

sudo mkdir _build
cd _build
sudo cmake ..
sudo make
sudo make install

# move .exe and input/output.so file to mjpg-streamer-experimental directory
# cd to mjpg-streamer-experimental folder...
cd ..
sudo cp _build/mjpg_streamer mjpg_streamer
#sudo cp _build/plugins/input_file/input_file.so input_file.so
#sudo cp _build/plugins/input_http/input_http.so input_http.so
#sudo cp _build/plugins/input_ptp2/input_ptp2.so input_ptp2.so
sudo cp _build/plugins/input_raspicam/input_raspicam.so input_raspicam.so
sudo cp _build/plugins/input_uvc/input_uvc.so input_uvc.so
#sudo cp _build/plugins/output_file/output_file.so output_file.so
sudo cp _build/plugins/output_http/output_http.so output_http.so
#sudo cp _build/plugins/output_rtsp/output_rtsp.so output_rtsp.so
#sudo cp _build/plugins/output_udp/output_udp.so output_udp.so
#sudo cp _build/plugins/output_viewer/output_viewer.so output_viewer.so
