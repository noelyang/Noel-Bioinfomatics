#!/bin/perl -w
# Simple script to change fasta tags with given new tags. Replace with one2one order.
# By Noel Yang.

use strict;
use warnings;

my $usage = "perl $0 fastain tagin fastaout
This is a simple script to change fasta tags.
";
die $usage if @ARGV < 2;

my ($input1 , $input2 , $output) = @ARGV;

open(INPUT1,"<$input1");
open(INPUT2,"<$input2");
open(OUTPUT,">$output");

my @tags=();

while(<INPUT1>){
	push(@tags, $_);
}
close(INPUT1);

my $i=0;
while(<INPUT2>){
	if(/^>/){
		syswrite(OUTPUT,$tags[$i]);
		$i += 1;
	}else{
		syswrite(OUTPUT,$_);
	}
}

close(INPUT2);
close(OUTPUT);
