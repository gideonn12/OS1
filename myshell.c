#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <stdlib.h>
// 329924567 Gideon Neeman

char history[100][100];
void printHistory()
{
    for (int i = 0; i < 100; i++)
    {
        if(strcmp(history[i], "") == 0)
        {
            break;
        }
        printf("%s\n", history[i]);
    }
}
void addHistory(char *command)
{
    for (int i = 0; i < 100; i++)
    {
        if (strcmp(history[i], "") == 0)
        {
            strcpy(history[i], command);
            break;
        }
    }
}
void cd(char *path)
{
    if (chdir(path) != 0)
    {
        perror("chdir() failed");
    }
}
void pwd()
{
    char string[100];
    if (getcwd(string, sizeof(string)) != NULL)
    {
        printf("%s\n", string);
    }
    else
    {
        perror("getcwd() failed");
    }
}
void ls(char *path)
{
    pid_t pid = fork();
    if (pid < 0)
    {
        fprintf(stderr, "Fork Failed\n");
        return;
    }
    if (pid == 0)
    {
        execlp("/bin/ls", "ls", path, NULL);
    }
    else
    {
        wait(NULL);
    }
}

int main(char argc, char *argv[])
{
    char path[10000] = "";

    for (int i = 1; i < argc; i++)
    {
        strcat(path, argv[i]);
        strcat(path, ":");
    }
    char *currentPath = getenv("PATH");
    strcat(path, currentPath);
    setenv("PATH", path, 1);

    while (1)
    {
        printf("$ ");
        fflush(stdout);
        char command[100];
        fgets(command, sizeof(command), stdin);
        command[strcspn(command, "\n")] = 0;

        char *token = strtok(command, " ");
        char *tokens[100];
        int i = 0;
        while (token != NULL)
        {
            tokens[i] = token;
            i++;
            token = strtok(NULL, " ");
        }
        if (strcmp(tokens[0], "history") == 0)
        {
            addHistory(tokens[0]);
            printHistory();
        }
        else if (strcmp(command, "cd") == 0)
        {
            addHistory(tokens[0]);
            cd(tokens[1]);
        }
        else if (strcmp(tokens[0], "pwd") == 0)
        {
            addHistory(tokens[0]);
            pwd();
        }
        else if (strcmp(tokens[0], "exit") == 0)
        {
            exit(0);
        }
        else
        {
            // TODO : add to history alco the flags
            addHistory(tokens[0]);
            pid_t pid = fork();
            if (pid < 0)
            {
                perror("Fork Failed");
                return 1;
            }
            if (pid == 0)
            {
                execvp(tokens[0], tokens);
                exit(0);
            }
            else
            {
                wait(NULL);
            }
        }
    }
    return 0;
}