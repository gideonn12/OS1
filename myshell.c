#include <stdio.h>
#include <string.h>
// 329924567 Gideon Neeman

char history[100][100];
void printHistory(){
    for(int i = 0; i < 100; i++) {
    printf("%s\n", history[i]);
    }
}
void addHistory(char *command){
    for(int i = 0; i < 100; i++) {
        if(strcmp(history[i], "") == 0){
            strcpy(history[i], command);
            break;
        }
    }
}
void cd(){}
void pwd(){}
void ls(){
    system("ls");
}
void cat(){
    system("cat");
}
void sleep(){
    system("sleep");
}
int main(char argc, char *argv[]) {
    char path[10000] = "";

    for(int i = 1; i < argc; i++) {
        strcat(path, argv[i]);
        strcat(path, ":");
    }
    char *currentPath = getenv("PATH");
    strcat(path, currentPath);
    setenv("PATH", path, 1);
    
    while(1){
        printf("$ ");
        fflush(stdout);
        char command[100];
        fgets(command, sizeof(command), stdin);
        command[strcspn(command, "\n")] = 0;
        addHistory(command);
        if(strcmp(command, "history") == 0){
            printHistory();
        }
        else if(strcmp(command, "cd") == 0){
            cd();
        }
        else if(strcmp(command, "pwd") == 0){

            pwd();
        }
        else if(strcmp(command, "exit") == 0){
            exit(0);  
        }
        else if(strcmp(command, "ls") == 0){
            ls();
        }
        else if(strcmp(command, "cat") == 0){
            cat();
        }
        else if(strcmp(command, "sleep") == 0){
            sleep();
        }
        else{
            system(command);
            }

    }
    return 0;
}