// Math_Utilities.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "numcpp.h"
#include <iostream>
// gnuplot
#include "gnuplot.h"
// dislin
#include "D:/dislin/discpp.h"
#include <cmath>

using namespace std;


int main()
{
	Numcpp np;

	cout << endl << np.getName() << endl<<endl;
	// example: linspace
	vector<float> linVector = np.linspace(1, 10, 10);
	np.print_vector(linVector);

	// example: randn 
	cout<<endl<<np.randn(0, .2)<<endl;

	// example: randn_vec
	vector<float> randnVec = np.randn_vec(0, .2, 10);
	np.print_vector(randnVec);

	// example: linspace + randnVec
	vector<float> noisyVec = np.vec_add(linVector, randnVec);
	np.print_vector(noisyVec);
	vector<float> nLinVec = np.nlinspace(1,10,10,0,.2);
	np.print_vector(nLinVec);

	// gnuplot
/*	Gnuplot plot;
	plot("plot sin(x)");
//	system("pause");
	plot("plot cos(x)");
//	system("pause");
*/
	// dislin plot
	int n = 100, i, ic;
	double fpi = 3.1415926 / 180.0, step, x;
	double xxray[100], yy1ray[100], yy2ray[100];
	double *xray, *y1ray, *y2ray;
	xray = xxray;
	y1ray = yy1ray;
	y2ray = yy2ray;

	step = 360. / (n - 1);

	for (i = 0; i < n; i++)
	{
		xray[i] = i * step;
		x = xray[i] * fpi;
		y1ray[i] = sin(x);
		y2ray[i] = cos(x);
/*		*(xray + i) = i * step;
		x = *(xray + i) * fpi;
		*(y1ray + i) = sin(x);
		*(y2ray + i) = cos(x);
		*/
	}

// char*	type, 
// double*	xdata, 
// double*	ydata, 
// int		dataLength, 
// char*	color, 
// int		markerInterval 
// int		markerType 
// int		markerColor 
// int		markerSize 
	DislinPlot myPlot;
	// set axis first
	myPlot.setGraf(0.0, 360, 0.0, 90.0, -1.0, 1.0, -1.0, 0.5);
	myPlot.initAxis();

	// set title
	myPlot.setTitle("my title", "my subtitle");
	myPlot.setHeight(50); // not necessary
	myPlot.setColor("fore");
	myPlot.initTitle();

	// set curve
	myPlot.setMarkerSize(20);
	myPlot.setData(n, xray, y1ray);
	myPlot.setColor("red"); // not necessary
	myPlot.plotCurve();
//	myPlot.plot(5, "curve", n, xray, y1ray, "red");

//	myPlot.setMarkerSize(40);
	myPlot.setData(n, xray, y2ray);
	myPlot.setColor("green"); // not necessary
	myPlot.plotCurve();
//	myPlot.plot(5, "curve", n, xray, y2ray, "green");


	myPlot.render();

	return 0;
}

