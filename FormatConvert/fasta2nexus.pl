#!/bin/perl -w
# This is a quick-and-dirty script to convert Fasta files to Nexus files.
# By Noel, 25/11/2013
# Contact nevrfa#gmail.com

use strict;
use warnings;

my $usage ="
perl $0 input output \n
";

die $usage if @ARGV < 2;

my ($input, $output) = @ARGV;
my @tags = ();
my @seqs = ();
my @tmp = ();

open(INPUT, "<$input");
my $first = 1;
while(<INPUT>){
	if(/^>(.*)/){
		my $tmpTag = $1;
		if($first ne 1){
			my $tmpseq = join("", @tmp);
			push(@seqs, $tmpseq);
			@tmp = ();
		}
		$tmpTag =~ s/\((\d{1,})\)/$1/g;
		push(@tags, $tmpTag);
		$first = 0;
	}else{
		chomp($_);
		push(@tmp, $_)
	}
}
close(INPUT);
my $tmpseq = join("", @tmp);
my $seqlength = length($tmpseq);
my $ntax = $#tags + 1;
push(@seqs, $tmpseq);

open(OUTPUT, ">$output");
my $header = "#NEXUS
BEGIN DATA;
dimensions ntax=$ntax nchar=$seqlength;
format missing=?
interleave=yes datatype=DNA gap=- match=.;

matrix
";

syswrite(OUTPUT, $header);
for(my $j=0; $j<=$#tags; $j+= 1){
	syswrite(OUTPUT, "$tags[$j]\t$seqs[$j]\n");
}
syswrite(OUTPUT,"\n");

my $tail =";
end;
";
syswrite(OUTPUT,$tail);
close(OUTPUT);