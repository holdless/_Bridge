/*
1. on project righ-click > properties > configuration properties > vc directories > set all include/lib dependencies for Java
2. Java SE version depends on the Visual Studio version (32 or 64), not the operation system version. wrong version causes "unsolved external..."
3. remember to add "jvm.lib"
*/

#include "stdafx.h"
#include <jni.h>

int _tmain(int argc, _TCHAR* argv[])
//int main(int argc, char* argv[])
{
	JavaVM *jvm;       /* denotes a Java VM */
    JNIEnv *env;       /* pointer to native method interface */
    JavaVMInitArgs vm_args; /* JDK/JRE 8 VM initialization arguments */
    JavaVMOption* options = new JavaVMOption[1];
    options[0].optionString = "D:/Users/changyht/Documents/NetBeansProjects/Stanford Pos Tagger/dist";
    vm_args.version = JNI_VERSION_1_8;
    vm_args.nOptions = 1;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = false;
    /* load and initialize a Java VM, return a JNI interface
     * pointer in env */
    JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
    delete options;
    /* invoke the Main.test method using the JNI */
    jclass cls = env->FindClass("StanfordPosTagger");
    jmethodID mid = env->GetStaticMethodID(cls, "tag", "(I)V");
    env->CallStaticVoidMethod(cls, mid, 100);
    /* We are done. */
    jvm->DestroyJavaVM();
	
	return 0;
}

