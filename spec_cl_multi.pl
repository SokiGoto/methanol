#!/usr/bin/perl
#version 2.0
use strict;
use Cwd 'getcwd';

my $cd = getcwd;
my $energy;
my $ELUM;
my $spec;
my $multi = 3;

my $specplot_path = "~/PROGRAM/MsSpec/spec_2019Mar/spec/res/treatment/specplot";

&input_parameter;
&option;

if (-d "plot-data") {system("rm -r plot-data")}mkdir("plot-data");


my $STEP = 0;
while (1){
	if (!-d "$cd/STEP$STEP/"){
		last;
	}
	$STEP = $STEP + 1;
}



my $multi_STEP = int($STEP/$multi);
my $multi_mod  = $STEP % $multi;

my @pids;
for (my $i = 0; $i < $multi; $i++ ) {
        my $pid = fork;
        if (! defined $pid) {
                die "fork failed\n";
        } elsif (! $pid) {
                process($i);
                exit;
        } else {
                push @pids, $pid;
        }
}
open(OUT, ">", "./pid.txt");
for my $pid (@pids) {
	print OUT "$pid\n";
}
close(OUT);
for my $pid (@pids) {
        waitpid($pid, 0);
}
system("rm $cd/tmp.txt");
print STDERR "finish\n";


########################################################

sub process{my ($process_num) = @_;
	my $for_start = $process_num*$multi_STEP;
	my $for_end   = ($process_num+1)*$multi_STEP;
	if ($process_num == ($multi-1)){
		$for_end = ($process_num+1)*$multi_STEP + $multi_mod;
	}

	my $print_end = $for_end-1;
        print STDERR "subprocess $process_num start : $for_start ~ $print_end\n";
	for (my $i = $process_num*$multi_STEP; $i < $for_end; $i++){
		our $spec_cldir_path = "$cd/STEP$i/spec";
		if (-d "$spec_cldir_path"){
			system("rm -r $spec_cldir_path");
		}
		system ("mkdir $spec_cldir_path");
		system ("mkdir $spec_cldir_path/clus");
		system ("mkdir $spec_cldir_path/res");
		system ("mkdir $spec_cldir_path/data");
		system ("mkdir $spec_cldir_path/div");
		system ("mkdir $spec_cldir_path/div/wf");
		system ("mkdir $spec_cldir_path/plot");
		system ("mkdir $spec_cldir_path/rad");
		system ("mkdir $spec_cldir_path/tl");
		system ("mkdir $spec_cldir_path/result");

		system("cp -rp ./STEP$i/scfdat/clus/clus.out $spec_cldir_path/clus/clus.out");
		system("cp -rp ./STEP$i/scfdat/rad/radmat.out $spec_cldir_path/rad/radmat.out");
		system("cp -rp ./STEP$i/scfdat/tl/tmat.out $spec_cldir_path/tl/tmat.out");
		
		for (my $j = 1; $j <= 3; $j++) {
			for (my $rad = 0; $rad <= 180; $rad++){
				my $direction = &mk_spec_data($spec_cldir_path,$rad,$j);
				chdir("$spec_cldir_path");
				#system("procspec_mi > $cd/tmp.txt");
				#system("procspec_se > $cd/tmp.txt");
				system("$spec > $cd/tmp.txt");
				open(ANSWER, ">", "treatment_answer.txt");
			        print ANSWER "res/res.dat\n";
			        print ANSWER "result/rad-".$direction."-".$rad.".dat\n";
			        print ANSWER "-1\n";
			        print ANSWER "N\n";
			        print ANSWER "N\n";
			        print ANSWER "N\n";
			        print ANSWER "N\n";
			        close(ANSWER);
			        system("$specplot_path < treatment_answer.txt > $cd/tmp.txt");
			        system("rm treatment_answer.txt");
		
				open(FH, "$spec_cldir_path/result/rad-".$direction."-".$rad.".dat") or die $!;
				my @array = <FH>;
				close(FH);
				open(OUT, ">>", "$spec_cldir_path/result/direction-".$direction.".dat");
				for (my $k = 0; $k < @array; $k++){
					print OUT  " ".sprintf("%6.2f",$rad).$array[$k];
				}
				print OUT "\n";
		                close (OUT);
				chdir("$cd");
			}
		}
		system("paste $spec_cldir_path/result/direction-x.dat ".
			"$spec_cldir_path/result/direction-y.dat ".
			"$spec_cldir_path/result/direction-z.dat ".
			"> $cd/plot-data/STEP$i.dat");
		print STDERR "Finished $i in process $process_num\n";
	}
        print STDERR "subprocess $process_num end\n";
}


