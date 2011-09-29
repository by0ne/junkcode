#!/usr/bin/env perl

use warnings;
use strict;

use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);

use Config::IniFiles;
use IO::Socket::SSL;

use Time::gmtime;
use Time::ParseDate;

Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

sub get_dates;
sub get_pem;
sub check_dates;
sub check_port;
sub check_hostname;
sub check_protocol_cipher;
sub letter_grade;
sub grade_result;
sub get_peer_certificate;

sub get_dates {
	my ( $dest_serv, $port ) = @_;    # Read command line
	$port = getservbyname( $port, 'tcp' ) unless $port =~ /^\d+$/;
	my $dest_ip = gethostbyname($dest_serv);
	my $dest_serv_params = sockaddr_in( $port, $dest_ip );

	socket( S, &AF_INET, &SOCK_STREAM, 0 ) or die "socket: $!";
	connect( S, $dest_serv_params ) or die "connect: $!";
	select(S);
	$| = 1;
	select(STDOUT);                   # Eliminate STDIO buffering

	# The network connection is now open, lets fire up SSL

	my $ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
	Net::SSLeay::CTX_set_options( $ctx, &Net::SSLeay::OP_ALL )
	  and die_if_ssl_error("ssl ctx set options");
	my $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
	Net::SSLeay::set_fd( $ssl, fileno(S) );    # Must use fileno
	my $res = Net::SSLeay::connect($ssl) and die_if_ssl_error("ssl connect");

	my $x509 = Net::SSLeay::get_peer_certificate($ssl);

	my $date_before =
	  Net::SSLeay::P_ASN1_UTCTIME_put2string(
									   Net::SSLeay::X509_get_notBefore($x509) );
	my $date_after =
	  Net::SSLeay::P_ASN1_UTCTIME_put2string(
										Net::SSLeay::X509_get_notAfter($x509) );
	Net::SSLeay::free($ssl);                   # Tear down connection
	Net::SSLeay::CTX_free($ctx);
	close S;

	return ( $date_before, $date_after );
}

sub get_pem {
	my ( $dest_serv, $port ) = @_;             # Read command line
	$port = getservbyname( $port, 'tcp' ) unless $port =~ /^\d+$/;
	my $dest_ip = gethostbyname($dest_serv);
	my $dest_serv_params = sockaddr_in( $port, $dest_ip );

	socket( S, &AF_INET, &SOCK_STREAM, 0 ) or die "socket: $!";
	connect( S, $dest_serv_params ) or die "connect: $!";
	select(S);
	$| = 1;
	select(STDOUT);                            # Eliminate STDIO buffering

	# The network connection is now open, lets fire up SSL

	my $ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
	Net::SSLeay::CTX_set_options( $ctx, &Net::SSLeay::OP_ALL )
	  and die_if_ssl_error("ssl ctx set options");
	my $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
	Net::SSLeay::set_fd( $ssl, fileno(S) );    # Must use fileno
	my $res = Net::SSLeay::connect($ssl) and die_if_ssl_error("ssl connect");

	my $x509 = Net::SSLeay::get_peer_certificate($ssl);
	my $pem  = Net::SSLeay::PEM_get_string_X509($x509);

	Net::SSLeay::free($ssl);                   # Tear down connection
	Net::SSLeay::CTX_free($ctx);
	close S;

	return ($pem);
}

sub check_dates {
	my ( $host, $port ) = @_;
	my ( $date_before, $date_after ) = get_dates( $host, $port );

	print "Valid from: $date_before\n";
	print "Valid to:   $date_after\n";

	my $date_before_epoch = parsedate($date_before);
	my $date_after_epoch  = parsedate($date_after);
	my $date_now_epoch    = time();

	#my $date_now_epoch = $date_after_epoch - (5 * 24 * 60 * 60);

	#print "valid from:  $date_before_epoch\n";
	#print "current time: $date_now_epoch\n";
	#print "valid to:    $date_after_epoch\n";

	if ( $date_before_epoch > $date_now_epoch ) {
		print "Certificate not yet valid\n";
	} elsif ( $date_after_epoch <= $date_now_epoch ) {
		print "Certificate expired\n";
	} elsif ( $date_after_epoch <= ( $date_now_epoch + ( 30 * 24 * 60 * 60 ) ) )
	{
		print "Certificate will expire in 30 days or less\n";
	} else {
		print "Certificate date valid\n";
	}
}

sub check_port {
	my ( $host, $port ) = @_;

	print "Connecting to $host:$port - ";

	if ( $port =~ /\D/ ) {
		$port = getservbyname( $port, 'tcp' );
	}
	die "No port" unless $port;

	my $iaddr = inet_aton($host) || die "no host: $host";
	my $paddr = sockaddr_in( $port, $iaddr );
	my $proto = getprotobyname('tcp');

	socket( SOCK, PF_INET, SOCK_STREAM, $proto ) || die "socket: $!";
	if ( connect( SOCK, $paddr ) ) {
		print "OK\n";
		close(SOCK) || die "close: $!";
		return 1;
	} else {
		print "Connection refused\n";
		return 0;
	}
}

