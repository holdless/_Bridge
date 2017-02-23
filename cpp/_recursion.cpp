// _test_recursion.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <windows.h>
using namespace std;

int sumr(int n);
int _tmain(int argc, _TCHAR* argv[])
{
	int a = sumr(100);
	cout<<endl<<a<<endl;
	Sleep(1000);
	return 0;
}

int sumr(int n)
{
	return (n<=0)? 0:(n + sumr(n-1));
}


