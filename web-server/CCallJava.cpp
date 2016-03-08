#include "stdafx.h"
#include <iostream>
#include <string.h>
#include <jni.h>
using namespace std;

jstring str2jstring(JNIEnv* env,const char* pat);
std::string jstring2str(JNIEnv* env, jstring jstr);

int _tmain(int argc, _TCHAR* argv[])
{
	JavaVM *jvm;       /* denotes a Java VM */
    JNIEnv *env;       /* pointer to native method interface */
    JavaVMInitArgs vm_args; /* JDK/JRE 8 VM initialization arguments */
    JavaVMOption* options = new JavaVMOption[1];
    options[0].optionString = "-Djava.class.path=D:/Users/changyht/Documents/NetBeansProjects/wJaWebServer/dist/wJaWebServer.jar";
    vm_args.version = JNI_VERSION_1_8;
    vm_args.nOptions = 1;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = false;
    /* load and initialize a Java VM, return a JNI interface
     * pointer in env */
    JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
    delete options;
    /* invoke the Main.test method using the JNI */
    jclass cls = env->FindClass("wjawebserver/WJaWebServer");
	
	// call java method "webServer" to start serving
    jmethodID mid = env->GetStaticMethodID(cls, "webServer2", "(I)V");
	int port = 8088; // webserver port
    env->CallStaticObjectMethod(cls, mid, port);

	jvm->DestroyJavaVM();
	return 0;
}
