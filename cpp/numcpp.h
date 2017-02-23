#pragma once
#include "stdafx.h"
#include <iostream>
#include <vector>
#include <string>
#include <random>
// dislin
#include "D:/dislin/discpp.h"
#include <cmath>
// VLA (variable-length argument)
#include <stdio.h>
#include <stdarg.h>

using namespace std;

struct dCoordinate {
	double x;
	double y;
};

struct iCoordinate {
	int x;
	int y;
};

struct RGB {
	double r;
	double g;
	double b;
};


struct Axis {
	dCoordinate start;
	dCoordinate end;
	dCoordinate org;
	dCoordinate step;

	iCoordinate grid;
	iCoordinate offset;
	RGB rgb;
};

struct Title {
	char* mTitle;
	char* sTitle;
};

struct Marker {
	int interval; // incmrk(int nmrk)
				  //	NMRK = -n	means that CURVE plots only symbols.Every n - th point will be marked by a symbol.
				  //	NMRK = 0	means that CURVE connects points with lines.
				  //	NMRK = n	means that CURVE plots lines and marks every n - th point with a symbol.Default: NMRK = 0
	int type; // marker (int nsym)
			  //  NSYM	is the symbol number between - 1 and 21. The value - 1 means that the symbol is not plotted in routines such as CURVE and ERRBAR.The symbols are shown in appendix B.Default: NSYM = 0
	int color; // mrclr(int nclr)
			   //  NCLR	is a colour value.If NCLR = -1, the current colour is selected for symbols in curves.
			   //	Default: NCLR = -1
	int size; // hsymbl(int nhsym)
			  //  NHSYM	is the size of symbols in plot coordinates.Default: NHSYM = 35
};

struct Curve {
	Marker marker;
	int dataLen;
	double* xdata;
	double* ydata;
};

class DislinPlot {
public:
	DislinPlot();
	~DislinPlot();

	// disline property setter
	// very init (usually not change...)
	void setWindow(int screenSizeX, int screenSizeY, float scalex, float scaley) {
		_dislin.window(0, 0, scalex*screenSizeX, scaley*screenSizeY); // 1920x1080
	}
	void setAxisName(char* namex, char* namey) {
		_dislin.name(namex, "x");
		_dislin.name(namey, "y");
	}
	void setAxisOffset(int offsetx, int offsety) {
		_dislin.labdig(offsetx, "x");
		_dislin.labdig(offsety, "y");
	}
	void setAxisLen(int lenx, int leny) {
		_dislin.axslen(lenx, leny);
	}
	void setAxisPos(int posx, int posy) {
		_dislin.axspos(posx, posy);
	}
	void setIntRgb(double r, double g, double b) {
		_dislin.axsbgd(_dislin.intrgb(r, g, b));
	}

	// set axis
	void setTicks(int tickx, int ticky) {
		_dislin.ticks(tickx, "x");
		_dislin.ticks(ticky, "y");
	}// how many ticks per step in each axis.
	void setGraf(double startx,
		double endx,
		double orgx,
		double stepx,
		double starty,
		double endy,
		double orgy,
		double stepy) {
		_axis.start.x = startx;
		_axis.end.x = endx;
		_axis.org.x = orgx;
		_axis.step.x = stepx;
		_axis.start.y = starty;
		_axis.end.y = endy;
		_axis.org.y = orgy;
		_axis.step.y = stepy;

	}
	void setGrid(int gridx, int gridy) {
		_axis.grid.x = gridx;
		_axis.grid.y = gridy;
	}
	void setRgb(double r, double g, double b) {
		_axis.rgb.r = r;
		_axis.rgb.g = g;
		_axis.rgb.b = b;
	}
	void initAxis() {
		_dislin.graf(_axis.start.x, _axis.end.x, _axis.org.x, _axis.step.x,
			_axis.start.y, _axis.end.y, _axis.org.y, _axis.step.y);
		_dislin.grid(_axis.grid.x, _axis.grid.y);
		_dislin.setrgb(_axis.rgb.r, _axis.rgb.g, _axis.rgb.b);

	}

