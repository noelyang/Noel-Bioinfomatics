#!/bin/perl
# This script filters sequence shorter than given length. If your sequence is 80bp per line, please use fasnochangeline.pl to process it first.
# By Noel Yang.

use warnings;
use strict;

my $usage = "perl $0 input output length
Only sequences longer than the given length will be written to the output.
If your sequence is formatted 80 bp per line, please use fasnochangeline.pl to process it first.
"

my ($input, $output, $lengh) = @ARGV;
open(INPUT,"<$input");
open(OUTPUT,">$output");
while(<INPUT>){
	chomp($_);
	if(/^>/){
		my $tag = $_;
	}else{
		my $seq = $_;
		if(length($seq) ge $length){
			syswrite(OUTPUT,"$tag\n$seq\n")
		}
	}
}
close(INPUT);
close(OUTPUT);