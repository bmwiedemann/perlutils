#!/usr/bin/perl -ws

use strict;
use common;

sub cat {
   while(<>) {
      print;
   }
}

sub tac {
   my @lines=<>;
   print reverse @lines;
}

sub rev {
   while(<>) {
      chop;
      print pack("C*",reverse(unpack("C*",$_))),"\n";
   }
}

sub sort {
   my @lines=<>;
   print sort @lines;
}

sub uniq {
   my $lastline;
   my $d=0; # dups
   while(<>) {
      my $bool=($lastline && $lastline eq $_); $bool+=0;
      $lastline=$_;
      if($bool^$d) {next}
      print;
   }
}

sub head {
#   for(my $i=0; $i<$n; ++$i) {
#      print $line;
#   }
}

sub installutils {
}

dispatch;