	// set title
	void setTitle(char* mtitle, char* stitle) {
		_title.mTitle = mtitle;
		_title.sTitle = stitle;
	}
	void initTitle() {
		_dislin.titlin(_title.mTitle, 1);
		_dislin.titlin(_title.sTitle, 3);
		_dislin.title();
	}

	// set curve
	void setData(int len, double* xdata, double* ydata) {
		_curve.dataLen = len;
		_curve.xdata = xdata;
		_curve.ydata = ydata;
	}
	void setVecData(int len, vector<float> xdata, vector<float> ydata) {
		_curve.dataLen = len;
		_curve.xdata = new double[len];
		_curve.ydata = new double[len];
		for (int i = 0; i < len; i++) {
			_curve.xdata[i] = xdata[i];
			_curve.ydata[i] = ydata[i];
		}
		_refcnt++;
	}

	// marker
	void setMarker(int nmrk, int nsym, int nclr, int nhsym) {
		_curve.marker.interval = nmrk; //0
		_curve.marker.type = nsym; //0
		_curve.marker.color = nclr; //-1
		_curve.marker.size = nhsym; //35
	}
	void setMarkerInterval(int interval) {
		_curve.marker.interval = interval;
	}
	void setMarkerType(int type) {
		if (_curve.marker.interval == 0)
			_curve.marker.interval = 1;
		_curve.marker.type = type;
	}
	void setMarkerColor(int color) {
		if (_curve.marker.interval == 0)
			_curve.marker.interval = 1;
		_curve.marker.color = color;
	}
	void setMarkerSize(int size) {
		if (_curve.marker.interval == 0)
			_curve.marker.interval = 1;
		_curve.marker.size = size;
	}

	void initCurve() {
		_dislin.incmrk(_curve.marker.interval);
		_dislin.marker(_curve.marker.type);
		_dislin.mrkclr(_curve.marker.color);
		_dislin.hsymbl(_curve.marker.size);
	}

	// other setting
	void setHeight(int height) {
		_dislin.height(height);
	}
	void setColor(char* color) {
		_dislin.color(color);
	}

	// plotting...............
	void plotCurve() {
		initCurve();
		_dislin.curve(_curve.xdata, _curve.ydata, _curve.dataLen);
//		_dislin.qplot(_xdata, _ydata, _dataLength);
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
	void plot(int len, ...) {
		va_list args;
		va_start(args, len);

		char* type = va_arg(args, char*);
		_curve.dataLen = va_arg(args, int);

		_curve.xdata = va_arg(args, double*);
		_curve.ydata = va_arg(args, double*);

		if (len >= 5)
			setColor(va_arg(args, char*));
		if (len >= 6)
			_curve.marker.interval = va_arg(args, int);
		if (len >= 7)
			_curve.marker.type = va_arg(args, int);
		if (len >= 8)
			_curve.marker.color = va_arg(args, int);
		if (len >= 9)
			_curve.marker.size = va_arg(args, int);

		if (!strcmp(type, "curve"))
			plotCurve();

		va_end(args);
	}
	void render() {
		_dislin.disfin();
		//		Curve::~Curve();
	}

private:
	// plot properties
	Dislin _dislin;
	Axis _axis;
	Title _title;
	Curve _curve;

	int _refcnt;
};

class Numcpp {

public:
	Numcpp(); // an object, like general toolkit
	Numcpp(const char*);
	Numcpp(string&);

