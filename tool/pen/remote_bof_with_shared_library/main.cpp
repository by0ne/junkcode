#include <windows.h>
#include <stdio.h>
#include <string.h>

#pragma comment (lib,"Ws2_32")
#define MAX_DATA 1024

void SocketStartup(){

	WSAData data;
	WSAStartup(MAKEWORD(2,2),&data);


}

void OverFlowFunction(char*data){
	char username[30] = "";

	strcpy(username,data);//failed 
	
	printf("USERNAME : %s %d\n",username,strlen(username));
	//ret to xx xx xx xx 
}

void Listen(){

	char buff[MAX_DATA+100] = "";
	SOCKET sck,sc_k = NULL;
	sockaddr_in socket_addr;
	char USER[] = "user";

	sck = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
	
	socket_addr.sin_family = AF_INET;
	socket_addr.sin_port = htons(6667);
	socket_addr.sin_addr.S_un.S_addr = INADDR_ANY;

	bind(sck,(SOCKADDR*)&socket_addr,sizeof(sockaddr_in));
	listen(sck,10);

	while(1){

		sc_k = accept(sck,NULL,NULL);

		while(sc_k != INVALID_SOCKET){

			recv(sc_k,buff,MAX_DATA,0);

			if(strstr(buff,USER) !=0 ){
			
				//printf("User Command Recv\n");
				OverFlowFunction(buff);
				
			}
		
		}

	}
}

void CallDll(){

	LoadLibrary("fmod.dll");

}
void main(){

	CallDll();
	SocketStartup();//startup the WSA
	Listen();
}