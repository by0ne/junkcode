    #include <stdlib.h>

    int
    main(int ac, char **av)
    {
	    int *r1;
	    int *r2;

	    r1 = &ac;
	    *r1 = 0;
	    r2 = (void *)0;	/* or (void *)1, etc. */
	    if (*r1 != *r2)
		    return 1;
	    return 1;
    }