	vector<float> linspace(float start, float end, float interval);
	vector<float> nlinspace(float start, float end, float interval, float mean, float stddev);
	void print_vector(vector<float>);
	float randn(float mean, float stddev);
	vector<float> randn_vec(float mean, float stddev, int num);
	vector<float> vec_add(vector<float>, vector<float>);
	string getName();

private:
	string _name;
	std::default_random_engine generator;
};

#pragma once
#include "stdafx.h"
#include <iostream>
#include <vector>
#include <string>
#include <random>
// dislin
#include "D:/dislin/discpp.h"
#include <cmath>
// VLA (variable-length argument)
#include <stdio.h>
#include <stdarg.h>

using namespace std;

struct dCoordinate {
	double x;
	double y;
};

struct iCoordinate {
	int x;
	int y;
};

struct RGB {
	double r;
	double g;
	double b;
};


struct Axis {
	dCoordinate start;
	dCoordinate end;
	dCoordinate org;
	dCoordinate step;

	iCoordinate grid;
	iCoordinate offset;
	RGB rgb;
};

struct Title {
	char* mTitle;
	char* sTitle;
};

struct Marker {
	int interval; // incmrk(int nmrk)
				  //	NMRK = -n	means that CURVE plots only symbols.Every n - th point will be marked by a symbol.
				  //	NMRK = 0	means that CURVE connects points with lines.
				  //	NMRK = n	means that CURVE plots lines and marks every n - th point with a symbol.Default: NMRK = 0
	int type; // marker (int nsym)
			  //  NSYM	is the symbol number between - 1 and 21. The value - 1 means that the symbol is not plotted in routines such as CURVE and ERRBAR.The symbols are shown in appendix B.Default: NSYM = 0
	int color; // mrclr(int nclr)
			   //  NCLR	is a colour value.If NCLR = -1, the current colour is selected for symbols in curves.
			   //	Default: NCLR = -1
	int size; // hsymbl(int nhsym)
			  //  NHSYM	is the size of symbols in plot coordinates.Default: NHSYM = 35
};

struct Curve {
	Marker marker;
	int dataLen;
	double* xdata;
	double* ydata;
};

class DislinPlot {
public:
	DislinPlot();
	~DislinPlot();

	// disline property setter
	// very init (usually not change...)
	void setWindow(int screenSizeX, int screenSizeY, float scalex, float scaley) {
		_dislin.window(0, 0, scalex*screenSizeX, scaley*screenSizeY); // 1920x1080
	}
	void setAxisName(char* namex, char* namey) {
		_dislin.name(namex, "x");
		_dislin.name(namey, "y");
	}
	void setAxisOffset(int offsetx, int offsety) {
		_dislin.labdig(offsetx, "x");
		_dislin.labdig(offsety, "y");
	}
	void setAxisLen(int lenx, int leny) {
		_dislin.axslen(lenx, leny);
	}
	void setAxisPos(int posx, int posy) {
		_dislin.axspos(posx, posy);
	}
	void setIntRgb(double r, double g, double b) {
		_dislin.axsbgd(_dislin.intrgb(r, g, b));
	}

	// set axis
	void setTicks(int tickx, int ticky) {
		_dislin.ticks(tickx, "x");
		_dislin.ticks(ticky, "y");
	}// how many ticks per step in each axis.
	void setGraf(double startx,
		double endx,
		double orgx,
		double stepx,
		double starty,
		double endy,
		double orgy,
		double stepy) {
		_axis.start.x = startx;
		_axis.end.x = endx;
		_axis.org.x = orgx;
		_axis.step.x = stepx;
		_axis.start.y = starty;
		_axis.end.y = endy;
		_axis.org.y = orgy;
		_axis.step.y = stepy;

	}
	void setGrid(int gridx, int gridy) {
		_axis.grid.x = gridx;
		_axis.grid.y = gridy;
	}
	void setRgb(double r, double g, double b) {
		_axis.rgb.r = r;
		_axis.rgb.g = g;
		_axis.rgb.b = b;
	}
	void initAxis() {
		_dislin.graf(_axis.start.x, _axis.end.x, _axis.org.x, _axis.step.x,
			_axis.start.y, _axis.end.y, _axis.org.y, _axis.step.y);
		_dislin.grid(_axis.grid.x, _axis.grid.y);
		_dislin.setrgb(_axis.rgb.r, _axis.rgb.g, _axis.rgb.b);

	}

