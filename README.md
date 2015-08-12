# Noel's Bioinfomatic Toolbox

Hi there, this is a personal repository which contains some scripts I used in my bioinformatic research.
All the solutions are dirty and quick. If you want some more functions, email me.

Current scripts:

> FormatConvert
	* fasta2nexus.pl: A quick-and-dirty script to convert Fasta files to Nexus files.
	* nex2nwk.pl: Simple script to convert nexus trees into newick trees. BioPerl is required.
	* extract_fasta_from_beast_xml.pl: Extract fasta files from multi-sample BEAST xml file.

> SequenceManipulate
	* changetags.pl: Simple script to change fasta tags with given new tags.
	* fasnochangeline.pl: Convert 80/100-bp-per-line fasta file into no change line fasta file.
	* lengthfilter.pl: This script filters sequence shorter than given length.
	* merge_sequences.pl: combine multiple fasta file into one (only merge sequences with same tags and in the same order).
	* pick_subalignment.pl: Pick out subalignment from a huge alignment file.
	* remove_common_gap.pl: Remove common gaps in multi-alignment. You can define a cut ratio.
	
	
Enjoy!
