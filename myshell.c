#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#pragma GCC optimize("O2")
// 329924567 Gideon Neeman

char history[100][101];
void printHistory()
{
    for (int i = 0; i < 100; i++)
    {
        if (strcmp(history[i], "") == 0)
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
    char string[101];
    if (getcwd(string, sizeof(string)) != NULL)
    {
        printf("%s\n", string);
    }
    else
    {
        perror("getcwd() failed");
    }
}

int main(char argc, char *argv[])
{
    char path[100001] = "";

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
        char command[101];
        fgets(command, sizeof(command), stdin);
        command[strcspn(command, "\n")] = 0;
        char *token = strtok(command, " ");
        char *tokens[101];
        int i = 0;
        while (token != NULL)
        {
            tokens[i] = token;
            i++;
            token = strtok(NULL, " ");
        }
        tokens[i] = NULL;
        char commandH[1024] = "";
        for (int j = 0; j < i && tokens[j] != NULL; j++)
        {
            strcat(commandH, tokens[j]);
            strcat(commandH, " ");
        }
        if (strcmp(tokens[0], "history") == 0)
        {
            addHistory(commandH);
            printHistory();
        }
        else if (strcmp(command, "cd") == 0)
        {
            addHistory(commandH);
            cd(tokens[1]);
        }
        else if (strcmp(tokens[0], "pwd") == 0)
        {
            addHistory(commandH);
            pwd();
        }
        else if (strcmp(tokens[0], "exit") == 0)
        {
            exit(0);
        }
        else
        {
            char command[1024] = "";
            for (int j = 0; j < i && tokens[j] != NULL; j++)
            {
                strcat(command, tokens[j]);
                strcat(command, " ");
            }
            addHistory(command);
            pid_t pid = fork();
            if (pid < 0)
            {
                perror("fork failed");
                return 1;
            }
            if (pid == 0)
            {
                if (tokens[1] == NULL || strcmp(tokens[1], "") == 0)
                {
                    execlp(tokens[0], tokens[0], NULL);
                }
                else
                {
                    execvp(tokens[0], tokens);
                }
                perror("exec failed");
                exit(EXIT_FAILURE);
            }
            else
            {
                wait(NULL);
            }
        }
    }
    return 0;
}