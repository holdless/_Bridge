#include "stdafx.h"
#include "numcpp.h"
#include <string>
using namespace std;

DislinPlot::DislinPlot() {
	_refcnt = 0;
	_dislin.metafl("cons");
	//	g.metafl("xwin");
	//	g.metafl("virt");
	setWindow(1920, 1080, 0.5, 0.7);
	//	g.winsiz(800, 600); 	
	_dislin.scrmod("revers");
	_dislin.disini();
	_dislin.pagera();
	_dislin.complx();

	setAxisLen(1500, 1000);
	setAxisPos(500, 1600);

	setAxisName("X-axis", "Y-axis");
	setAxisOffset(-1, 0);
	setTicks(9, 10);
	setTitle("Demo of CURVE", "sin(x), cos(x)");
	setIntRgb(0.95, 0.95, 0.95);

//	setGraf(0.0, 360, 0.0, 90.0, -1.0, 1.0, -1.0, 0.5);
//	setGrid(1, 1);
//	setRgb(.7, .7, .7);
	_axis.start.x = 0.0;
	_axis.end.x = 360.0;
	_axis.org.x = 0.0;
	_axis.step.x = 90.0;
	_axis.start.y = -1.0;
	_axis.end.y = 1.0;
	_axis.org.y = -1.0;
	_axis.step.y = 0.5;
	_axis.grid.x = 1;
	_axis.grid.y = 1;
	_axis.rgb.r = .7;
	_axis.rgb.g = .7;
	_axis.rgb.b = .7;

//	_dislin.graf(0.0, 360, 0.0, 90.0, -1.0, 1.0, -1.0, 0.5);
//	_dislin.grid(1, 1);
//	_dislin.setrgb(.7, .7, .7);

	setColor("fore");
	setHeight(50);


	// marker
	_curve.marker.interval = 0;
	_curve.marker.type = 0;
	_curve.marker.color = -1;
	_curve.marker.size = 10;// default in dislin:35

}

DislinPlot::~DislinPlot() {
	if (_refcnt > 1) {
		delete[] _curve.xdata;
		delete[] _curve.ydata;
	}
	// my guess is that the "dislin" fini function has already handled this...
}

Numcpp::Numcpp() {
	_name = "numpy in c++";
}

Numcpp::Numcpp(const char *name) {
	_name = name;
}

Numcpp::Numcpp(string &name) {
	_name = name;
}

string Numcpp::getName() {
	return _name;
}

vector<float> Numcpp::linspace(float start, float end, float num) {

	float delta = (end - start) / (num - 1);

	vector<float> linspaced(num - 1);
	for (int i = 0; i < num - 1; ++i)
	{
		linspaced[i] = start + delta * i;
	}
	linspaced.push_back(end);
	return linspaced;
}

vector<float> Numcpp::nlinspace(float start, float end, float interval,
	float mean, float stddev) {

	vector<float> linVec = linspace(start, end, interval);
	vector<float> randnVec = randn_vec(mean, stddev, linVec.size());
	return vec_add(linVec, randnVec);
}

void Numcpp::print_vector(vector<float> vec) {
	for (float d : vec)
		std::cout << d << " ";
	std::cout << std::endl;
}

float Numcpp::randn(float mean, float stddev) {
	std::normal_distribution<float> dist(mean, stddev);
	return dist(generator);
}

vector<float> Numcpp::randn_vec(float mean, float stddev, int num) {
	std::normal_distribution<float> dist(mean, stddev);
	vector<float> randnVec(num);
	for (int i = 0; i < num; i++)
		randnVec[i] = dist(generator);

	return randnVec;
}

vector<float> Numcpp::vec_add(vector<float>a, vector<float>b) {
	vector<float> ret(a.size());
	for (int i = 0; i < a.size(); i++)
		ret[i] = a[i] + b[i];
	return ret;
}

