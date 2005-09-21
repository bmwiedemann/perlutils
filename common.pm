# this provides functionality used by various perlutils

sub usage() {
   print "usage: ...TODO\n";
   exit 1;
}

sub dispatch() {
   (my $basename=$0)=~s!.*/!!;
#print $basename;
   my $function=shift(@ARGV);
   usage unless defined $function;
   eval "&$function";
}

1;
