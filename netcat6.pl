#!/usr/bin/perl -w
use strict;
use IO::Socket;
use IO::Socket::INET6;
use IO::Select;
use Time::HiRes qw(gettimeofday tv_interval);
use Getopt::Long;

my %options=qw(
timeout	1
);
my @options=qw(broadcast|b listen|l port|p=i udp|u timeout|w=i source|s=s verbose|v+);
my ($sent,$rcvd)=(0,0);

if(!GetOptions(\%options, @options)) {die "invalid option on commandline. @ARGV\n"}
my $sock;
my @opts=(Proto=>$options{udp}?"udp":"tcp");
if($options{source}) {
	push(@opts, LocalAddr=>$options{source});
}
if($options{broadcast}) {
	push(@opts, Broadcast=>1);
}
if($options{port}) {
	push(@opts, LocalPort=>$options{port});
}


if($options{listen}) {
	if(!$options{udp}) {push(@opts, Listen=>1)}
	$sock=IO::Socket::INET6->new(@opts, ReuseAddr=>1) or die "$@\n";
	if($options{udp}) {
		my $firstmsg;
		$sock->recv($firstmsg, 65535);
		print $firstmsg;
		my $sender=$sock->peerhost();
		my $pport=$sock->peerport();
		#print "incoming $sender : $pport : $firstmsg\n";
		push(@opts, PeerPort=>$pport, PeerAddr=>$sender);
		$sock=IO::Socket::INET6->new(@opts, ReuseAddr=>1) or die "$@\n";
	} else {
		$sock=$sock->accept();
	}
} else {
	my $paddr=shift;
	my $pport=shift;
	if(!$paddr || !$pport) {
		usage();
		exit 1;
	}

	$sock=IO::Socket::INET6->new(@opts, PeerAddr=>$paddr, PeerPort=>$pport, Timeout=>$options{timeout}) or die "$@ $!";
	if($options{verbose}) {
		printf("%s [%s] %i (%s) open\n", "", $sock->peerhost(), $sock->peerport(), "TODO");
	}
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
		if(!$numbytes) { 
		   # we are done when the remote socket is closed
			if($fd == $sock) { last MAINLOOP }
			$willexit++; $sel->remove($fd); close($fd); $exittime||=[gettimeofday()]; next FDLOOP; }
		syswrite($outfd, $data, $numbytes);
		if($fd == $sock) { $rcvd+=$numbytes }
		else { $sent+=$numbytes }
	}
}

if($options{verbose}) {
	print " sent $sent, rcvd $rcvd\n";
}
