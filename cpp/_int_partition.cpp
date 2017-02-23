// _partition.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <windows.h>
using namespace std;

unsigned int p(int, int, int*, int);

int _tmain(int argc, _TCHAR* argv[])
{
	const int len = 123;
/*
	int num[len+1] = {1};

	for (int i = 1; i <= len; ++i)
	{
		for (int j = i; j <= len; ++j)
			num[j] += num[j - i];
	}

	for (int i = 0; i <= len; i++)
		cout<<endl<< i <<' '<<num[i]<<endl;
*/

	int* M = new int[(len+1)*(len+1)];
	for (int i = 0; i <= len; i++)
	{
		for (int j = 0; j <= len; j++)
//			M[i*(len+1)+j] = -1;
			*((M + i*(len+1)) + j) = -1;
	}
	cout<<endl<< p(len, len, M, len) <<endl;
	Sleep(3000);
	delete [] M;
	return 0;
}

unsigned int p(int n, int m, int* M, int len)
{
	if (n < 0)
		return 0;

	// memoization
	if (*(M + n*(len+1) + m) != -1)
		return *(M + n*(len+1) + m);
	// update table
	else
	{
		if (n == m)
			*(M + n*(len+1) + m) = 1 + p(n, m - 1, M, len);
		else if (m == 0 || n < 0)
			*(M + n*(len+1) + m) = 0;
		else if (n == 0 || m == 1)
			*(M + n*(len+1) + m) = 1;
		else
			*(M + n*(len+1) + m) = p(n - m, m, M, len) + p(n, m - 1, M, len);
	}

	return *(M + n*(len+1) + m);
}

