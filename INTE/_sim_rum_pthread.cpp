#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>
#include <iostream>

using namespace std;

// global variables
bool cam_end(false), frame_in(false);
// pthread init
pthread_mutex_t mut = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;

void *camera_buffer_callback(void *arg) 
{
	for (int i = 0; i < *(int*)arg; i++)
	{
		pthread_mutex_lock(&mut);
		frame_in = true;
		pthread_cond_signal(&cond);	
		cout<<"frame:"<<i+1<<endl;
		pthread_mutex_unlock(&mut);
		sleep(5);
	}
	
	cam_end = true;
	return NULL;
}

void *image_proc(void *arg) 
{
//	struct timeval now;
//	struct timespec outtime;
	
	while (!cam_end)
	{
		pthread_mutex_lock(&mut);
		while (!frame_in) // using "while" because of "spurious wakeup" from cpu 
		{	
			cout<<"wait..."<<endl;
			pthread_cond_wait(&cond, &mut);
		}
		cout<<"img proc..."<<endl;
		frame_in = false;
		pthread_mutex_unlock(&mut);
		sleep(1);
	}
	
	return NULL;
}

void *talk(void *arg)
{
	int a = 0;
	while(!cam_end)
	{
		cin>>a;
		cout<<"[talk] your input: "<<a<<endl;
	}
	return NULL;
}

int main()
{
	pthread_t cam_thread;
	pthread_t img_thread;
	pthread_t talk_thread;
	
	int loop = 20;
	
	//// pthread create ////
	// create camera_buffer_callback thread
	if ( pthread_create( &cam_thread, NULL, camera_buffer_callback, (void*)&loop) ) {
		printf("error creating cam_thread.");
		abort();
	}
	// create image_proc thread
	if ( pthread_create( &img_thread, NULL, image_proc, NULL) ) {
		printf("error creating img_thread.");
		abort();
	}
	// create talk thread
	if ( pthread_create( &talk_thread, NULL, talk, NULL) ) {
		printf("error creating img_thread.");
		abort();
	}

	//// pthread join ///
	if ( pthread_join ( cam_thread, NULL ) ) 
	{
		printf("error joining cam_thread.");
		abort();
	}
	if ( pthread_join ( img_thread, NULL ) ) 
	{
		printf("error joining img_thread.");
		abort();
	}
	if ( pthread_join ( talk_thread, NULL ) ) 
	{
		printf("error joining talk_thread.");
		abort();
	}
	
	return 0;
}
