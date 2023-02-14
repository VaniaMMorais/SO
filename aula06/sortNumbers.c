#include <stdio.h>
#include <stdlib.h>

/* SUGESTÂO: utilize as páginas do manual para conhecer mais sobre as funções usadas:
 man qsort
*/

int compareInts(const void *px1, const void *px2)
{
    int x1 = *((int *)px1);
    int x2 = *((int *)px2);
    return(x1 < x2 ? -1 : x1 == x2 ? 0 : 1);
}

int main(int argc, char *argv[])
{
    int numSize;
    int *numbers;
    numbers=(int*) malloc(100*sizeof(int));
    FILE *fp;
    char line[1000];
    fp= fopen("nums.txt","r");
    if(fp==NULL) 
    {
    	perror ("Error opening file!");
    	return EXIT_FAILURE;
    }
    
    

    numSize = argc - 1;

    /* Memory allocation for all the numbers in the arguments */
    numbers = (int *) malloc(sizeof(int) * numSize);

    /* Storing the arguments in the "array" numbers */
    for(int i = 0 ; i < numSize ; i++)
    {
        numbers[i] = atoi(argv[i+1]);
    }

    /* void qsort(void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *)); 
         The qsort() function sorts an array with nmemb elements of size size.*/
    qsort(numbers, numSize, sizeof(int), compareInts);

    /* Printing the sorted numbers */
    printf("Sorted numbers: \n");
    for(int i = 0 ; i < numSize ; i++)
    {
        printf("%d\n", numbers[i]);
    }
    int count=0;
    while(fgets(line, sizeof(line), fp) != NULL)
    {
    	numbers[count]= atoi(line);
    	count ++;
    }
    while (fscanf(fp, "%d", &numbers[count]))
    {
    	count++;
    }

    return EXIT_SUCCESS;
}
