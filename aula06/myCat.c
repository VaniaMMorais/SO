#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
/* SUGESTÂO: utilize as páginas do manual para conhecer mais sobre as funções usadas:
 man fopen
 man fgets
*/

#define LINEMAXSIZE 80 /* or other suitable maximum line size */


int main(int argc, char *argv[])
{
    FILE *fp = NULL;
    char line [LINEMAXSIZE]; 
    
    /* Validate number of arguments */
    if( argc < 2 )
    {
        printf("USAGE: %s fileName\n", argv[0]);
        return EXIT_FAILURE;
    }
    int nl=1;
    int i=1;
    for(i=1; i<argc; i++){
    	/* Open the file provided as argument */
    	errno = 0;
    	fp = fopen(argv[i], "r");
    	if( fp == NULL )
    	{
    	    perror ("Error opening file!");
    	    return EXIT_FAILURE;
    	}

    	/* Read all the lines of the file */
    	int newline=1;
    	while( fgets(line, sizeof(line), fp) != NULL )
    	{
        	 if(newline) printf("%3d:",nl);
        	 printf("%s",line);
        	 newline=line[ strlen(line)-1 ]=='\n';
        	 nl++;
    	}

    	fclose(fp);
    }
    return EXIT_SUCCESS;
}