	// set title
	void setTitle(char* mtitle, char* stitle) {
		_title.mTitle = mtitle;
		_title.sTitle = stitle;
	}
	void initTitle() {
		_dislin.titlin(_title.mTitle, 1);
		_dislin.titlin(_title.sTitle, 3);
		_dislin.title();
	}

	// set curve
	void setData(int len, double* xdata, double* ydata) {
		_curve.dataLen = len;
		_curve.xdata = xdata;
		_curve.ydata = ydata;
	}
	void setVecData(int len, vector<float> xdata, vector<float> ydata) {
		_curve.dataLen = len;
		_curve.xdata = new double[len];
		_curve.ydata = new double[len];
		for (int i = 0; i < len; i++) {
			_curve.xdata[i] = xdata[i];
			_curve.ydata[i] = ydata[i];
		}
		_refcnt++;
	}

	// marker
	void setMarker(int nmrk, int nsym, int nclr, int nhsym) {
		_curve.marker.interval = nmrk; //0
		_curve.marker.type = nsym; //0
		_curve.marker.color = nclr; //-1
		_curve.marker.size = nhsym; //35
	}
	void setMarkerInterval(int interval) {
		_curve.marker.interval = interval;
	}
	void setMarkerType(int type) {
		if (_curve.marker.interval == 0)
			_curve.marker.interval = 1;
		_curve.marker.type = type;
	}
	void setMarkerColor(int color) {
		if (_curve.marker.interval == 0)
			_curve.marker.interval = 1;
		_curve.marker.color = color;
	}
	void setMarkerSize(int size) {
		if (_curve.marker.interval == 0)
			_curve.marker.interval = 1;
		_curve.marker.size = size;
	}

	void initCurve() {
		_dislin.incmrk(_curve.marker.interval);
		_dislin.marker(_curve.marker.type);
		_dislin.mrkclr(_curve.marker.color);
		_dislin.hsymbl(_curve.marker.size);
	}

	// other setting
	void setHeight(int height) {
		_dislin.height(height);
	}
	void setColor(char* color) {
		_dislin.color(color);
	}

	// plotting...............
	void plotCurve() {
		initCurve();
		_dislin.curve(_curve.xdata, _curve.ydata, _curve.dataLen);
//		_dislin.qplot(_xdata, _ydata, _dataLength);
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
	void plot(int len, ...) {
		va_list args;
		va_start(args, len);

		char* type = va_arg(args, char*);
		_curve.dataLen = va_arg(args, int);

		_curve.xdata = va_arg(args, double*);
		_curve.ydata = va_arg(args, double*);

		if (len >= 5)
			setColor(va_arg(args, char*));
		if (len >= 6)
			_curve.marker.interval = va_arg(args, int);
		if (len >= 7)
			_curve.marker.type = va_arg(args, int);
		if (len >= 8)
			_curve.marker.color = va_arg(args, int);
		if (len >= 9)
			_curve.marker.size = va_arg(args, int);

		if (!strcmp(type, "curve"))
			plotCurve();

		va_end(args);
	}
	void render() {
		_dislin.disfin();
		//		Curve::~Curve();
	}

private:
	// plot properties
	Dislin _dislin;
	Axis _axis;
	Title _title;
	Curve _curve;

	int _refcnt;
};

class Numcpp {

public:
	Numcpp(); // an object, like general toolkit
	Numcpp(const char*);
	Numcpp(string&);

	vector<float> linspace(float start, float end, float interval);
	vector<float> nlinspace(float start, float end, float interval, float mean, float stddev);
	void print_vector(vector<float>);
	float randn(float mean, float stddev);
	vector<float> randn_vec(float mean, float stddev, int num);
	vector<float> vec_add(vector<float>, vector<float>);
	string getName();

private:
	string _name;
	std::default_random_engine generator;
};