sub mk_spec_data { # arg (file name path, rad, direction)
	my $rad = sprintf("%.2f",$_[1]);
	my $direction;
	my $IPOL;
	my $THLUM;
	my $PHILUM;
	if ($_[2] == 1){
               $direction = "x";
	       $IPOL = -1;
	       $THLUM = 90.00;
	       $PHILUM = 90.00;
        } elsif ($_[2] == 2) {
               $direction = "y";
	       $IPOL = -1;
	       $THLUM = 90.00;
	       $PHILUM = 0.00;
        } elsif ($_[2] == 3) {
               $direction = "z";
	       $IPOL = 1;
	       $THLUM = 90.00;
	       $PHILUM = 0.00;
        }
	open(REWRITE, ">", "$_[0]/data/spec.dat") or die $!;
	print REWRITE "    ***************************************************************************\n";
	print REWRITE "    *                X-RAY ABSORPTION CALCULATION OF MgO(001)                 *\n";
	print REWRITE "    ***************************************************************************\n";
	print REWRITE "    *=========================================================================*\n";
	print REWRITE "    *                           CRYSTAL STRUCTURE :                           *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *  CUB         P         0         6         CRIST,CENTR,IBAS,NAT         *\n";
	print REWRITE "    *    4.2100    1.000     1.000   ATU         A,BSURA,CSURA,UNIT           *\n";
	print REWRITE "    *   90.00     90.00     90.00                ALPHAD,BETAD,GAMMAD          *\n";
	print REWRITE "    *    0         0         0         1         H,K,I,L                      *\n";
	print REWRITE "    *    8         1.40      0         1         NIV,COUPUR,ITEST,IESURF      *\n";
	print REWRITE "    *    0.000000  0.000000  0.000000   O   8    ATBAS,CHEM(NAT),NZAT(NAT)    *\n";
	print REWRITE "    *    0.000000  0.000000  0.000000   C   6    ATBAS,CHEM(NAT),NZAT(NAT)    *\n";
	print REWRITE "    *    0.000000  0.000000  0.000000   H   1    ATBAS,CHEM(NAT),NZAT(NAT)    *\n";
	print REWRITE "    *    1.000000  0.000000  0.000000            VECBAS                       *\n";
	print REWRITE "    *    0.000000  1.000000  0.000000                                         *\n";
	print REWRITE "    *    0.000000  0.000000  1.000000                                         *\n";
	print REWRITE "    *    0         0         0.0       0.0       IREL,NREL,PCREL(NREL)        *\n";
	print REWRITE "    *   28.00      0.00      1                   OMEGA1,OMEGA2,IADS           *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                          TYPE OF CALCULATION :                          *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *  PHD         0         0        ".sprintf("%2s", $IPOL).
							      "         SPECTRO,ISPIN,IDICHR,IPOL    *\n";
	print REWRITE "    *    1                                       I_AMP                        *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                      PhD EXPERIMENTAL PARAMETERS :                      *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *   1s         0         1         0         LI,S-O,INITL,I_SO            *\n";
	print REWRITE "    *    1         0         0         0         IPHI,ITHETA,IE,IFTHET        *\n";
	print REWRITE "    *  361         1         1         1         NPHI,NTHETA,NE,NFTHET        *\n";
	print REWRITE "    *    0.00    ".sprintf("%6.2f",$rad)."   ".sprintf("%7.2f",$energy).
						       "      0.500     PHI0,THETA0,E0,R0            *\n";
	print REWRITE "    *  360.00    ".sprintf("%6.2f",$rad)."   ".sprintf("%7.2f",$energy).
						       "     -1.000     PHI1,THETA1,E1,R1            *\n";
	print REWRITE "    *  ".sprintf("%6.2f",$THLUM)."    ".sprintf("%6.2f",$PHILUM).
		         "    ".sprintf("%6.2f",$ELUM)."                THLUM,PHILUM,ELUM            *\n";
	print REWRITE "    *    0         0         0.00      0         IMOD,IMOY,ACCEPT,ICHKDIR     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                      LEED EXPERIMENTAL PARAMETERS :                     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *   -1         0         0         0         IPHI,ITHETA,IE,IFTHET        *\n";
	print REWRITE "    *    1        87         1         1         NPHI,NTHETA,NE,NFTHET        *\n";
	print REWRITE "    *    0.00      0.00    184.00      0.500     PHI0,THETA0,E0,R0            *\n";
	print REWRITE "    *  360.00     86.00    250.00     -1.000     PHI1,THETA1,E1,R1            *\n";
	print REWRITE "    *  -55.00      0.00                          TH_INI,PHI_INI               *\n";
	print REWRITE "    *    1         0         1.00      0         IMOD,IMOY,ACCEPT,ICHKDIR     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                     EXAFS EXPERIMENTAL PARAMETERS :                     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *   K1         1       -55.00      0.00      EDGE,INITL,THLUM,PHILUM      *\n";
	print REWRITE "    *   42         0.00     20.50  11103.60      NE,EK_INI,EK_FIN,EPH_INI     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                      AED EXPERIMENTAL PARAMETERS :                      *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *   L2        M2        M2                   EDGE_C,EDGE_I,EDGE_A         *\n";
	print REWRITE "    *    0        1D2                            I_MULT,MULT                  *\n";
	print REWRITE "    *    0         1         0         0         IPHI,ITHETA,IFTHET,I_INT     *\n";
	print REWRITE "    *    1         1         1                   NPHI,NTHETA,NFTHET           *\n";
	print REWRITE "    *    0.00     45.00      0.500               PHI0,THETA0,R0               *\n";
	print REWRITE "    *    0.00     70.00     -1.000               PHI1,THETA1,R1               *\n";
	print REWRITE "    *    1         0         1.00      0         IMOD,IMOY,ACCEPT,ICHKDIR     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                   EIGENVALUE CALCULATION PARAMETERS :                   *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *    1       100.00    100.00      0         NE,EK_INI,EK_FIN,I_DAMP      *\n";
	print REWRITE "    *    0         0         0         0         I_SPECTRUM(NE)               *\n";
	print REWRITE "    *    1      EPSI         0.00100   1.000     I_PWM,METHOD,ACC,EXPO        *\n";
	print REWRITE "    *  200        10         3         0.000     N_MAX,N_ITER,N_TABLE,SHIFT   *\n";
	print REWRITE "    *    1         1         1         1         I_XN,I_VA,I_GN,I_WN          *\n";
	print REWRITE "    *    0         1.00      1.00                L,ALPHA,BETA                 *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                        CALCULATION PARAMETERS :                         *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *    8         1         1         0         NO,NDIF,ISPHER,I_GR          *\n";
	print REWRITE "    *    0         0         9         0         ISFLIP,IR_DIA,ITRTL,I_TEST   *\n";
	print REWRITE "    *    1         1         0         0         NEMET,IEMET(NEMET)           *\n";
	print REWRITE "    *    0         1       100         0.00      ISOM,NONVOL,NPATH,VINT       *\n";
	print REWRITE "    *    0         1         0         0         IFWD,NTHREWRITE,I_NO,I_RA    *\n";
	print REWRITE "    * .. 1        20.00      0        20.00      N_RA,THFWD,IBWD,THBWD(NAT)   *\n";
	print REWRITE "    * .. 1        20.00      0        20.00      N_RA,THFWD,IBWD,THBWD(NAT)   *\n";
	print REWRITE "    * .. 1        20.00      0        20.00      N_RA,THFWD,IBWD,THBWD(NAT)   *\n";
	print REWRITE "    * .. 1        20.00      0        20.00      N_RA,THFWD,IBWD,THBWD(NAT)   *\n";
	print REWRITE "    * .. 1        20.00      0        20.00      N_RA,THFWD,IBWD,THBWD(NAT)   *\n";
	print REWRITE "    * .. 1        20.00      0        20.00      N_RA,THFWD,IBWD,THBWD(NAT)   *\n";
	print REWRITE "    *    0         2         0.0100    2         IPW,NCUT,PCTINT,IPP          *\n";
	print REWRITE "    *    0         2.10    LPU                   ILENGTH,RLENGTH,UNLENGTH     *\n";
	print REWRITE "    *    0         1         0         2         IDWSPH,ISPEED,IATT,IPRINT    *\n";
	print REWRITE "    *    0       420.00    293.00      1.20      IDCM,TD,T,RSJ                *\n";
	print REWRITE "    *   -1        15.00                          ILPM,XLPM0                   *\n";
	print REWRITE "    * .. 0.00000   0.00000   0.00000   0.00000   UJ2(NAT)                     *\n";
	print REWRITE "    * .. 0.00000   0.00000   0.00000   0.00000   UJ2(NAT)                     *\n";
	print REWRITE "    *====+=========+=========+=========+=========+============================*\n";
	print REWRITE "    *                 INPUT FILES (PHD, EXAFS, LEED, AED, APECS) :            *\n";
	print REWRITE "    *-------------------------------------------------------------------------*\n";
	print REWRITE "    *        NAME                    UNIT                TYPE                 *\n";
	print REWRITE "    *====+======================+======+=========+============================*\n";
	print REWRITE "    *    data/spec.dat                 5         DATA FILE                    *\n";
	print REWRITE "    *    tl/tmat.out                   1         PHASE SHIFTS/TL FILE         *\n";
	print REWRITE "    *    rad/radmat.out                3         RADIAL MATRIX ELTS FILE      *\n";
	print REWRITE "    *    clus/clus.out                 4         CLUSTER FILE                 *\n";
	print REWRITE "    *    div/testa.pos                 2         ADSORBATE FILE               *\n";
	print REWRITE "    *    div/dir_test.dat             11         K DIRECTIONS FILE            *\n";
	print REWRITE "    *====+======================+======+=========+============================*\n";
	print REWRITE "    *                     ADDITIONAL INPUT FILES (APECS) :                    *\n";
	print REWRITE "    *                            (AUGER ELECTRON)                             *\n";
	print REWRITE "    *-------------------------------------------------------------------------*\n";
	print REWRITE "    *        NAME                    UNIT                TYPE                 *\n";
	print REWRITE "    *====+======================+======+=========+============================*\n";
	print REWRITE "    *    tl/tl_test2.dat              12         PHASE SHIFTS/TL FILE         *\n";
	print REWRITE "    *    rad/rad_test2.dat            13         RADIAL MATRIX ELTS FILE      *\n";
	print REWRITE "    *    div/dir_test2.dat            14         K DIRECTIONS FILE            *\n";
	print REWRITE "    *====+======================+======+=========+============================*\n";
	print REWRITE "    *                             REWRITEPUT FILES :                          *\n";
	print REWRITE "    *-------------------------------------------------------------------------*\n";
	print REWRITE "    *        NAME                    UNIT                TYPE                 *\n";
	print REWRITE "    *====+======================+======+=========+============================*\n";
	print REWRITE "    *    spec.lis                      6         CONTROL FILE                 *\n";
	print REWRITE "    *    res/res.dat                   9         RESULT FILE                  *\n";
	print REWRITE "    *    scatfac/facdif1.dat           8         SCATTERING FACTOR FILE       *\n";
	print REWRITE "    *    clus/new.clu                 10         AUGMENTED CLUSTER FILE       *\n";
	print REWRITE "    *====+======================+======+=========+============================*\n";
	print REWRITE "    *                          END OF THE DATA FILE                           *\n";
	print REWRITE "    *=========================================================================*\n";
	print REWRITE "    ***************************************************************************\n\n";
	close(REWRITE);
	return $direction;
}

