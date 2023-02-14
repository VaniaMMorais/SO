#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    if(argc != 3){
    	printf("Número de argumentos incorreto");
    	exit(1);
    }
    else
    {
    	int i;
    	for(i = 0 ; i < argc ; i++)
    	{
        	printf("Argument %02d: \"%s\"\n", i, argv[i]);        
    	}
    }

    return EXIT_SUCCESS;
}
