#!/usr/bin/perl -w
# $Id: crl-from-ldap.pl,v 1.0 2008/03/07 18:49:47 EPinto Exp $
#
# Copyright (C) 2008 yersinia.spiros
#
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.


use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text
                         ldap_error_name
                         ldap_error_desc
                        );
use Pod::Usage;
use POSIX qw(strftime);
use Sys::Hostname;
use URI::ldap;


my $args = join(" ", @ARGV);

$ENV{PATH} = "/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin";
my $PROGRAM = ($0 =~ /^(.*\/){0,1}(.+)/)[1];

my $VERSION = "1.0";
my $verbose=0;
my $ldap_base ;
my $ldap_filter ;
my $ldap_server;
my $crl_file;

my $help = 0;
my $man = 0;
my $ldap_timeout=10;

my $rc = GetOptions( "ldap-filter=s" => \$ldap_filter,
                    "crl-file=s", => \$crl_file,
                    "timeout=i", => \$ldap_timeout,
                    "verbose!" => \$verbose,
                    "help|?" => \$help,
                    "man" => \$man,
                   );



if($help || ! $rc) {
  pod2usage(0);
}

if($man) {
  pod2usage({-exitstatus => 0,
             -verbose => 3});
}


if (!$ldap_filter) {
      die "$PROGRAM: Please '--ldap-filter=<ldap filter>'.\n";
}

if (!$crl_file) {
      die "$PROGRAM: Please '--crl-file=<file>'.\n";
}


my $uri = URI->new("$ldap_filter");
$ldap_base  = $uri->dn;
$ldap_filter = $uri->filter;
$ldap_server = $uri->host;
my $ldap_scope  = $uri->scope;

if (!$ldap_base && !$ldap_filter && !$ldap_server && !$ldap_scope) {
      die "$PROGRAM: Wrong '--ldap-filter=<ldap filter>'.\n";
}

my $ldap = Net::LDAP->new($ldap_server,
                          timeout => $ldap_timeout
) or die "$PROGRAM: $@";

$ldap->bind(version => 3) or die "$PROGRAM: $@";

my $mesg = $ldap->search (
                            base    => $ldap_base,
                            scope   => $ldap_scope,
                            filter  => "$ldap_filter",
                            attrs   =>  ["certificateRevocationList;binary"],
                            timelimit => $ldap_timeout
                       );


die "$PROGRAM: Error in ldap search: ",ldap_error_name($mesg)," LDAP Return code was ",$mesg->code,
        if $mesg->code;

#
# get record entry object
#
my $entry = $mesg->entry();
my $crl;
die "$PROGRAM: Error more entries dn returned for a single crl" if ( $mesg->count > 1 );
if ( $mesg->count == 0 )
{

    my $mesg = $ldap->search (
                            base    => $ldap_base,
                            scope   => $ldap_scope,
                            filter  => "$ldap_filter",
                            attrs   =>  ["certificateRevocationList"],
                            timelimit => $ldap_timeout
                       );
    die "$PROGRAM: Error in ldap search: ",ldap_error_name($mesg)," LDAP Return code was ",$mesg->code,
        if $mesg->code;

    die "$PROGRAM: Error more entries dn returned for a single crl" if ( $mesg->count > 1 );
    if ( $mesg->count == 0 )
    {

    print "\n";
    print "$PROGRAM: No crl for filter \n" ;
    print "\n";
    exit(1);
   }
   else
   {
    my @attrs = sort $entry->attributes;
    my $max = 0;

    my $dn = $entry->dn();
    my $attr = $entry->get_value("certificateRevocationList");

    if($attr)
       {
       $crl = $attr;
       }
    else
      {
       print STDERR "\n";
       print STDERR "$PROGRAM: No certificateRevocationList attribute for DN\n";
       print STDERR "$dn\n";
       print STDERR "\n";
       $ldap->unbind;
       exit(1);
    }
   }
}
else
{
  my @attrs = sort $entry->attributes;
  my $max = 0;

  my $dn = $entry->dn();
  my $attr = $entry->get_value("certificateRevocationList;binary");

  if($attr)
      {
      $crl = $attr;
      }
  else
     {
      print STDERR "\n";
      print STDERR "$PROGRAM: No certificateRevocationList attribute for DN\n";
      print STDERR "$dn\n";
      print STDERR "\n";
      $ldap->unbind;
      exit(1);
  }
}

$ldap->unbind;
if (! $crl) {
  die "$PROGRAM: unable to find crl.\n";
}


open(OUT, "+>$crl_file") or die "$PROGRAM: unable to open output file '$crl_file': $!\n";
binmode(OUT);
$| = 1;

print OUT $crl;

close(OUT);

if ( ! -f $crl_file || -z $crl_file) {
  die "$PROGRAM: output file '$crl_file' does not exist or is empty.";
}
else {

}
print STDERR "$PROGRAM: SUCCESS : wrote $crl_file\n";






__END__

=head1 NAME


crl-from-ldap.pl - Retrieve a CRL from a LDAP server and write it into a file

=head1 SYNOPSIS


crl-from-ldap.pl [options]

 Options:

   --crl-file=file        * required

   --ldap-filter=string   * required

   --timeout=integer      * optional

   --[no]verbose

   --help | -? | --?
   --man | -m

=head1 OPTIONS

=over 8

=item B<--crl-file=file>

This sets the file to use for placement of the CRL.

=item B<--ldap-filter=string>

The  ldap filter as defined in RFC 2255 - The LDAP URL Format

=item B<--timeout=number>

The timeout for connect and search the crl.

Default 10 seconds


=item B<--help | --? | -?>

A quick list of options.

=item B<--man | -m>

The full POD documentation.

=head1 DESCRIPTION

B<crl-from-ldap.pl> retrieves a CRL (Certificate Revocation List) from
an  LDAP server and puts it in a specific file

If any sort of error occurs this program aborts, printing the error
(if you run it under cron, the error will be mailed to the owner of
the crontab).

This program is intended to be run from a crontab, scheduled to run
once a day.

=head1 CRON

The retrieval script can be run daily at 10am by putting the following
line into root's crontab:

0 10 * * * /path/to/script/crl-from-ldap.pl

=head1 Perl Requirements

The retrieval script requires the following Perl modules:
Data::Dumper, Getopt::Long, Net::LDAP, Pod::Usage, POSIX,
Time::ParseDate, Sys::Hostname and URI::ldap .

If these modules are not installed they can be retrieved from
http://www.cpan.org .

=head1 AUTHOR/BUGS

This script was written from Elia Pinto
<yersia.spiros@gmail.com>

=head1 COPYRIGHT

This is free software; see the source for copying conditions.  There
is NO war- ranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.


=cut

# }}}


