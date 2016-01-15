// faceRecog.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "opencv2/core/core.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include "opencv2/ml/ml.hpp"  // for load .csv (CvMLData)

#include <fstream> // write .csv

#include <iostream>
#include <fstream>
#include <sstream>

#include <time.h> // timer..


using namespace cv;
using namespace std;

//String face_cascade_name = ".../lbpcascades/lbpcascade_frontalface.xml";
String face_cascade_name = ".../haarcascades/haarcascade_frontalface_alt.xml";
//String eyes_cascade_name = ".../haarcascades/haarcascade_eye_tree_eyeglasses.xml";
CascadeClassifier face_cascade;
//CascadeClassifier eyes_cascade;

static Mat norm_0_255(InputArray _src) 
{
    Mat src = _src.getMat();
    // Create and return normalized image:
    Mat dst;
    switch(src.channels()) {
    case 1:
        cv::normalize(_src, dst, 0, 255, NORM_MINMAX, CV_8UC1);
        break;
    case 3:
        cv::normalize(_src, dst, 0, 255, NORM_MINMAX, CV_8UC3);
        break;
    default:
        src.copyTo(dst);
        break;
    }
    return dst;
}

static void read_csv(const string& filename, 
					 vector<Mat>& images, 
					 vector<int>& labels, 
					 char separator = ';') 
{
    ifstream file(filename.c_str(), ifstream::in);
    if (!file) 
	{
        string error_message = "No valid input file was given, please check the given filename.";
        CV_Error(CV_StsBadArg, error_message);
    }

    string line, path, classlabel;
    while (getline(file, line)) 
	{
        stringstream liness(line);
        getline(liness, path, separator);
        getline(liness, classlabel);

        if(!path.empty() && !classlabel.empty()) 
		{
            images.push_back(imread(path, 0));
            labels.push_back(atoi(classlabel.c_str()));
        }
    }
}

/*
////////////////////////////
//// parse DB.csv ////
////////////////////////////
class CSVRow
{
    public:
        string const& operator[](size_t index) const
        {
            return m_data[index];
        }
        size_t size() const
        {
            return m_data.size();
        }
        void readNextRow(istream& str)
        {
            string         line;
            getline(str,line);
            stringstream   lineStream(line);
            string         cell;
            m_data.clear();
            while(getline(lineStream,cell,','))
            {
                m_data.push_back(cell);
            }
        }
    private:
        vector<string>    m_data;
};
istream& operator>>(istream& str,CSVRow& data)
{
    data.readNextRow(str);
    return str;
}
*/

void loadCsv(Mat& matData, string path)
{
	CvMLData mlData;
	mlData.read_csv(path.c_str());
	const CvMat* tmp = mlData.get_values();
	matData = Mat(tmp, true); // data type: CV_32FC1 (float)
}

////////////
enum{_COL,_ROW};
void covMat(Mat& samples, Mat& covar, Mat& mean, int option)
{
	if (option == _ROW) {

		calcCovarMatrix(samples, covar, mean, CV_COVAR_NORMAL | CV_COVAR_ROWS);
		covar = covar/(samples.rows - 1);
	}
	else if (option == _COL) {

		calcCovarMatrix(samples, covar, mean, CV_COVAR_NORMAL | CV_COVAR_COLS);
		covar = covar/(samples.cols - 1);
	}
}

void vectorMat2Mat(vector<Mat>& A, Mat& B)
{
	for (int i = 0; i < A.size(); i++)
	{
		B.push_back(A.at(i));
	}
}

string type2str(int type) {
  string r;

  uchar depth = type & CV_MAT_DEPTH_MASK;
  uchar chans = 1 + (type >> CV_CN_SHIFT);

  switch ( depth ) {
    case CV_8U:  r = "8U"; break;
    case CV_8S:  r = "8S"; break;
    case CV_16U: r = "16U"; break;
    case CV_16S: r = "16S"; break;
    case CV_32S: r = "32S"; break;
    case CV_32F: r = "32F"; break;
    case CV_64F: r = "64F"; break;
    default:     r = "User"; break;
  }

  r += "C";
  r += (chans+'0');

  return r;
}
  //////////////
 //// main ////
