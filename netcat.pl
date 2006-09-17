#!/usr/bin/perl -w
use strict;
use IO::Socket;
use IO::Select;
use Time::HiRes qw(gettimeofday tv_interval);
use Getopt::Long;

my %options=qw(
timeout	1
);
my @options=qw(listen|l port|p=i udp|u);

if(!GetOptions(\%options, @options)) {die "invalid option on commandline. @ARGV\n"}
my $sock;
my $proto=$options{udp}?"udp":"tcp";
if($options{listen}) {
	$sock=IO::Socket::INET->new(Proto=>$proto, Listen=>1, ReuseAddr=>1, LocalPort=>$options{port}) or die "$@\n";
	$sock=$sock->accept();
} else {
	my $paddr=shift;
	my $pport=shift;
	if(!$paddr || !$pport) {
		usage();
		exit 1;
	}

	$sock=IO::Socket::INET->new(Proto=>$proto, PeerAddr=>$paddr, PeerPort=>$pport) or die "$@ $!";
}
my $sel=IO::Select->new($sock, \*STDIN);
my $willexit=0;
my $exittime;

MAINLOOP:
while(1) {
	my @ready = $sel->can_read(1);
	if($willexit>1 || ($willexit && tv_interval($exittime)>$options{timeout})) {last}
   FDLOOP:
	foreach my $fd (@ready) {
		my $outfd=$sock;
		if($fd == $sock) { $outfd=\*STDOUT }
		my $data;
		my $numbytes=sysread($fd, $data, 65000);
		if(!$numbytes) { $willexit++; $sel->remove($fd); close($fd); $exittime||=[gettimeofday()]; next FDLOOP; }
		syswrite($outfd, $data, $numbytes);
	}
}

