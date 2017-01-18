sudo apt-get update
#sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y

# 建置與編譯所需工具：
sudo apt-get install build-essential gcc cmake pkg-config

# 抓原始檔需要的工具：
sudo apt-get install git 

# Python相關：
sudo apt-get install python python-dev python-numpy 

# 圖形視窗程式庫：
sudo apt-get install libgtk2.0-dev

# 音訊視訊的編解碼、錄製、轉換、串流：
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev

# 圖檔格式（選用性）：
sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libjasper-dev

# IEEE 1394相機介面（選用性）： 
sudo apt-get install libdc1394-22-dev

# TBB（Intel's Threading Building Blocks）（選用性）：
sudo apt-get install libtbb2 libtbb-dev
# 出現錯誤訊息：
# E: Unable to locate package libtbb2
# E: Package 'libtbb-dev' has no installation candidate

# 大都沒問題，但是Raspbian沒有libtbb2和libtbb-dev這兩個套件，於是也必須自己編譯；
# 照理說這是選用性功能，可有可無，但TBB是C/C++平行處理程式庫，有了它，OpenCV的速度會較快。

# 到TBB網站，查詢原始碼檔案的網址，下載並解壓縮，得到含原始碼檔案的目錄，切換進去：
wget https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb44_20151115oss_src.tgz
tar zxvf tbb44_20151115oss_src.tgz
cd tbb44_20151115oss

# 開始建置，根據這篇，應加上參數：
make tbb CXXFLAGS="-DTBB_USE_GCC_BUILTINS=1 -D__TBB_64BIT_ATOMICS=0"

# 然後進入子目錄build，裡頭會有兩個目錄存放建置結果，其一以debug結尾、另一個以release結尾，切換到release那一個：
cd build
cd linux_armv7_gcc_cc4.9.2_libc2.19_kernel4.1.13_release

# 執行tbbvars.sh這支腳本程式檔，它會設定許多環境變數，之後的OpenCV才知道TBB在哪：
source tbbvars.sh

# 搞定TBB後，接著是OpenCV，原始碼檔案約580 MB，建置後需要約1.6 GB，請先確認儲存空間是否足夠。

# 以git下載位於GitHub的OpenCV原始碼，得到目錄opencv，切換進去：
git clone git@github.com:Itseez/opencv.git 
cd opencv

# 目前處於最新的版本分支，到OpenCV官網查詢後，得知目前釋出的正式版本為3.1.0，所以決定切換到該分支： 
git checkout 3.1.0

# 新增目錄build存放建置結果，切換進去：
mkdir build
cd build

# 先執行cmake產生建置需要的設定檔：
cmake -DWITH_TBB:BOOL=TRUE -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local ..

# 其中「-DWITH_TBB:BOOL=TRUE「代表我們想要使用TBB，「-D CMAKE_INSTALL_PREFIX=/usr/local」代表之後要安裝的路徑，
# 最後的「..」代表原始碼所在路徑。

# 然後開始建置：
make -j4

# 由於Raspberry Pi的CPU速度很慢，根據其他人的經驗，約需要10小時。但我使用Pi 2，
# 可下參數「-j4」充分利用四個核心，我大概花了3小時。

# 最後終於出現完成的訊息：
# ...
# Linking CXX executable ../../bin/opencv_test_calib3d
# [100%] Built target opencv_test_calib3d
# Linking CXX shared module ../../lib/python3/cv2.cpython-34m.so
# [100%] Built target opencv_python3
# Linking CXX shared module ../../lib/cv2.so
# [100%] Built target opencv_python2

# 然後安裝：
sudo make install

# 執行指令更新程式庫：
sudo ldconfig

# 試著檢查OpenCV的版本：
pkg-config --modversion opencv
# 3.1.0

#
# 然後是是撰寫C++程式，顯示一張圖檔。新增檔案test.cpp，準備一張圖檔test.png，程式內容如下：
# #include <opencv2/core/core.hpp>
# #include <opencv2/highgui/highgui.hpp>
# #include <iostream>
# 
# using namespace cv;
# using namespace std;
# 
# int main(int argc, char **argv)
# {
#    Mat image = imread("test.jpg", CV_LOAD_IMAGE_COLOR);
#    namedWindow("test", WINDOW_AUTOSIZE);
#    imshow("test", image);
#    waitKey(0);
#    return 0;
# }

# 以底下兩道指令之一進行編譯：
# $ g++ -lopencv_core -lopencv_highgui -lopencv_imgcodecs tes.cpp
# $ g++ `pkg-config --libs opencv` test.cpp

//////////
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install build-essential cmake cmake-gui pkg-config
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install libxvidcore-dev libx264-dev
sudo apt-get install libgtk2.0-dev
sudo apt-get install libatlas-base-dev gfortran
sudo apt-get install python2.7-dev python3-dev

sudo apt-get update
sudo apt-get upgrade

cd ~
cd Downloads
mkdir opencv
cd opencv
wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.2.0.zip
unzip opencv.zip
wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.2.0.zip
unzip opencv_contrib.zip

cd ~
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

sudo apt-get update
sudo apt-get upgrade

pip install numpy

cd Downloads/opencv
mkdir build
cd build

# >>> use cmake-gui to build and generate

sudo make -j4
make install
