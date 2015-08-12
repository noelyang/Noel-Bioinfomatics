#!/usr/bin/perl
# Pick sub-algnment.
# By Noel Yang.

use warnings;
use strict;

my $usage = "---------------------------------------------------------------------------
perl $0 input output_prefix Cut_Position

This script is designed to pick out subalignment from a huge alignment file.
Cut_Position: format should be like Start:End for each subalignment
---------------------------------------------------------------------------
";
die $usage if @ARGV < 3;

my $input = shift(@ARGV);
my $outputPre= shift(@ARGV);
my @cutPosition = @ARGV;
my $tmpread = "";
my $tmpwrite = "";

for( my $i = 0; $i <= $#cutPosition; $i++ ){
	my ($start, $end) = split(":", $cutPosition[$i]);
	my $j = $i + 1;
	$start -= 1;
	$end -= 1;
	my $cutLength = $end - $start + 1;
	my $output = $outputPre."$j.fa";
	open(INPUT,"<$input");
	open(OUTPUT,">$output");
	while(<INPUT>){
		chomp($_);
		if(/^>/){
			syswrite(OUTPUT,"$_\n");
		}
		else{
			$tmpread = $_;
			$tmpwrite = substr($tmpread, $start, $end);
			syswrite(OUTPUT,"$tmpwrite\n");
		}
	}
	close(INPUT);
	close(OUTPUT);
}