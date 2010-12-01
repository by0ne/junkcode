#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main() {
	printf("Hello from rpm-setuid-test-" VERSION "-" RELEASE ".  Effective UID: %d\n", geteuid());
	return 0;
}