sub input_parameter {
        open(IN, "<", "input_methanol.txt");
        while(my $line = <IN>){
                chomp($line);
                $line =~ s/ |\t//g;
                if ($line =~ /^energy/){
                        $line =~ /energy="(.*)".*/;
                        $energy = $1;
                }
                if ($line =~ /^spec/){
                        $line =~ /spec="(.*)"/;
                        $spec = $1;
                }
                if ($line =~ /^elum/){
                        $line =~ /elum="(.*)"/;
                        $ELUM = $1;
                }
        }
}

sub option{
	if (my ($result) = grep { $ARGV[$_] eq '-help' } 0 .. $#ARGV) {
                print "movie.pl program make atom and spectra movie.\n";
                print "--------------------------------------------------------------------------\n";
                print "options\n";
                print "  -np             |multi num\n";
                print "  -version, -v    |display version information\n";
                print "  -help           |show help\n";
                exit(0);
        }

	if (my ($result) = grep { $ARGV[$_] eq '-version' || $ARGV[$_] eq '-v' } 0 .. $#ARGV) {
                print "movie.pl 1.0.0\n";
                exit(0);
        }

        
	if (my ($result) = grep { $ARGV[$_] eq '-np' } 0 .. $#ARGV) {
                if ($ARGV[$result + 1]) {
                        $multi = int($ARGV[$result + 1]);
			if ($multi < 1){
				print "multi >= 1\n";
				exit(1);
			}
                        splice(@ARGV, $result, 2);
                } else {
                        print "Please enter mode.\n";
                        exit(1);
                }
        }
}
