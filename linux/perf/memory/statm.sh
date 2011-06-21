cat /proc/"$1"/statm | awk '
BEGIN { PGSZ=4 ; }
{
TOTAL = $1*PGSZ;
RSS = $2*PGSZ;
SHARED = $3*PGSZ;
ANON = RSS-SHARED;
TEXT = $4*PGSZ;
LIBS = $5*PGSZ;
DATA = $6*PGSZ;
}
END {
print "Convert in KBYTE";
print "TOTAL VM :" TOTAL;

print "Resident :" RSS;
print "Shared :" SHARED;
print "Anon :" ANON;
print "Text :" TEXT;
print "Shared Libs :" SHARED;
print "Data :" DATA;
print " ";
}
'
