// The contents of this file are in the public domain. See LICENSE_FOR_EXAMPLE_PROGRAMS.txt
/*
This example program shows how to find frontal human faces in an image.  In
particular, this program shows how you can take a list of images from the
command line and display each on the screen with red boxes overlaid on each
human face.
The examples/faces folder contains some jpg images of people.  You can run
this program on them and see the detections by executing the following command:
./face_detection_ex faces/*.jpg

This face detector is made using the now classic Histogram of Oriented
Gradients (HOG) feature combined with a linear classifier, an image pyramid,
and sliding window detection scheme.  This type of object detector is fairly
general and capable of detecting many types of semi-rigid objects in
addition to human faces.  Therefore, if you are interested in making your
own object detectors then read the fhog_object_detector_ex.cpp example
program.  It shows how to use the machine learning tools which were used to
create dlib's face detector.
Finally, note that the face detector is fastest when compiled with at least
SSE2 instructions enabled.  So if you are using a PC with an Intel or AMD
chip then you should enable at least SSE2 instructions.  If you are using
cmake to compile this program you can enable them by using one of the
following commands when you create the build project:
cmake path_to_dlib_root/examples -DUSE_SSE2_INSTRUCTIONS=ON
cmake path_to_dlib_root/examples -DUSE_SSE4_INSTRUCTIONS=ON
cmake path_to_dlib_root/examples -DUSE_AVX_INSTRUCTIONS=ON
This will set the appropriate compiler options for GCC, clang, Visual
Studio, or the Intel compiler.  If you are using another compiler then you
need to consult your compiler's manual to determine how to enable these
instructions.  Note that AVX is the fastest but requires a CPU from at least
2011.  SSE4 is the next fastest and is supported by most current machines.
*/

/* 2017.1.21 hiroshi:
1. properties setup:
opencv lib path/dll path (input) should be additionally set
2. too slow for live-cam on win7, maybe try on Mac or linux with blas or lapack libraries
3. still need to try from dlib to opencv mat format code...
*/


#include <dlib/image_processing.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <iostream>
// 2017.1.21 hiroshi: add cv_image.h & to_open_cv.h
#include <dlib/opencv/cv_image.h>
#include <dlib/opencv/to_open_cv.h>
// 2017.1.21 hiroshi: import opencv.hpp
#include <opencv2/opencv.hpp>
// 2017.1.25 hiroshi: draw_rectangle
#include <dlib/image_transforms.h>
// 2017.1.25 hiroshi: test time
#include <time.h>

using namespace dlib;
using namespace std;

// ----------------------------------------------------------------------------------------

int main(int argc, char** argv)
{
	try
	{
		if (argc == 1)
		{
			cout << "Give some image files as arguments to this program." << endl;
			return 0;
		}

		frontal_face_detector detector = get_frontal_face_detector();
//		image_window win;

		int start;
		double duration;
		// Loop over all the images provided on the command line.
		for (int i = 1; i < argc; ++i)
		{
			cout << "processing image " << argv[i] << endl;
			array2d<rgb_pixel> img;
			//load_image(img, argv[i]);
			// 2017.1.21 hiroshi: add dlib::cv_image object
			start = clock();
			cv::Mat src = cv::imread(argv[i], CV_LOAD_IMAGE_COLOR);
			assign_image(img, dlib::cv_image<bgr_pixel>(src));
			duration = (clock() - start) / (double)CLOCKS_PER_SEC;
			cout << endl << "convert to Dlib-img time: " << duration << endl;

			// Make the image bigger by a factor of two.  This is useful since
			// the face detector looks for faces that are about 80 by 80 pixels
			// or larger.  Therefore, if you want to find faces that are smaller
			// than that then you need to upsample the image as we do here by
			// calling pyramid_up().  So this will allow it to detect faces that
			// are at least 40 by 40 pixels in size.  We could call pyramid_up()
			// again to find even smaller faces, but note that every time we
			// upsample the image we make the detector run slower since it must
			// process a larger image.
			pyramid_up(img);

			// Now tell the face detector to give us a list of bounding boxes
			// around all the faces it can find in the image.
			start = clock();
			std::vector<rectangle> dets = detector(img);
			duration = (clock() - start) / (double)CLOCKS_PER_SEC;
			cout << endl << "detecting time: " << duration << endl;

			cout << "Number of faces detected: " << dets.size() << endl;
			// Now we show the image on the screen and the face detections as
			// red overlay boxes.
//			win.clear_overlay();
//			win.set_image(img);
//			win.add_overlay(dets, rgb_pixel(255, 0, 0));

			// 2017.1.25 hiroshi: directly write boxes into img
			start = clock();
			for (int i = 0; i < dets.size(); i++)
				draw_rectangle(img, dets[i], rgb_pixel(255, 0, 0));
			duration = (clock() - start) / (double)CLOCKS_PER_SEC;
			cout << endl << "write rect in img time: " << duration << endl;
		
			//2017.1.25 hiroshi: to_Mat
			start = clock();
			cv::Mat cvimg = dlib::toMat(img);
			cv::cvtColor(cvimg, cvimg, cv::COLOR_RGB2BGR);
			duration = (clock() - start) / (double)CLOCKS_PER_SEC;
			cout << endl << "convert to Mat time: " << duration << endl;

			cv::imshow("cv", cvimg);
			cv::waitKey(33);

			cout << "Hit enter to process the next image..." << endl;
			cin.get();
		}

		cv::waitKey(0);
	}
	catch (exception& e)
	{
		cout << "\nexception thrown!" << endl;
		cout << e.what() << endl;
	}
}
