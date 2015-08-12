#!/bin/perl -w
# combine multiple fasta file into one (only merge sequences with same tag)
# By Noel Yang.

use strict;
use warnings;

my $usage = "perl $0 inputs output
";

my $output = pop(@ARGV);
my @inputs = @ARGV;
my @seqs = ();
my @tags = ();
my $j = 0;

for(my $i=0;$i le $#inputs;$i++){
	$j = 0;
	open(INPUT,"<$inputs[$i]");
	while(<INPUT>){
		chomp();
		my $readline = $_;
		if(/^>/){
			if($i==0){
				push(@tags, $readline);
			}
		}else{
			$seqs[$j] .= $readline;
			$j++;
		}	
	}
	close(INPUT);
}

open(OUTPUT,">$output");
for(my $m=0; $m <= $#seqs; $m++){
	syswrite(OUTPUT,"$tags[$m]\n$seqs[$m]\n");
}
close(OUTPUT);
