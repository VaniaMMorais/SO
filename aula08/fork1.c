#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    int ret;

    printf("Antes do fork: PID = %d, PPID = %d\n", getpid(), getppid()); //executada pelo pai
    if ((ret = fork()) < 0) { 	//executada pelo pai e pelo filho, porque o filho é criado dentro do fork
        perror ("erro na duplicação do processo");
        return EXIT_FAILURE;
    }
    if (ret > 0) sleep (1);	//O if é executada pelo pai e pelo filho; O sleep é executado pelo pai
    printf("Quem sou eu?\nApós o fork: PID = %d, PPID = %d\n", getpid(), getppid());// executada pelo pai e pelo filho

    return EXIT_SUCCESS;
}
