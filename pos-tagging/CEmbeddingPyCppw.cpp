// c_embedding_py.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"


#define MS_NO_COREDLL
// Since Python may define some pre-processor definitions which affect the standard headers
// on some systems, you must include Python.h before any standard headers are included.
#include <Python.h>

//#include <stdlib.h>
//#include <stdio.h>
//#include <iostream>
#include <Windows.h>

using namespace std;

int main(int argc, char* argv[])
{
/*
	Py_SetProgramName(argv[0]);  
	Py_Initialize();
//	FILE* file = fopen("_pos_tagging.py", "r");
//	PyRun_SimpleFile(file, "_pos_tagging.py");
	PyObject* pyFileObj = PyFile_FromString("D:/Python27/_py/_pos_tagging.py", "r");
	PyRun_SimpleFile(PyFile_AsFile(pyFileObj), "D:/Python27/_py/_pos_tagging.py", 1);
	Py_Finalize();
	return 0;	  
*/

    PyObject *pName, *pModule, *pDict, *pFunc;
    PyObject *pArgs, *pValue;
    int i;

    Py_SetProgramName(argv[0]);
    Py_Initialize();

	PySys_SetArgv(argc, argv);
    pName = PyString_FromString("test");
    /* Error checking of pName left out */

    pModule = PyImport_Import(pName);
    Py_DECREF(pName);

    if (pModule != NULL) 
	{
        pFunc = PyObject_GetAttrString(pModule, "mySum");
        /* pFunc is a new reference */

        if (pFunc && PyCallable_Check(pFunc)) 
		{
			int input[2] = {299, -10};
            pArgs = PyTuple_New(2);

            for (i = 0; i < 2; i++) 
			{
                pValue = PyInt_FromLong(input[i]);
//                pValue = PyString_FromString(argv[i + 3]);
                if (!pValue) 
				{
                    Py_DECREF(pArgs);
                    Py_DECREF(pModule);
                    fprintf(stderr, "Cannot convert argument\n");
                    return 1;
                }
                // pValue reference stolen here:
                PyTuple_SetItem(pArgs, i, pValue);
            }

            pValue = PyObject_CallObject(pFunc, pArgs);
            Py_DECREF(pArgs);

            if (pValue != NULL) 
			{
                printf("Result of call: %ld\n", PyInt_AsLong(pValue));
                Py_DECREF(pValue);
            }
            else 
			{
                Py_DECREF(pFunc);
                Py_DECREF(pModule);
                PyErr_Print();
                fprintf(stderr,"Call failed\n");
                return 1;
            }
        }
        else 
		{
            if (PyErr_Occurred())
                PyErr_Print();
            fprintf(stderr, "Cannot find function \"%s\"\n", argv[2]);
        }
        Py_XDECREF(pFunc);
        Py_DECREF(pModule);
    }
    else 
	{
        PyErr_Print();
        fprintf(stderr, "Failed to load \"%s\"\n", argv[1]);
        return 1;
    }
    Py_Finalize();

	Sleep(2000);
    return 0;
}

