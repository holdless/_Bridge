# <raspicam: for opencv(c++) recognise pi-cam>
# (download file: http://www.uco.es/investiga/grupos/ava/node/40)
unzip raspicam-0.1.3
cd raspicam-0.1.3
mkdir build
cd build
sudo cmake ..
sudo make
sudo make install
sudo ldconfig
