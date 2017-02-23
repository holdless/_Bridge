#pragma once
#include "stdafx.h"

#include "tiny_dnn/tiny_dnn.h" // vec_t is defined here

#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <boost/foreach.hpp>
#include <boost/filesystem.hpp>

// hiroshi's class:
//#include "D:/Users/changyht/Documents/Visual Studio 2015/Projects/Math_Utilities/Math_Utilities/numcpp.h"
//#include "D:/Users/changyht/Documents/Visual Studio 2015/Projects/_readTxtFile/_readTxtFile/parser.h"

using namespace boost::filesystem;
using namespace std;
using namespace tiny_dnn;
//using namespace tiny_dnn::activation;
//using namespace tiny_dnn::layers;

struct VectorRgb {
	vector<vec_t> red;
	vector<vec_t> green;
	vector<vec_t> blue;
};

struct VectorData {
	VectorRgb rgb;
	vector<vec_t> gray;
};

struct MatData {
	cv::Mat gray;
	cv::Mat rgb;
};

class TinyDnnImage {
public:
	TinyDnnImage(	char* path,
	 		     	//	int colorType,
					bool isSingleFile) {

		if (isSingleFile)
			convert_image(path);
		else
			convert_images(path);
	}

	VectorData getVecData() {
		return _vecData;
	}

	vector<vec_t> getVecData(char* type) {
		if (strcmp(type, "red") == 0)
			return _vecData.rgb.red;
		else if (strcmp(type, "green") == 0)
			return _vecData.rgb.green;
		else if (strcmp(type, "blue") == 0)
			return _vecData.rgb.blue;
		else
			return _vecData.gray;
	}

	cv::Mat getMatData(char* type) {
		if (strcmp(type, "rgb") == 0)
			return _matData.rgb;
		else
			return _matData.gray;
	}

	// type: CV_32FC2, CV_8UC3...
	cv::Mat vec2mat(VectorData vecdata, cv::Size matSize, int type) {
	
		int channels(1);
		if (type == CV_8UC3 ||
			type == CV_8SC3 ||
			type == CV_16UC3 ||
			type == CV_16SC3 ||
			type == CV_32SC3 ||
			type == CV_32FC3 ||
			type == CV_64FC3
			)
			channels = 3;

		
		cv::Mat dstMat(matSize.height, matSize.width, type);
		
		if (channels == 1)
		{
			// from vector<vec_t> to vector<uchar>
			vector<uchar> vec;
			for (unsigned int i = 0; i < vecdata.gray[0].size(); i++) {
				vec.push_back((uchar)vecdata.gray[0].at(i));
			}

			memcpy(dstMat.data, vec.data(), vec.size()*sizeof(uchar));

		}
		else if (channels == 3)
		{
			// from vector<vec_t> to vector<uchar>
			vector<int> vec[3];
			for (unsigned int i = 0; i < vecdata.rgb.green[0].size(); i++) {
				vec[0].push_back((int)vecdata.rgb.green[0].at(i));
				vec[1].push_back((int)vecdata.rgb.blue[0].at(i));
				vec[2].push_back((int)vecdata.rgb.red[0].at(i));
			}
/*
			int k = 0;
			for (int j = 0; j < size.height; j++) {
				for (int i = 0; i < size.width; i++) {
					dstMat.at<cv::Vec3b>(j, i)[0] = vec[0][k];
					dstMat.at<cv::Vec3b>(j, i)[1] = vec[1][k];
					dstMat.at<cv::Vec3b>(j, i)[2] = vec[2][k];
					k++;
				}
			}*/
			int k = 0;
			for (int j = 0; j < matSize.height; j++) {
				uchar* dstData = dstMat.ptr<uchar>(j);
				for (int i = 0; i < matSize.width; i++) {
//					*(dstData + channels*i + 0) = vec[0][k];
	//				*(dstData + channels*i + 1) = vec[1][k];
		//			*(dstData + channels*i + 2) = vec[2][k];
					dstData[channels*i + 2] = vec[0][k];
					dstData[channels*i + 1] = vec[1][k];
					dstData[channels*i + 0] = vec[2][k];
					k++;
				}
			}
			
		}

		return dstMat;
	}

private:
	VectorData _vecData;
//	vector<vec_t> _vecData;
	MatData _matData;
//	cv::Mat _matData;

	void convert_image(const std::string& imagefilename) {
		// gray
		_matData.gray = cv::imread(imagefilename, cv::IMREAD_GRAYSCALE);

		if (_matData.gray.data == nullptr) return; // cannot open, or it's not an image

		cv::Mat_<uint8_t> resized;
		cv::resize(_matData.gray, resized, _matData.gray.size());
		vec_t d;

		std::transform(resized.begin(), resized.end(), std::back_inserter(d),
			[=](uint8_t c) { return c * 1; });
		_vecData.gray.push_back(d);


		// rgb
		_matData.rgb = cv::imread(imagefilename, cv::IMREAD_COLOR);

		if (_matData.rgb.data == nullptr) return; // cannot open, or it's not an image

		cv::Mat channel[3];
		cv::split(_matData.rgb, channel);

		cv::Mat_<uint8_t> resizedArray[3];
		vec_t dArray[3];

		for (int i = 0; i < 3; i++)
		{
			cv::resize(channel[i], resizedArray[i], channel[i].size());
			std::transform(	resizedArray[i].begin(), 
							resizedArray[i].end(), 
							std::back_inserter(dArray[i]),
							[=](uint8_t c) { return c * 1; });
		}
		_vecData.rgb.green.push_back(dArray[0]);
		_vecData.rgb.blue.push_back(dArray[1]);
		_vecData.rgb.red.push_back(dArray[2]);
	}
	// convert all images found in directory to vec_t
	void convert_images(const std::string& directory) 	{
		path dpath(directory);

		BOOST_FOREACH(	const path& p,
						std::make_pair(directory_iterator(dpath), directory_iterator())) {
			if (is_directory(p)) continue;
			convert_image(p.string());
		}
	}
};



