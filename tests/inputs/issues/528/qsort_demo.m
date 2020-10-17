#include <stdio.h>
#include <stdlib.h>

/*
        Al Danial April 25 2000
*/

#define ELEMENTS 1000

static int compar_string(const void *a, const void *b){
        return (strcmp( (char *)a, (char *)b));
}

int comp(const void *a, const void *b ) {
    return *(int *)a - * (int *)b;
}

main(){

        int x, i;
        char *string;
        struct sort_test_t {
                int s;
        } ;

        struct sort_test_t sort_test[ELEMENTS];

        /* inititalize the array */
        for (i=0;i<ELEMENTS;i++) {
                /* produce a random variable */
                x=1+(100000.0*rand()/(RAND_MAX+1.0));
                /* load the variable into the string as an array */
                sort_test[i].s = (int) x;
                /*
                printf("unsorted %d %d\n", i, sort_test[i].s);
                */
        }

        /* sort the array */
        qsort(sort_test, ELEMENTS, sizeof(sort_test[0]), &comp);

        /* output the sorted array */
        for (i=0;i<ELEMENTS;i++) {
                printf("sorted %d %d\n", i, sort_test[i].s);
        }

}
