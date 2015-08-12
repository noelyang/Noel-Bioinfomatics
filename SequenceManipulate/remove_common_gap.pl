#!/usr/bin/perl -w
# Script to remove common gaps in multi-alignment.
# By Noel Yang

use warnings;
use strict;

my $usage = "perl $0 input output cutRatio
This script is designed to remove the common gaps in multi-alignment files
cutRatio: positions with gap/all ratio greater than the cutRatio will be removed.
";
die $usage if @ARGV < 2;

my ($input, $output, $cutratio) = @ARGV;
my @gap_pos = ();
my $tmpread ="";
my @temparray = ();
my $primaryLen = 0;

open(INPUT,"<$input");
while(<INPUT>){
	if(/^>/) {next;}
	else{
		chomp($_);
		$tmpread = $_;
		$primaryLen = length($tmpread);
		last;
	}
}
close(INPUT);

for( my $i = 0; $i < $primaryLen ; $i++ ){
	$gap_pos[$i] = 0;
}

open(INPUT,"<$input");
my $j=0;
while(<INPUT>){
	if(/^>/) {next;}
	else{
		chomp($_);
		$tmpread = $_;
		@temparray = split("" , $tmpread);
		for( my $i = 0; $i < $primaryLen ; $i++ ){
			if ($temparray[$i] eq "-"){
				$gap_pos[$i]++;
			}
		}
		$j++;
	}
}
close(INPUT);

for( my $i = 0; $i < $primaryLen ; $i++){
	$gap_pos[$i] = $gap_pos[$i]/$j;
	print $gap_pos[$i]."\n";
}

open(INPUT,"<$input");
open(OUTPUT,">$output");
my $first=1;
while(<INPUT>){
	chomp($_);
	if(/^>/) {
		if($first eq 1){
			syswrite(OUTPUT, "$_\n");
			$first = 0;
		}else{
			syswrite(OUTPUT, "\n$_\n");
		}
	}else{
		$tmpread = $_;
		@temparray = split("" , $tmpread);
		for( my $i = 0; $i < $primaryLen ; $i++ ){
			if($gap_pos[$i] <= $cutratio){
				syswrite(OUTPUT,"$temparray[$i]");
			}
		}
	}
}
close(INPUT);
close(OUTPUT);
