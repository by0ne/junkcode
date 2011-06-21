#if 0
base=malloccount
cmd="gcc -Wall -Wstrict-prototypes -fPIC -D_GNU_SOURCE -ldl \
    -shared -o lib$base.so $base.c"
echo $cmd
$cmd
if [ $? != 0 ]; then echo compile failed; return; fi
echo -e "\nrun with:\nLD_PRELOAD=$PWD/lib$base.so <program>"
return
#endif

#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>
#include <stdio.h>

static size_t cur, peak, total;

static void *(*_malloc)(size_t);
static void (*_free)(void *);

#define INIT_HEAP_SIZE 4096
static char init_heap[INIT_HEAP_SIZE];
static size_t init_heap_use;

#define min(a,b) (a) < (b) ? (a) : (b)

static inline void inc_count(size_t inc)
{
	if ((cur += inc) > peak)
		peak = cur;
	total += inc;
}

static inline void dec_count(size_t dec)
{
	cur -= dec;
}

void *malloc(size_t size)
{
	void *ret;
	if (!size)
		return NULL;
	if (_malloc) {
		ret = (*_malloc)(size + sizeof(size_t));
		*((size_t *)ret) = size;
		ret += sizeof(size_t);
		inc_count(size);
	} else {
		if (init_heap_use + size > INIT_HEAP_SIZE) {
			fprintf(stderr, "init heap full!\n");
			exit(EXIT_FAILURE);
		}
		ret = init_heap + (init_heap_use += size);
	}
	return ret;
}

void free(void *ptr)
{
	if (!ptr)
		return;
	if (ptr >= (void *)init_heap
			&& ptr <= (void *)init_heap + init_heap_use)
		return;
	ptr -= sizeof(size_t);
	dec_count(*(size_t *)ptr);
	(*_free)(ptr);
}

void *calloc(size_t nmemb, size_t size)
{
	void *ret;
	size *= nmemb;
	if (!size)
		return NULL;
	ret = malloc(size);
	memset(ret, 0, size);
	return ret;
}
void *realloc(void *ptr, size_t size)
{
	void *newptr;
	size_t oldsize;

	if (!size) {
		free(ptr);
		return NULL;
	}
	if (!ptr)
		return malloc(size);
	oldsize = *(size_t *)(ptr - sizeof(size_t));
	newptr = malloc(size);
	if (newptr)
		memcpy(newptr, ptr, min(oldsize, size));
	return newptr;
}

__attribute__((constructor)) void init(void)
{
	char *error;

	dlerror();
	_malloc = dlsym(RTLD_NEXT, "malloc");
	if ((error = dlerror()) != NULL) {
		fprintf(stderr, "malloccount: %s\n", error);
		exit(EXIT_FAILURE);
	}
	_free = dlsym(RTLD_NEXT, "free");
	if ((error = dlerror()) != NULL) {
		fprintf(stderr, "malloccount: %s\n", error);
		exit(EXIT_FAILURE);
	}
}

__attribute__((destructor)) void fini(void)
{
	FILE *fp;
	
	if (!(fp = fopen("/dev/tty", "w")))
		return;
	
	fprintf(fp, "### bytes allocated: total: %d, peak: %d\n",
			total, peak);

	fclose(fp);
}


