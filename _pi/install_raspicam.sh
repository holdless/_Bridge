# <raspicam: for opencv(c++) recognise pi-cam>
# (download file: http://www.uco.es/investiga/grupos/ava/node/40)
unzip raspicam-0.1.3
cd raspicam-0.1.3
################
## if MMAL RGB/BGR bug has been fixed (RPi after 2016/7 version)
cd src/private
sudo nano private_impl.cpp

# int Private_Impl::convertFormat ( RASPICAM_FORMAT fmt ) {
#  switch ( fmt ) {
#    case RASPICAM_FORMAT_RGB:
#      return MMAL_ENCODING_BGR24; <--- MMAL_ENCODING_RBG24
#    case RASPICAM_FORMAT_BGR:
#      return MMAL_ENCODING_RGB24; <--- MMAL_ENCODING_BGR24
#      ....
#  }
# }
################
mkdir build
cd build
sudo cmake ..
sudo make
sudo make install
sudo ldconfig
