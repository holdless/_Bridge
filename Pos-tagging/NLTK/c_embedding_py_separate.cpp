// c_embedding_py.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"


#define MS_NO_COREDLL
// Since Python may define some pre-processor definitions which affect the standard headers
// on some systems, you must include Python.h before any standard headers are included.
#include <Python.h>
#include <Windows.h> // for Sleep(2000)


PyObject* callPythonFunc(const char* scriptName, 
			 const char* funcName,
			 PyObject* pInpTuple);

int main(int argc, char* argv[])
{
	// declare names of py script & functions
	const char* script_name = "pos_tag";
	const char* load_func_name = "loadPickle";
	const char* tag_func_name = "posTagging";
	const char* sentence = "i am jacjk";

	// declare PyObject
	PyObject *pTagger;
	PyObject *pArgs, *pSentence;

	// init C/Python interpreter
	Py_SetProgramName(argv[0]);
    Py_Initialize();
    PySys_SetArgv(argc, argv);

	// 1st call: loading tagger
    pTagger = callPythonFunc(script_name, 
							 load_func_name,
							 NULL);

	// 2nd call: for pos-tagging
	pArgs = PyTuple_New(2);
	pSentence = PyString_FromString(sentence);
	PyTuple_SetItem(pArgs, 0, pSentence);
	PyTuple_SetItem(pArgs, 1, pTagger);
    PyObject* b = callPythonFunc(script_name, 
								 tag_func_name,
								 pArgs);

    Py_DECREF(pArgs);
//    Py_DECREF(pSentence); //<- after PyTuple_SetItem (who steals the refcnt), we don need to handle this!?
//    Py_DECREF(pTagger);
    Py_DECREF(b);

	Py_Finalize();

    return 0;
}


PyObject* callPythonFunc(const char* scriptName, 
					const char* funcName,
					PyObject* pInpTuple)
{
	PyObject *pName, *pModule, *pFunc, *pRetValue;

    pName = PyString_FromString(scriptName);
    pModule = PyImport_Import(pName);
    Py_DECREF(pName);

	if (pModule != NULL) 
	{
        pFunc = PyObject_GetAttrString(pModule, funcName);
        // pFunc is a new reference

        if (pFunc && PyCallable_Check(pFunc)) 
		{
            pRetValue = PyObject_CallObject(pFunc, pInpTuple);

            if (pRetValue != NULL) 
			{
                printf("Call successful\n");
//                Py_DECREF(pValue);
            }
            else 
			{
                Py_DECREF(pFunc);
                Py_DECREF(pModule);
                PyErr_Print();
                fprintf(stderr,"Call failed\n");
                return NULL;
            }
        }
        else 
		{
            if (PyErr_Occurred())
                PyErr_Print();
            fprintf(stderr, "Cannot find function \"%s\"\n", funcName);
        }
        Py_XDECREF(pFunc);
        Py_DECREF(pModule);
    }
    else 
	{
        PyErr_Print();
        fprintf(stderr, "Failed to load \"%s\"\n", scriptName);
        return NULL;
    }

	return pRetValue;
}

