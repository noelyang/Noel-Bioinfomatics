#!/bin/perl
# Convert 80-bp per line fasta file into no change line fasta file.
# By Noel Yang

my $usage = "perl $0 input output
";

die $usage if @AGRV < 1;

my ($input, $output) = @ARGV;
open(INPUT,"<$input");
open(OUTPUT,">$output");
my $test = 0;
while(<INPUT>){
	if(/^>/){
		if($test eq 1){
			syswrite(OUTPUT,"\n");
		}
		syswrite(OUTPUT,$_);
		$test = 1;
	}else{
		chomp($_);
		my $tmp = $_;
		syswrite(OUTPUT,$tmp);
	}
}
close(INPUT);
close(OUTPUT);
