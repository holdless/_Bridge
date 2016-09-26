// 640.1.0926 @hsinchu
// function for mjpg_streamer -> opencv, rgb2bgr

#include "stdafx.h"
#include "opencv2/opencv.hpp"

using namespace cv;

// without "&", data will still be modified perminantly but not for header and metadata
// with"&", not only data but metadat/header will all be changed!
void rgb2bgr(Mat& image) 
{
	Mat new_img(image.rows, image.cols, CV_8UC3);
	Mat channel[3], new_channel[3];

    // The actual splitting.
	split(image, channel);
	split(new_img, new_channel);

	// 640.1.0926 hiroshi: test for re-combine channels:: BGR2RGB
	split(new_img, new_channel);
	new_channel[0] = channel[2];
	new_channel[1] = channel[1];
	new_channel[2] = channel[0];
	merge(new_channel, 3, image);
}
 
int _tmain(int argc, _TCHAR* argv[])
{
    Mat image;
    image = imread("D:/Users/changyht/Pictures/image proc/bgr.png", CV_LOAD_IMAGE_COLOR);   // Read the file

    if(! image.data )                              // Check for invalid input
    {
        cout <<  "Could not open or find the image" << std::endl ;
        return -1;
    }

	namedWindow( "Display window", CV_WINDOW_AUTOSIZE );// Create a window for display.

    // Create Matrices (make sure there is an image in input!)
    Mat channel[3];
    imshow( "Original Image", image );

	// 640.1.0926 hiroshi
	rgb2bgr(image);
    imshow("RGB2BGR", image);

    // The actual splitting.
    split(image, channel);

    channel[0]=Mat::zeros(image.rows, image.cols, CV_8UC1);//Set blue channel to 0

    //Merging red and green channels

    merge(channel,3,image);
    imshow("R+G", image);

    waitKey(0);//Wait for a keystroke in the window
    return 0;
}



