// _memcpy_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "memory.h"
#include <string.h>
#include <windows.h>


int _tmain(int argc, _TCHAR* argv[])
{
	char *str1 ="Sample string";
	char str2[40];
	char *str4 = (char *)malloc(40);
	printf ("size of str1: %d\n",sizeof(str1)/sizeof(char));
	memcpy (str2,str1,strlen(str1)+1);
	memcpy (str4,str1,strlen(str1)+1);
	printf ("str1 length: %d\n", strlen(str1));
	printf ("str1: %s\nstr2: %s\n",str1,str2);
	printf ("size of str2: %d\n",sizeof(str2)/sizeof(char));
	printf ("str4: %s\n",str4);
	printf ("size of str4: %d\n",sizeof(str4)/sizeof(char));
	Sleep(2000);
	free(str4);
	return 0;
}

