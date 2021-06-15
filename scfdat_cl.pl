#!/usr/bin/perl
use strict;
use Cwd 'getcwd';


my $input_file;
my $output_file;

my $log_01 = 0;

my $Number_of_atoms = 6;
my $extra_line = 2;
my $total_line = $Number_of_atoms + $extra_line;
my $cheaker = 0;
my $print;
my $flag = 0;


#my $rO = 0.566892;
#my $rH = 0.451732;
#my $rC = 0.598745;
my $rO = 0.403114;
my $rH = 0.491432;
my $rC = 0.628338;

my $energy;
my $lmax_mode;
my $lmax;
my $sort_atom;


&option;
&input_parameter;
my $cd = getcwd;

my $log_file = 'log.out';
open(RM, ">", $log_file);
close(RM);

open(IN, "<", $input_file);
my @lines = <IN>;
my $lines_len = @lines;
my $STEP = $lines_len/$total_line;
for (my $i = 0; $i < $lines_len/$total_line; $i++){
	if (!-d "STEP$i"){
		system ("mkdir STEP$i");
	}
	if (-d "STEP$i/scfdat"){
		system ("rm -r STEP$i/scfdat");
	}
	mkdir("STEP$i/scfdat");
	mkdir("STEP$i/scfdat/clus");
	mkdir("STEP$i/scfdat/data");
	mkdir("STEP$i/scfdat/div");
	mkdir("STEP$i/scfdat/div/wf");
	mkdir("STEP$i/scfdat/plot");
	mkdir("STEP$i/scfdat/rad");
	mkdir("STEP$i/scfdat/tl");

	#system ("cp -rp common/scfdat ./STEP$i");
	open (OUT, ">", "./STEP$i/scfdat/data/data3.ms");
	$cheaker = 0;
	$flag = 0;
	print OUT "&job\n";
	print OUT "calctype='xpd',\n";
	print OUT "emin=".sprintf("%7.2f",$energy).",\n";
	print OUT "emax=".sprintf("%7.2f",$energy).",\n";
	print OUT "enunit=' ev',\n";
	print OUT "delta=0.3,\n";
	print OUT "ovlpfac=0.0,\n";
	print OUT "potgen='in',\n";
	print OUT "potype='hdrel',\n";
	print OUT "relc='nr',\n";
	print OUT "norman='extrad',\n";
	print OUT "lmax_mode=$lmax_mode,\n";
	print OUT "lmaxt=$lmax,\n";
	print OUT "edge='k',\n";
	print OUT "coor='angs',\n";
	print OUT "gamma=0.01,\n";
	print OUT "charelx='ex',\n";
	print OUT "ionzst='neutral'\n";
	print OUT "&end\n";
	print OUT "\n";
	print OUT "\n";
	print OUT "\n";
	
	my $var = $i*$total_line;
	if(! $sort_atom  eq "" ){
		for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
			if ($lines[$var + $j] =~ /$sort_atom/){
				&print_out($sort_atom, $lines[$var + $j]);
				print OUT $print;
				$flag = 1;
			} elsif ($flag == 1) {
				my @read_atom = split(/ +/, $lines[$var + $j]);
				&print_out($read_atom[0], $lines[$var + $j]);
        	                print OUT $print;
			} elsif ($flag == 0) {
				$cheaker = $cheaker + 1;
			}
		}
		for (my $j = $extra_line; $j < $cheaker + $extra_line; $j++){
			my @read_atom = split(/ +/, $lines[$var + $j]);
			&print_out($read_atom[0], $lines[$var + $j]);
        	        print OUT $print;	
		}
	} else {
		for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
                        my @read_atom = split(/ +/, $lines[$var + $j]);
                        &print_out($read_atom[0], $lines[$var + $j]);
                        print OUT $print;
                }
	}
	print OUT "	"."-1  -1        0.       0.       0.      0.";
	close(OUT);
	#print "$cd/STEP$i/scfdat/\n";
	chdir("$cd/STEP$i/scfdat/");
	print "finished $i/".($STEP-1)."\n";
	#system("pwd");
	system("procfase3_nosym >> $cd/$log_file");
	chdir("$cd");
}
close(IN);
if ($log_01 == 0){
	system("rm -r $log_file");
}
#system("./spec_cl.pl $lines_len $Number_of_atoms $extra_line");




########################################################################
sub input_parameter {
	open(IN, "<", "input_methanol.txt");
	while(my $line = <IN>){
		chomp($line);
		$line =~ s/ |\t//g;
		if ($line =~ /^structure_file/){
                        $line =~ /structure_file="(.*)"/;
                        $input_file = $1;
                }
		if ($line =~ /^energy/){
			$line =~ /energy="(.*)".*/;
			$energy = $1;
		}
		if ($line =~ /^lmax/){
			$line =~ /lmax="(.*)".*/;
			$lmax = $1;
		}
		if ($line =~ /^lmax_mode/){
			$line =~ /lmax_mode="(.*)".*/;
			$lmax_mode = $1;
		}
		if ($line =~ /^absorbing_atom/){
			$line =~ /absorbing_atom="(.*)".*/;
			$sort_atom = $1;
		}
	}
}

sub print_out{
	my $atomic_number;
	my $atomic_radius;
	chomp($_[1]);
	my @out = split(/ /,$_[1],2);
	if ($_[0] eq 'H'){
		$atomic_number = 1;
		#$number = 0.451732;
		$atomic_radius = $rH;
	} elsif ($_[0] eq 'C'){
                $atomic_number = 6;
		#$number = 0.598745;
                $atomic_radius = $rC;
	} elsif ($_[0] eq 'O'){
                $atomic_number = 8;
		#$number = 0.566892;
                $atomic_radius = $rO;
	}
	$print = "\t $out[0]  $atomic_number  $out[1]  $atomic_radius\n";
}




sub option{
	if (my ($result) = grep { $ARGV[$_] eq '-help' } 0 .. $#ARGV) {
		print "-o [filename] |name output file\n";
		print "-E [Energy]   |Determine kinetic energy of photoelectron\n";
		print "-log          |Leave a log\n";
		print "-version      |display version information";
		print "-help         |Show optin\n";
		exit(0);
	}

	if (my ($result) = grep { $ARGV[$_] eq '-version' } 0 .. $#ARGV) {
		print "scfdat_cl.pl 2.0.0\n";
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

	if (my ($result) = grep { $ARGV[$_] eq '-E' } 0 .. $#ARGV) {
                if ($ARGV[$result + 1]) {
                        $energy = $ARGV[$result + 1];
                        splice(@ARGV, $result, 2);
                } else {
                        print "Please enter energy.\n";
                        exit(1);
                }
	}

	if (my ($result) = grep { $ARGV[$_] eq '-log' } 0 .. $#ARGV) {
		$log_01 = 1;
		splice(@ARGV, $result, 1);
	}

        if (@ARGV == 1){
                $input_file = $ARGV[0];
        } elsif (@ARGV != 0) {
                print "Please chack option.\n";
                exit(1);
        }
}
