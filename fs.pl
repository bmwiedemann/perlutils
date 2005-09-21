#!/usr/bin/perl -w
use strict;
use common;

sub ls {
   my @args=@ARGV;
   if(!@args) { push @args,"." }
   foreach(@args) {
      if(-d) {s/([^\/])$/$1\//;$_.="*";}
      foreach my $file (glob($_)) {
         print "$file\n";
      }
   }
   print "@args\n";
}

dispatch();