sub check_hostname {

	# Verify hostname / CN Name
	my ( $host, $port ) = @_;
	my %server_options = (
						   PeerAddr => $host,
						   PeerPort => $port
	);

	if ( my $client = IO::Socket::SSL->new(%server_options) ) {
		if ( !$client->verify_hostname( $host, 'http' ) ) {
			print "Hostname verification failed\n";
			print "  "
			  . $client->peer_certificate('commonName')
			  . " != $host\n";

			print "\n\n";
			print "Protocol grade: N/A (-)\n";
			print "Cipher grade: N/A (-)\n";
			print "\n";
			print "Summary grade: 0 (F)\n";
			print "\n\n";

			return 1;
		} else {
			print "Certificate CN: "
			  . $client->peer_certificate('commonName')
			  . " == Hostname: $host\n";

			return 0;
		}
	}
	return -1;
}

sub check_protocol_cipher {
	my ( $host, $port, $ssl_version, $cipher ) = @_;

	#print "check_protocol_cipher( $host, $port, $ssl_version, $cipher )\n";

	my %server_options = (
						   SSL_version     => $ssl_version,
						   SSL_cipher_list => $cipher,
						   PeerAddr        => $host,
						   PeerPort        => $port
	);

	if ( my $client = IO::Socket::SSL->new(%server_options) ) {
		return 1;    # Connection accepted
	} else {
		return 0;    # Connection failed
	}
}

sub letter_grade {
	my $score = shift(@_);
	my $grade;

	if ( $score >= 80 ) {
		$grade = "A";
	} elsif ( $score >= 65 ) {
		$grade = "B";
	} elsif ( $score >= 50 ) {
		$grade = "C";
	} elsif ( $score >= 35 ) {
		$grade = "D";
	} elsif ( $score >= 20 ) {
		$grade = "E";
	} else {
		$grade = "F";
	}

	return ($grade);
}

sub grade_result {
	my @scores = @_;
	my $score;
	my @sorted_scores = sort { $a <=> $b } @scores;

	if ( $sorted_scores[0] == 0 ) {
		$score = 0;
	} else {
		$score =
		  ( ( $sorted_scores[0] + $sorted_scores[$#sorted_scores] ) / 2 );
	}
	my $grade = letter_grade($score);

	return ( $score, $grade );
}

sub get_peer_certificate {

	# Verify hostname / CN Name
	my ( $host, $port ) = @_;

	#print "check_hostname($host, $port)\n";

	my %server_options = (
						   PeerAddr => $host,
						   PeerPort => $port
	);

	if ( my $client = IO::Socket::SSL->new(%server_options) ) {
		return $client->dump_peer_certificate();
	} else {
		return -1;
	}
}

my $numArgs = @ARGV;
my ( $host, $port );

my @protocol_scores = ();
my @cipher_scores   = ();

if ( ( $numArgs < 1 ) || ( $numArgs > 2 ) ) {
	print "Usage: sslaudit.pl host [port]";
	exit;
} else {
	$host = $ARGV[0];

	if ( $numArgs == 2 ) {
		$port = $ARGV[1];
	} else {
		$port = 443;
	}
}

if ( check_port( $host, $port ) ) {
	if ( !check_hostname( $host, $port ) ) {
		my $peer_certificate = get_peer_certificate( $host, $port );
		print $peer_certificate;

		my $pem = get_pem( $host, $port );
		print "\n" . $pem . "\n";

		check_dates( $host, $port );

		print "\n\n";

		my $filename = "sslaudit.ini";

		my $cfg = new Config::IniFiles( -file => $filename )
		  or die( "Can't read $filename" . $@ );
		my @protocols = $cfg->Sections;
		my $protocol;
		my $cipher;

		foreach $protocol (@protocols) {
			my @ciphers = $cfg->Parameters($protocol);
			foreach $cipher (@ciphers) {
				print "$protocol - $cipher";
				my $success =
				  check_protocol_cipher( $host, $port, $protocol, $cipher );

				my ( $score, $enabled );
				my $testname = $protocol . "_" . $cipher;

				if ($success) {
					$score = $cfg->val( $protocol, $cipher );
					$score =~ s/\s*[\#\;].*//g
					  ;    # Remove comments and whitespace before comments
					if ( $cipher =~ m/DEFAULT/i ) {
						push @protocol_scores, $score
						  ; # The "DEFAULT" cipher is being tested, i.e. the protocol itself
					} else {
						push @cipher_scores,
						  $score;    # A particular cipher is being tested
					}
					print " - successfull - $score\n";
					$enabled = 1;
				} else {
					print " - unsuccessfull\n";
					$enabled = 0;
					$score   = '';
				}
			}
			if ( @cipher_scores > 0 ) {

				# We got some cipher scores
				my ( $cipher_score, $cipher_grade ) =
				  grade_result(@cipher_scores);

				print "\n\n";
				print "$protocol cipher score: $cipher_score ($cipher_grade)\n";
				print "\n\n";
			} else {
				print "\n\n";
				print "$protocol not supported by server\n";
				print "\n\n";
			}
		}
		if ( @protocol_scores > 0 ) {
			my ( $protocol_score, $protocol_grade ) =
			  grade_result(@protocol_scores);
			print "Protocol score: $protocol_score ($protocol_grade)\n";
			print "\n\n";
		}
	} else {
		print "Hostname missmatch\n";
	}
} else {
	print "$host:$port is not responding";
}

exit;
