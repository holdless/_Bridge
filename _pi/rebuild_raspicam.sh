cd home/pi/Downloads/raspicam-0.1.3
sudo rm -rf build
mkdir build
cd build
sudo cmake ..
sudo make
sudo make install
sudo ldconfig
