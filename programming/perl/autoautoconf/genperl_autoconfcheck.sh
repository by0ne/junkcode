cat <<"EOF"
AC_PATH_PROG(PERL, perl)
if test -z "$PERL"; then
   AC_MSG_ERROR([perl not found])
fi
$PERL -e 'require 5.006;' || {
   AC_MSG_ERROR(
[perl 5.6 or better is required; perl 5.8.2 or better
is recommended.  If you have several perl versions
installed, select the one us should use using
  ./configure PERL=/path/to/perl])
}
# We require ithreads support, and version 5.7.2 for CLONE.
AC_CACHE_CHECK([whether $PERL supports ithreads], [am_cv_prog_PERL_ithreads],
[if $PERL -e '
    require 5.007_002;
    use Config;
    if ($Config{useithreads})
      {
        require threads;
        import threads;
        require Thread::Queue;
        import Thread::Queue;
        exit 0;
      }
    exit 1;' >&AS_MESSAGE_LOG_FD 2>&1
then
  am_cv_prog_PERL_ithreads=yes
else
  am_cv_prog_PERL_ithreads=no
fi])

EOF

