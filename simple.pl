#!/usr/bin/perl -w
use strict;
use common;

sub date {
   print scalar localtime();
   print "\n";
}

sub perlsh {
   while(<>) {
      eval;
      if($@) {print $@}
   }
}

dispatch();
