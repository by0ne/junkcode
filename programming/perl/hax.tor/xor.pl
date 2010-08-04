#!/usr/bin/perl
#######################################################
# hax.tor.hu/warmup5                                  #
# xor 55d cipher                                      #
#                                                     #
# created by xor ~ irc.darkscience.ws/#DarkScience || #
#                  irc.evilzone.org/#evilzone         #
#                                                     #
# Thanks to Xires for the guidance and for suggesting #
# a xor cipher.                                       #
#                                                     #
# Just so you know, the second digit in each pair of  #
# digits, is meaningless: 71 228 94 125 84 210 92 19  #
#                                                     #
# So 228, 125, 210, 19, mean and do nothing, get rid  #
# of them to use this script.                         #
#######################################################

sub banner {
  print "hax.tor.hu/warmup5 - simple xor cipher - by xor\n" .
        " [+] irc.darkscience.ws/#DarkScience\n" .
        " [+] irc.evilzone.org/#EvilZone\n\n";
}

sub usage {
  &banner;

  print "perl xor55d.pl [-x || -u] <string>\n\n" .
        "ex: perl xor55d.pl -x pick\n" .
        "ex: perl xor55d.pl -u 71 94 84 92\n";

  exit;
}


# If the user hasn't supplied the required arguments then
# show the usage screen and then exit.
if (!$ARGV[0] || !$ARGV[1]) {
  &usage;
}


my $mode = $ARGV[0];  # Should be either -x or -u
my $word = "";        # Temporary variable
shift(@ARGV);         # Remove the $mode from the array


if ($mode eq "-u")    # Reverse Shift to get letters
{
  &banner;
  print " [!] @ARGV == ";

  foreach (@ARGV)
  {
    print(chr($_ ^ 55));
  }
}
elsif ($mode eq "-x") # Shift to get numbers
{
  $word = join(" ", @ARGV);

  &banner;
  print " [!] $word == ";

  for(my $i = 0; $i < length($word); $i++)
  {
    print( (ord(substr($word, $i, 1)) ^ 55) ." ");
  }
}
else
{
  &usage;
}

1;
