#!/usr/bin/perl
use strict;
my $STEP = 100;

open(OUT, ">", "R_I.dat");
open(IN_R, "<", "R.dat") or die $!;
my @R_lines = <IN_R>;
chomp(@R_lines);
close(IN_R);

for (my $i = 0; $i <= $STEP; $i++){
	print OUT "$i $R_lines[$i]";

	open(IN, "<", "plot-data/STEP$i.dat");
	my @lines = <IN>;
	close(IN);
	chomp(@lines);
	my @line = split(/\s+/, $lines[0]);
	print OUT " $line[1] $line[2] $line[3] $line[6] $line[9]";
	
	my @line = split(/\s+/, $lines[65160]);
	print OUT " $line[1] $line[2] $line[3] $line[6] $line[9]\n";
}
close(OUT);

system("sort -n -k 2 R_I.dat > R_I_sort.dat");

open(MKPDF, ">", "R_I.plt");

print MKPDF "set terminal pdfcairo"."\n";
print MKPDF "set output \"R_I.pdf\"\n";
#print MKPDF "set terminal png\n";
#print MKPDF "set out \"R_I.png\"\n";
#print MKPDF "file = \"R_I_sort.dat\"\n";
print MKPDF "file = \"R_I.dat\"\n";
print MKPDF "unset key\n";
print MKPDF "set title \"100eV\"\n";
print MKPDF "set format \"%2.1f\"\n";
print MKPDF "set ytics 0.1\n";
#print MKPDF "set xr[1.0:4.2]\n";
print MKPDF "set encoding iso\n";
print MKPDF "set xlabel \"R [\\305]\"\n";
print MKPDF "set ylabel \"I_B/I_F\"\n";
print MKPDF "\n";
print MKPDF "plot file u 1:((\$10+\$11+\$12)/3.0)/((\$5+\$6+\$7)/3.0) w linespoints pointtype 7 pointsize 0.3\n";

close(MKPDF);

system("gnuplot R_I.plt");
system("magick -density 300 R_I.pdf -layers flatten R_I.png");

close(OUT);
