// LoadVGGFace.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "IhsorihVGGFaceRecognizer.h"
#include <time.h>

#define _MILLIONTH 1E-9

int main(int argc, char **argv) {
	// load image
	cv::Mat frame = imread("vgg_face_caffe/ak.png");
	/*	cv::Mat frame;
	cv::VideoCapture cap("D:/Users/changyht/Videos/Google - Deep Learning/L2 Deep Neural Networks Videos/01 - Intro to Lesson 2.mp4");
	if (!cap.isOpened()) {
	std::cout << "Cannot open the video file on C++ API" << std::endl;
	return -1;
	}
	double fps = cap.get(CV_CAP_PROP_FPS); // get the frame per second of the video
	cout << "Frame per second: " << fps << endl;
	*/

	// create obj-rec object
	IhsorihVGGFaceRecognizer objRec;
	objRec.init("vgg_face_caffe/VGG_FACE_deploy.prototxt",
		"vgg_face_caffe/VGG_FACE.caffemodel",
		"vgg_face_caffe/names.txt");

	int start;
	double duration;
	objRec.setImage(frame);
	start = clock();
	objRec.predict();
	duration = (clock() - start) / (double)CLOCKS_PER_SEC;
	cout << endl << "predict time laspe: " << duration << endl;
	objRec.putProbBar(frame);

	cv::imshow("etst", frame);
	if (waitKey(0) == 27) //wait for 'esc' key press for 30 ms. If 'esc' key is pressed, break loop
	{
		cout << "esc key is pressed by user" << endl;
		//break;
	}

	/*
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
	*/
	return 0;
}

