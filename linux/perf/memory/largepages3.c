#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#define SIZE (3UL*1024*1024*1024)

int main()
{
	char *p = malloc(SIZE), *p2;
	struct timeval before, after;

	gettimeofday(&before, NULL);
	memset(p, 0, SIZE);
	gettimeofday(&after, NULL);
	printf("memset page fault %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	memset(p, 0, SIZE);
	gettimeofday(&after, NULL);
	printf("memset tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	memset(p, 0, SIZE);
	gettimeofday(&after, NULL);
	printf("memset second tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	for (p2 = p; p2 < p+SIZE; p2 += 4096)
		*p2 = 0;
	gettimeofday(&after, NULL);
	printf("random access tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	for (p2 = p; p2 < p+SIZE; p2 += 4096)
		*p2 = 0;
	gettimeofday(&after, NULL);
	printf("random access second tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	return 0;
}

