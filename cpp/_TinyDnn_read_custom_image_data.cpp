// _TinyDnn_read_custom_image_data.cpp : Defines the entry point for the console application.
//

//#include <stdio.h> //20161130, sprintf

#include "stdafx.h"
/*
#include "opencv2/core/core.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/ml/ml.hpp"  // for load .csv (CvMLData)
#include <iostream>
#include <fstream> // write .csv
#include <sstream>

#include <time.h>
*/
//
#include "tiny_dnn/tiny_dnn.h" // vec_t is defined here

//#include <opencv2/imgcodecs.hpp> // using highgui.hpp instead, not in opencv2.4.11
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
//#include <boost/foreach.hpp>
//#include <boost/filesystem.hpp>

// hiroshi's class:
//#include "D:/Users/changyht/Documents/Visual Studio 2015/Projects/Math_Utilities/Math_Utilities/numcpp.h"
//#include "D:/Users/changyht/Documents/Visual Studio 2015/Projects/_readTxtFile/_readTxtFile/parser.h"

#include "tinydnn_image.h"

//using namespace boost::filesystem;
using namespace std;
using namespace tiny_dnn;
using namespace tiny_dnn::activation;
using namespace tiny_dnn::layers;

int main() {
	// init setting
	char* path = "D:/Users/changyht/Pictures/image proc/bgr.png";

	// init tiny-dnn image object (vector<vec_t>)
	TinyDnnImage img(	path, 
//						cv::IMREAD_GRAYSCALE, 
						true);

	// convert
	cv::Mat finMat = img.vec2mat(	img.getVecData(), // VectorData
									img.getMatData("rgb").size(), // mat size
									CV_8UC1);

	cv::imshow("mat image", img.getMatData("rgb"));
	cv::imshow("converted image", finMat);
	cv::waitKey(0);
		

	return 0;
}