//////////////
int main(int argc, const char *argv[])
{
	clock_t start;
	float duration;

    // Check for valid command line arguments, print usage
    // if no arguments were given.
//    if (argc < 2) 
//	{
//        cout << "usage: " << argv[0] << " <csv.ext> <output_folder> " << endl;
//        exit(1);
//    }

    string output_folder = ".";

	/// 545-5/1106, hiroshi: add input arguments
	argv[1] = ".../att_face_index.csv";
	//argv[2] = "output";
	argc = 2;

    if (argc == 3) 
	{
        output_folder = string(argv[2]);
    }
    // Get the path to your CSV.
    string fn_csv = string(argv[1]);
    // These vectors hold the images and corresponding labels.
    vector<Mat> images;
    vector<int> labels;

    // Read in the data. This can fail if no valid
    // input filename is given.
    try 
	{
        read_csv(fn_csv, images, labels);
    } 
	catch (cv::Exception& e) 
	{
        cerr << "Error opening file \"" << fn_csv << "\". Reason: " << e.msg << endl;
        // nothing more we can do
        exit(1);
    }

    // Quit if there are not enough images for this demo.
    if(images.size() <= 1) 
	{
        string error_message = "This demo needs at least 2 images to work. Please add more images to your data set!";
        CV_Error(CV_StsError, error_message);
    }

    // Get the height from the first image. We'll need this
    // later in code to reshape the images to their original
    // size:
    int height = images[0].rows;
    int width = images[0].cols;

/*
    // The following lines simply get the last images from
    // your dataset and remove it from the vector. This is
    // done, so that the training data (which we learn the
    // cv::FaceRecognizer on) and the test data we test
    // the model with, do not overlap.
    Mat testSample = images[images.size() - 1];
    int testLabel = labels[labels.size() - 1];
    images.pop_back();
    labels.pop_back();
*/

	// The following lines create an Eigenfaces model for
    // face recognition and train it with the images and
    // labels read from the given CSV file.
    // This here is a full PCA, if you just want to keep
    // 10 principal components (read Eigenfaces), then call
    // the factory method like this:
    //
    //      cv::createEigenFaceRecognizer(10);
    //
    // If you want to create a FaceRecognizer with a
    // confidence threshold (e.g. 123.0), call it with:
    //
    //      cv::createEigenFaceRecognizer(10, 123.0);
    //
    // If you want to use _all_ Eigenfaces and have a threshold,
    // then call the method like this:
    //
    //      cv::createEigenFaceRecognizer(0, 123.0);
    //
	int num_components = 20; // how many eigen-vectors we need
    Ptr<FaceRecognizer> model;

	bool _train = false;

	if (_train)
	{
		if (num_components > 0)
			model = createEigenFaceRecognizer(num_components);
		else
			model = createEigenFaceRecognizer();
	
		// train model
		start = clock();
		model->train(images, labels);
		duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
		cout<<endl<<"training time: "<<duration<<endl;
	
		start = clock();
		model->save("eigenfaces_at.yml");
		duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
		cout<<endl<<"save .yml time: "<<duration<<endl;
	}
	else
	{
		start = clock();
		model = createEigenFaceRecognizer();
		model->load("eigenfaces_at.yml");
		duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
		cout<<endl<<"load .yml time: "<<duration<<endl;
	}

	// Here is how to get the eigenvalues of this Eigenfaces model:
//    Mat eigenvalues = model->getMat("eigenvalues");
    Mat W = model->getMat("eigenvectors");
    Mat mean = model->getMat("mean");
	vector<Mat> projs = model->getMatVector("projections");
	Mat projections;
	start = clock();
	vectorMat2Mat(projs, projections);
	duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
	cout<<endl<<"vectorMat to Mat time: "<<duration<<endl;

	Mat evs;
	if (num_components > 0)
		evs = Mat(W, Range::all(), Range(0, num_components));
	else
		evs = W;

	// 548.1.1123.hiroshi: calculate covariance matrix
	Mat cov, projmean, invcov;
	covMat(projections, cov, projmean, _ROW);
	cout<<endl<<determinant(cov);
	invcov = cov.inv(DECOMP_CHOLESKY);

/*
	// 547-2 1117 hiroshi: save trained data into .csv
	 /////////////////
	//// save DB ////
	start = clock();
	ofstream file_0("projections.csv");
	file_0 << format(projections, "CSV") << endl;
	file_0.close();
	ofstream file_1("mean.csv");
	file_1 << format(mean, "CSV") << endl;
	file_1.close();
	ofstream file_2("evs.csv");
	file_2 << format(evs, "CSV") << endl;
	file_2.close();
	duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
	cout<<endl<<"saving .csv time: "<<duration<<endl;
	//547.4.1119.hiroshi: parse saved DB (mean.csv & ev.csv)
	/////////////////
	//// load DB ////
	start = clock();
	Mat mean_mat, ev_mat, proj_mat;
	loadCsv(mean_mat, "mean.csv");
//	mean.convertTo(mean, CV_32FC1);
	loadCsv(ev_mat, "evs.csv");
	loadCsv(proj_mat, "projections.csv");
	duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
	cout<<endl<<"reading .csv time: "<<duration<<endl;
*/
	/*
		// reconstruction by projection & eigenvector
	    Mat reconstruction = subspaceReconstruct(evs, mean, projection.row(0));
        // Normalize the result:
        reconstruction = norm_0_255(reconstruction.reshape(1, images[0].rows));
        // Display or save:
        imshow(format("eigenface_reconstruction_%d", num_components), reconstruction);
	*/



	// 547-4-1119-hiroshi: take my own pic as source image
	Mat testSample = imread(".../face_database/jack/19131_1078086809441_8213360_n.jpg", CV_LOAD_IMAGE_COLOR);

	// 547-4-1119-hiroshi: add face detection on a given sourve image
	face_cascade.load(face_cascade_name);

	// 547-4-1119-hiroshi: detect, image pre-proc, and face recog.
	Mat testGray = testSample.clone();
	cvtColor(testGray, testGray, CV_BGR2GRAY);
	vector< Rect_<int> > faces;
	face_cascade.detectMultiScale(testGray, faces);

	for (int i = 0; i < faces.size(); i++)
	{
		Rect face_i = faces[i];
		Mat face = testGray(face_i);

		Mat face_resized;
		resize(face, face_resized, Size(width, height), 1.0, 1.0, INTER_CUBIC);
		equalizeHist(face_resized, face_resized);

		// The following line predicts the label of a given
		// test image:
		int prediction = model->predict(face_resized);
		//
		// To get the confidence of a prediction call the model with:
		//
		//      int predictedLabel = -1;
		//      double confidence = 0.0;
		//      model->predict(testSample, predictedLabel, confidence);
		//
		// 547.5.1120.hiroshi: my own face recognizing judgment here
		 ////////////////////
		//// myJudgment ////
		Mat testFace_projection = subspaceProject(evs, mean, face_resized.reshape(1,1));

		start = clock();
		float DIS(10000), MDIS(10000), SIM(0);
		int iDIS(0), iMDIS(0), iSIM(0);
		int iiDIS(0), iiMDIS(0), iiSIM(0);
		for (int i = 0; i < images.size(); i++)
		{
			float dis = norm(testFace_projection, projections.row(i), NORM_L2);
			float mdis = Mahalanobis(testFace_projection, projections.row(i), invcov);
			float sim = testFace_projection.dot(projections.row(i))/(norm(testFace_projection)*norm(projections));

			if (dis < DIS) {

				DIS = dis;
				iiDIS = iDIS;
				iDIS = i;
			}
			if (mdis < MDIS) {

				MDIS = mdis;
				iiMDIS = iMDIS;
				iMDIS = i;
			}
			if (sim > SIM) {

				SIM = sim;
				iiSIM = iSIM;
				iSIM = i;
			}
//			cout<<endl<<"dis: "<<dis<<endl<<"m-dis: "<<mdis<<endl<<"sim: "<<sim<<endl;
		}
		duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
		cout<<endl<<"judge time: "<<duration<<endl;


		cout<<endl<<"DIS: "<<DIS<<endl<<"MDIS: "<<MDIS<<endl<<"SIM: "<<SIM<<endl;
		cout<<endl<<"iDIS: "<<iDIS<<endl<<"iMDIS: "<<iMDIS<<endl<<"iSIM: "<<iSIM<<endl;
		cout<<endl<<"iiDIS: "<<iiDIS<<endl<<"iiMDIS: "<<iiMDIS<<endl<<"iiSIM: "<<iiSIM<<endl;
		cout<<endl<<"label(iDIS): "<<labels[iDIS]<<endl<<"label(iMDIS): "<<labels[iMDIS]<<endl<<"label(iSIM): "<<labels[iSIM]<<endl;
		cout<<endl<<"label(iiDIS): "<<labels[iiDIS]<<endl<<"label(iiMDIS): "<<labels[iiMDIS]<<endl<<"label(iiSIM): "<<labels[iiSIM]<<endl;


    
		// draw detected-face rect
		rectangle(testSample, face_i, CV_RGB(0,255,0), 1);
		string box_text = format("Prediction = %d", prediction);

		int pos_x = max(face_i.tl().x - 10, 0);
		int pos_y = max(face_i.tl().y - 10, 0);

		putText(testSample, 
				box_text, 
				Point(pos_x, pos_y), 
				FONT_HERSHEY_PLAIN, 
				1.0, 
				CV_RGB(0,255,0), 
				2.0);
	}

	imshow("facerec", testSample);


    // Display if we are not writing to an output folder:
    if(argc == 2) 
	{
        waitKey(0);
    }

	while(1)
	{
        char key = (char) waitKey(20);
        // Exit this loop on escape:
        if(key == 27)
            break;
	}

	return 0;
}
