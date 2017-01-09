// LoadCaffe.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "IhsorihGoogLeNetObjectRecognizer.h"
int main(int argc, char **argv) {
	// load image
//	cv::Mat frame = imread("D:/Users/changyht/Pictures/googlenet_320x320/bike.jpg");
	cv::Mat frame;
	cv::VideoCapture cap("D:/Users/changyht/Videos/Google - Deep Learning/L2 Deep Neural Networks Videos/01 - Intro to Lesson 2.mp4");

	if (!cap.isOpened()) {
		std::cout << "Cannot open the video file on C++ API" << std::endl;
		return -1;
	}

	double fps = cap.get(CV_CAP_PROP_FPS); // get the frame per second of the video
	cout << "Frame per second: " << fps << endl;


	// create obj-rec object
	IhsorihGoogLeNetObjectRecognizer objRec;
	objRec.init("D:/Users/changyht/Documents/_github/caffe/bvlc_googlenet.prototxt",
		"D:/Users/changyht/Documents/_github/caffe/bvlc_googlenet.caffemodel",
		"D:/Users/changyht/Documents/_github/caffe/synset_words.txt");

	int k = 0;
	for (;;) {
		if (!cap.read(frame)) {
			cout << "Cannot read the frame from video file" << endl;
			break;
		}
		// do object recognition
		if (k % 20 == 19) {
			objRec.setImage(frame);
			objRec.predict();
			objRec.putProbBar(frame);
			k = 0;
		}
		else
			k++;

		cv::imshow("etst", frame);
		if (waitKey(30) == 27) //wait for 'esc' key press for 30 ms. If 'esc' key is pressed, break loop
		{
			cout << "esc key is pressed by user" << endl;
			break;
		}
	}

	return 0;
}

