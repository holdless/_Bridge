// LoadCaffe.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
using namespace cv;
using namespace cv::dnn;
#include <fstream>
#include <iostream>
#include <cstdlib>
using namespace std;

string caffePath = "D:/Users/changyht/Documents/_github/caffe/";
string imagePath = "D:/Users/changyht/Pictures/googlenet_320x320/";
string imageName = "panda.jpg";
const char* synset = "D:/Users/changyht/Documents/_github/caffe/synset_words.txt";

/* Find best class for the blob (i. e. class with maximal probability) */
void getMaxClass(dnn::Blob &probBlob, int *classId, double *classProb)
{
	Mat probMat = probBlob.matRefConst().reshape(1, 1); //reshape the blob to 1x1000 matrix
	Point classNumber;
	minMaxLoc(probMat, NULL, classProb, NULL, &classNumber);
	*classId = classNumber.x;
}

std::vector<String> readClassNames(const char *filename = synset)
{
	std::vector<String> classNames;
	std::ifstream fp(filename);
	if (!fp.is_open())
	{
		std::cerr << "File with classes labels not found: " << filename << std::endl;
		exit(-1);
	}
	std::string name;
	while (!fp.eof())
	{
		std::getline(fp, name);
		if (name.length())
			classNames.push_back(name.substr(name.find(' ') + 1));
	}
	fp.close();
	return classNames;
}

int main(int argc, char **argv) {

	cv::dnn::initModule();  //Required if OpenCV is built as static libs
	String modelTxt = caffePath + "bvlc_googlenet.prototxt";
	String modelBin = caffePath + "bvlc_googlenet.caffemodel";
	String imageFile = imagePath + imageName;
	Net net = dnn::readNetFromCaffe(modelTxt, modelBin);
	if (net.empty())
	{
		std::cerr << "Can't load network by using the following files: " << std::endl;
		std::cerr << "prototxt:   " << modelTxt << std::endl;
		std::cerr << "caffemodel: " << modelBin << std::endl;
		std::cerr << "bvlc_googlenet.caffemodel can be downloaded here:" << std::endl;
		std::cerr << "http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel" << std::endl;
		exit(-1);
	}
	Mat img = imread(imageFile);
	if (img.empty())
	{
		std::cerr << "Can't read image from the file: " << imageFile << std::endl;
		exit(-1);
	}
	resize(img, img, Size(224, 224));                   //GoogLeNet accepts only 224x224 RGB-images
	dnn::Blob inputBlob = dnn::Blob::fromImages(img);   //Convert Mat to dnn::Blob batch of images
	net.setBlob(".data", inputBlob);        //set the network input
	net.forward();                          //compute output
	dnn::Blob prob = net.getBlob("prob");   //gather output of "prob" layer
	int classId;
	double classProb;
	getMaxClass(prob, &classId, &classProb);//find the best class
	std::vector<String> classNames = readClassNames();
	std::cout << "Best class: #" << classId << " '" << classNames.at(classId) << "'" << std::endl;
	std::cout << "Probability: " << classProb * 100 << "%" << std::endl;
	return 0;
}

