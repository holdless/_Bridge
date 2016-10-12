#include<stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include<string.h>    //strlen
#include<sys/socket.h>
#include<arpa/inet.h> //inet_addr
#include<unistd.h>    //write
 
void error(const char *msg)
{
    perror(msg);
    exit(1);
}
 
int main(int argc , char *argv[])
{
    int srv_socket , client_socket , c;
    struct sockaddr_in server , client;
    char *message;
	char buffer[256];
	int n;
     
    //Create socket
    srv_socket = socket(AF_INET , SOCK_STREAM , 0);
    if (srv_socket == -1)
    {
        printf("Could not create socket");
    }
     
    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons( 6969 );
     
    //Bind
    if( bind(srv_socket,(struct sockaddr *)&server , sizeof(server)) < 0)
    {
        puts("bind failed");
        return 1;
    }
    puts("bind done");
     
    //Listen
    listen(srv_socket , 3);
     
    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);
    while( (client_socket = accept(srv_socket, (struct sockaddr *)&client, (socklen_t*)&c)) )
    {
        puts("Connection accepted");
		
        // 642.2.1011 hiroshi: receive data from client
		n = read(client_socket, buffer, sizeof(buffer));
		if (n < 0) error("ERROR reading from socket");
		printf("Here is the message: %s\n",buffer);
		memset(buffer, 0x0, sizeof(buffer));
	 
        //Reply to the client
        message = "Hello Client , I have received your connection. But I have to go now, bye\n";
        n = write(client_socket , message , strlen(message));
		if (n < 0) error("ERROR writing to socket");
    }
     
    if (client_socket<0)
    {
        perror("accept failed");
        return 1;
    }
     
    close(client_socket);
    close(srv_socket);

    return 0;
}
