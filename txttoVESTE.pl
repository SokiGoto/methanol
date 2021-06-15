#!/usr/bin/perl
use strict;

#dos2unix filename.*** <- code CR+LF to LF
#iconv -f sjis -t utf8 ***.txt -o ***.txt  <- encoding sjis to utf-8

my $input_file = "input.txt";
my $output_file = "output.txt";

my $total_line = 7;

&option;
&rewrite_check;

if (!open(IN, "<", $input_file)){
	print ("not found $input_file\n");
}

my @lines;
while(<IN>){
	if ($_ !~ /^\s*$/){
		push(@lines, $_);
	}
}
my $lines_len = @lines;
open(OUT, ">", "output.txt");
for (my $i = 0; $i < $lines_len/$total_line; $i++){
	print OUT "6\n";
	my $var = $i * $total_line;
	for (my $j = 0; $j < 7; $j++){
		print OUT "$lines[$var+$j]";
	}
}
close(IN);
close(OUT);
################# subrotine ##########################
sub option{
	if (my ($result) = grep { $ARGV[$_] eq '-help' } 0 .. $#ARGV) {
		print "txttoVESTA.pl program convert txt format files to VESTA format.\n";
		print "--------------------------------------------------------------------------\n";
		print "options\n";
		print "  -o [filename] |name output file\n";
		print "  -l [number]   |determine the number of lines to separate\n";
		print "  -version      |display version information\n";
		print "  -help         |show help\n";
		exit(0);
	}

	if (my ($result) = grep { $ARGV[$_] eq '-version' } 0 .. $#ARGV) {
		print "scfdat_cl.pl 1.0.0\n";
                exit(0);
        }

        if (my ($result) = grep { $ARGV[$_] eq '-o' } 0 .. $#ARGV) {
                if ($ARGV[$result + 1]) {
                        $output_file = $ARGV[$result + 1];
                        splice(@ARGV, $result, 2);
                } else {
                        print "Please enter output file name.\n";
                        exit(1);
                }
        }

	
        if (my ($result) = grep { $ARGV[$_] eq '-l' } 0 .. $#ARGV) {
                if ($ARGV[$result + 1]) {
                        $total_line = $ARGV[$result + 1];
                        splice(@ARGV, $result, 2);
                } else {
                        print "Please enter the number of lines to separete.\n";
                        exit(1);
                }
        }

        if (@ARGV == 1){
                $input_file = $ARGV[0];
        } elsif(@ARGV == 0){
	} else {
                print "Please chack option.\n";
                exit(1);
        }
}

sub rewrite_check{
	if (-f $output_file){
		print "File '$output_file' already exists. Overwrite ? [y/N]  ";
		&yes_no;
	}
}

sub yes_no{
        my $in = <STDIN>;
        chomp($in);
        if ($in eq 'yes' || $in eq 'y') {
		print "";
        } elsif ($in eq 'N' || $in eq 'n' || $in eq 'no' || $in eq '') {
                print "Cancel\n";
                exit(1);
        } else {
                print "Plese enter y or N.\n";
                &yes_no();
        }
}
