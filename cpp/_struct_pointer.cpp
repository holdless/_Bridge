// _struct_pointer.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <windows.h>
using namespace std;

struct Ball {
	char color[10];
	double radius;
};

typedef struct Ball CBall;

int _tmain(int argc, _TCHAR* argv[])
{
	CBall ball1 = {"red", 4.0};
	CBall ball2 = {"green", 5.0};
	CBall *pBall = &ball2;
	cout<<endl<<"color: "<<ball1.color<<endl;
	cout<<endl<<"radius: "<<ball1.radius<<endl;
	cout<<endl;
	cout<<endl<<"ptr-color: "<<pBall->color<<endl;
	cout<<endl<<"ptr-radius: "<<pBall->radius<<endl;
	cout<<endl;
	CBall *pNewBall = &ball1;
	*(pNewBall->color+1) = 'y';
	pNewBall->radius = 10.0;
	cout<<endl<<"new ptr-color: "<<ball1.color<<endl;
	cout<<endl<<"new ptr-radius: "<<ball1.radius<<endl;
	Sleep(2000);
	return 0;
}

