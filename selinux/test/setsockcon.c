#include <selinux/selinux.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
/*
 *   class can be
 *     "file"
 *       "dir"
 *         "lnk_file"
 *           "sock_file"
 *             "fifo_file"
 *               "chr_file"
 *                 "blk_file"
 *                 */

static int getfileconfrompath(security_context_t scon, const char *path, char *class, security_context_t *newcon) {
	security_context_t fcon = NULL;
	security_class_t sclass;
	int rc = 0;

	rc = getfilecon(path, &fcon);
	if (rc < 0)
		goto out;
	sclass = string_to_security_class(class);
	rc = security_compute_create(scon, fcon, sclass, newcon);
	if (rc < 0)
		goto out;
out:
	freecon(fcon);
	return rc;
}

static int getconfromexe(const char *exe, security_context_t *newcon)
{
	security_context_t mycon = NULL, fcon = NULL;
	security_class_t sclass;
	int rc = 0;

	rc = getcon(&mycon);
	if (rc < 0)
		goto out;
	rc = getfilecon(exe, &fcon);
	if (rc < 0)
		goto out;
	sclass = string_to_security_class("process");
	rc = security_compute_create(mycon, fcon, sclass, newcon);
	if (rc < 0)
		goto out;
out:
	freecon(mycon);
	freecon(fcon);
	return rc;
}

void usage(const char *program) {
	printf(
"%s exec_path listen_directory type\n\n"
"%s /usr/sbin/avahi-daemon /var/run file\n"
, program, program);
	
	
}
int main(int argc, char **argv) 
{
	int i;
	security_context_t newcon = NULL;
	security_context_t filecon = NULL;

	if ( argc < 3 ) {
		usage(argv[0]);
		exit(1);
	}

	/* This function returns the context defined in policy for the 
 * 	   executable argv[1], after it transitions from the current context */
	if (getconfromexe(argv[1], &newcon) < 0) {
		perror(argv[1]);
		exit(1);
	}
	/* This function tells the kernel to label all sockets after this call 
 * 	   with the newcon context, untill this function is called again */
	if (setsockcreatecon(newcon) < 0) {
		perror(argv[1]);
		exit(1);
	}
	/* This function returns the file context defined in policy for the 
 * 	   context newcon, creating a object of type arg[2] in the directory 
 * 	   	   argv[2] */
	if (getfileconfrompath(newcon, argv[2], argv[3], &filecon)  < 0) {
		perror(argv[2]);
		exit(1);
	}
	printf("%s %s %s\n", argv[1], newcon, filecon);
	/* This function tells the kernel to label all file system objects 
 * 	   created after this call with the filecon context, until this 
 * 	   	   function is called again */

	if (setfscreatecon(filecon) < 0) {
		perror(filecon);
		exit(1);
	}
	freecon(newcon);
	freecon(filecon);

	/* calling setsockcreatecon and setfscreatecon with the NULL parameter 
 * 	   resets the system to the default */
	setsockcreatecon(NULL);
	setfscreatecon(NULL);

	exit(0);
}

