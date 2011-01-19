# Process this file with automake to produce Makefile.in
# Makefile.am for t50/man.
#

man_MANS = t50.1
EXTRA_DIST = $(man_MANS)
MAINTAINERCLEANFILES = $(man_MANS)

common_mandeps = $(top_srcdir)/configure.ac

t50.1: $(top_srcdir)/src/usage.c $(common_mandeps)
	$(HELP2MAN) -s 1 -N --name="T50" $(top_srcdir)/src/t50 -o $@
