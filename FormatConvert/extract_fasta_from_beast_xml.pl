#!/bin/perl -w
# Noel Yang, 23/06/2015
# Extract fasta files from multi-sample BEAST xml file.

use strict;
use warnings;

my $usage = "perl $0 input taxonNum
";
my ($input) = @ARGV;
die $usage if @ARGV < 1;


my @geneList = ();
my @taxonList = ();
my @seqList = ();
my $seqIdentifier = 0;
my $seq = "";
my $alignmentIdentifier = 0;


open(INPUT,"<$input");
while(<INPUT>){
	if(/\t\<!\-\-\sgene\sname\s\=\s(\w+),.*/){
		my $geneName = $1;
		push(@geneList,$geneName);
		print $#geneList."\n";
	}

	if(/\t\<alignment.*/){
		my $gene = shift(@geneList);
		my $filename = $gene.".fasta";
		open(OUTPUT,">$filename");
	}

	if(/\t\t\t\<taxon\sidref\=\"(.*)\"\/\>/){
		my $taxonId = $1;
		syswrite(OUTPUT,">$taxonId\n")
	}

	if(/\t\t\<sequence\>/){
		$seqIdentifier = 1;
	}
	if((/\t\t\t([\w,-]+)/) && $seqIdentifier eq 1){
		my $tmp = $1;
		$seq = $seq.$tmp;
	}
	
	if(/\t\t\<\/sequence\>/){
		$seqIdentifier = 0;
		syswrite(OUTPUT,"$seq\n");
		$seq = "";
	}

	if(/\t\<\/alignment\>/){
		close(OUTPUT);
	}

}
close(INPUT);
