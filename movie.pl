#!/usr/bin/perl
use strict;
use List::Util 'max', 'min';

my $output_file = "output";
my $input_file;
my $energy;
my $STEP;
my $scale;
my $absorbing_atom;
#my $scale = 2500; #2500eV
#my $scale = 30; #100eV
my $cbrmax = 6;

my $Number_of_atoms = 6;
my $extra_line = 2;
my $total_line = $Number_of_atoms + $extra_line;
my $set_view = "se view 90, 0, 1, 1";

my $xmax = 0;
my $xmin = 0;
my $ymax = 0;
my $ymin = 0;
my $zmax = 0;
my $zmin = 0;
my $rO = 0.5794375693;
my $rC = 0.6239214294;
my $rH = 0.4555414633;
my $r_max = max($rO, $rC, $rH);
my $mode = 3; #mode=1 only atom ,mode=2 only spectra, mode=3 atom and spectra
my $log_01 = 0;

&option;
&input_parameter;
if ($energy == 2500){
	$scale = 4000;
} elsif ($energy == 100){
	$scale = 30
}
&check_range;
&movie_atom;

sub option{
	if (my ($result) = grep { $ARGV[$_] eq '-help' } 0 .. $#ARGV) {
                print "movie.pl program make atom and spectra movie.\n";
                print "--------------------------------------------------------------------------\n";
                print "options\n";
                print "  -o [filename]  |name output file\n";
                print "  -mode [number] |make movie mode. 1:atom only 2:spectra only 3(defult):atom and spectra\n";
		print "  -log           |Leave a log\n";
                print "  -version, -v   |display version information\n";
                print "  -help          |show help\n";
                exit(0);
        }

	if (my ($result) = grep { $ARGV[$_] eq '-version' || $ARGV[$_] eq '-v' } 0 .. $#ARGV) {
                print "movie.pl 1.0.0\n";
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

	if (my ($result) = grep { $ARGV[$_] eq '-log' } 0 .. $#ARGV) {
                my $log_01 = 1;
                splice(@ARGV, $result, 1);
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
        
	if (my ($result) = grep { $ARGV[$_] eq '-mode' } 0 .. $#ARGV) {
                if ($ARGV[$result + 1]) {
                        $mode = $ARGV[$result + 1];
			if ($mode != 1 && $mode != 2 && $mode != 3){
				print "mode = 1 or 2 or 3.\n";
				exit(1);
			}
                        splice(@ARGV, $result, 2);
                } else {
                        print "Please enter mode.\n";
                        exit(1);
                }
        }

        if (@ARGV == 1){
                $input_file = $ARGV[0];
        } elsif (@ARGV != 0) {
                print "Please chack option.\n";
                exit(1);
        }
}

sub input_parameter {
        open(IN, "<", "input_methanol.txt");
        while(my $line = <IN>){
                chomp($line);
                $line =~ s/ //g;
                if ($line =~ /^structure_file/){
                        $line =~ /structure_file="(.*)"/;
                        $input_file = $1;
                }
                if ($line =~ /^energy/){
                        $line =~ /energy="(.*)".*/;
                        $energy = $1;
                }
                if ($line =~ /^absorbing_atom/){
                        $line =~ /absorbing_atom="(.*)".*/;
                        $absorbing_atom = $1;
                }
        }
}

sub check_range{
	open(IN, "<", $input_file) or die ("$input_file : $!");
	my @lines = <IN>;
	close (IN);
	my $lines_len = @lines;
	$STEP = $lines_len/($Number_of_atoms+$extra_line);
	if ($mode == 3 || $mode == 1){
		chomp(@lines);
		@lines = grep(!/^\s*$/, @lines);
		for (my $i=0; $i < $lines_len/($Number_of_atoms+$extra_line); $i++) {
        	       my $var = $i*$total_line;
                       my $O_x;
                       my $O_y;
                       my $O_z;

        	       for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
			       my @data = split(/\s+/, $lines[$var + $j]);
                        	if ($data[0] eq $absorbing_atom){
                                	$O_x = $data[1];
                                	$O_y = $data[2];
                                	$O_z = $data[3];
                        	}
                	}
                	for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
                        	my @data = split(/\s+/, $lines[$var + $j]);
                        	$data[1] = $data[1]-$O_x;
                        	$data[2] = $data[2]-$O_y;
                        	$data[3] = $data[3]-$O_z;

        	               if ($xmax == 0 and $xmin == 0 and $ymax == 0 
					       and $ymin == 0 and $zmax == 0 and $zmin == 0) {
                        		my $xmax = $data[1] + $r_max;
		                        my $xmin = $data[1] - $r_max;
		                        my $ymax = $data[2] + $r_max;
	        	                my $ymin = $data[2] - $r_max;
	                	        my $zmax = $data[3] + $r_max;
	                        	my $zmin = $data[3] - $r_max;
				}
		        	if ($data[1] + $r_max > $xmax) {$xmax = $data[1] + $r_max}
	                	if ($data[1] - $r_max < $xmin) {$xmin = $data[1] - $r_max}
	                	if ($data[2] + $r_max > $ymax) {$ymax = $data[2] + $r_max}
	                	if ($data[2] - $r_max < $ymin) {$ymin = $data[2] - $r_max}
	                	if ($data[3] + $r_max > $zmax) {$zmax = $data[3] + $r_max}
	                	if ($data[3] - $r_max < $zmin) {$zmin = $data[3] - $r_max}
        	        }
        	}
		#print "$xmax : $xmin : $ymax : $ymin : $zmax : $zmin \n";
	}

	if ($mode == 2 || $mode == 3){
        	for (my $i = 0; $i < $STEP; $i++) {
			if (!-d "plot-data"){
				print "You should run spec calculation.\n";
				exit(1);
			}
        	        open(CHECK, "<", "./plot-data/STEP$i.dat")or die $!;
        	        while(my $line = <CHECK>){
        	                my @data = split(/\s+/, $line);
				#print "$data[0] : $data[1] : $data[2] : $data[3] : $data[4] : ".
				#	"$data[5] : $data[6] : $data[7] : $data[8] : $data[9]\n";
        	                my $x = ($scale*($data[3]+$data[6]+$data[9])/3.0)*sin($data[1])*cos($data[2]);
        	                my $y = ($scale*($data[3]+$data[6]+$data[9])/3.0)*sin($data[1])*sin($data[2]);
        	                my $z = ($scale*($data[3]+$data[6]+$data[9])/3.0)*cos($data[1]);
        	                if ($xmax == 0 and $xmin == 0 and $ymax == 0
						and $ymin == 0 and $zmax == 0 and $zmin == 0 ) {
        	                        $xmax = $x;
        	                        $xmin = $x;
        	                        $ymax = $y;
        	                        $ymin = $y;
        	                        $zmax = $z;
        	                        $zmin = $z;
        	                }
        	                if ($x > $xmax) {$xmax = $x}
        	                if ($x < $xmin) {$xmin = $x}
        	                if ($y > $ymax) {$ymax = $y}
        	                if ($y < $ymin) {$ymin = $y}
        	                if ($z > $zmax) {$zmax = $z}
        	                if ($z < $zmin) {$zmin = $z}
        	        }
        	}
		#print "$xmax : $xmin : $ymax : $ymin : $zmax : $zmin \n";
	}
        close(CHECK);
}


sub movie_atom{
        if (-d "plot_atom"){system("rm -r plot_atom/")}
	if ($mode == 1 || $mode == 3){mkdir "plot_atom"}
        if (-d "plot_spectra"){system("rm -r plot_spectra/")}
	if ($mode == 2 || $mode == 3){mkdir "plot_spectra"}
        if (-d "pdf"){system("rm -r pdf/")} mkdir "pdf";
        if (-d "png"){system("rm -r png/")} mkdir "png";
        if (!-d "output"){mkdir "output"};
	if (-f "output/$output_file.mp4"){system("rm output/$output_file.mp4")}

        open(IN, "<", $input_file) or die ("$input_file : $!");
        my @lines = <IN>;
        close (IN);
        chomp(@lines);
        @lines = grep(!/^\s*$/, @lines);
        my $lines_len = @lines;

        for (my $i=0; $i < $lines_len/($Number_of_atoms+$extra_line); $i++) {
                my $var = $i*$total_line;
                my $gnuplot_file = "./plot_atom/$output_file-".sprintf("%03s", $i).".plt";
                my $pdf_file = "./pdf/$output_file-".sprintf("%03s", $i).".pdf";
                my $png_file = "./png/$output_file-".sprintf("%03s", $i).".png";


		if ($mode == 1 || $mode == 3){
                	open(OUT, ">", $gnuplot_file) or die "$!";
                	print OUT "set title \"".$lines[$var + 1]."\"\n";
                	print OUT ''."\n";
                	print OUT 'unse key'."\n";
                	print OUT 'set pm3d'."\n";
                	print OUT 'set pm3d depthorder'."\n";
                	print OUT 'set pm3d lighting specular 0.7'."\n";
                	print OUT 'se isosamples 5'."\n";
                	print OUT 'unse border'."\n";
                	print OUT 'unse xtics'."\n";
                	print OUT 'unse ytics'."\n";
                	print OUT 'unse ztics'."\n";
                	print OUT 'unse colorbox'."\n";
                	print OUT ''."\n";
                	print OUT '# 球面データファイル'."\n";
                	print OUT 'set parametric'."\n";
                	print OUT 'set urange [-0.1:pi]'."\n";
                	print OUT 'set vrange [0:2*pi]'."\n";
                	print OUT 'set samples 30'."\n";
                	print OUT 'set isosamples 30'."\n";
                	print OUT 'sphere="sphere_xyz.dat"'."\n";
                	print OUT 'set table sphere'."\n";
                	print OUT 'splot sin(u)*cos(v), sin(u)*sin(v), cos(u)'."\n";
                	print OUT 'unset table'."\n";
                	print OUT ''."\n";
                	print OUT '# 色分け関数'."\n";
                	print OUT 'u0 = pi/4'."\n";
                	print OUT 'v0 = 0'."\n";
                	print OUT 'x0 = sin(u0)*cos(v0); y0 = sin(u0)*sin(v0); z0 = cos(u0)'."\n";
                	print OUT 'rr(x,y,z) = (x-x0)**2 + (y-y0)**2 + (z-z0)**2'."\n";
                	print OUT 'f(x,y,z) =  exp(-rr(x,y,z)/2);'."\n";
                	print OUT 'H(x,y,z) = 0.2*f(x,y,z) '."\n";
                	print OUT 'O(x,y,z) = 0.2*f(x,y,z)+0.38'."\n";
			print OUT 'C(x,y,z) = 0.2*f(x,y,z)+1.0'."\n";
                	print OUT ''."\n";
                	print OUT 'set palette cubehelix start 0.5 cycles -1.5 saturation 3'."\n";
                	print OUT ''."\n";
                	print OUT '#'."\n";
                	print OUT 'set macro'."\n";
                	print OUT 'Hx = "rH*($1)"; Hy = "rH*($2)"; Hz = "rH*($3)"; H = "H($1,$2,$3)"'."\n";
                	print OUT 'Ox = "rO*($1)"; Oy = "rO*($2)"; Oz = "rO*($3)"; O = "O($1,$2,$3)"'."\n";
                	print OUT 'Cx = "rC*($1)"; Cy = "rC*($2)"; Cz = "rC*($3)"; C = "C($1,$2,$3)"'."\n";
                	print OUT "rO = $rO"."\n";
                	print OUT "rC = $rC"."\n";
                	print OUT "rH = $rH"."\n";
                	#print OUT "se xr[-$xmax:$xmax]"."\n";
                	#print OUT "se yr[-$ymax:$ymax]"."\n";
                	#print OUT "se zr[-$zmax:$zmax]"."\n";
                	print OUT "se xr[$xmin:$xmax]"."\n";
                	print OUT "se yr[$ymin:$ymax]"."\n";
                	print OUT "se zr[$zmin:$zmax]"."\n";
                	print OUT 'se ticslevel 0'."\n";
                	print OUT 'se view equal xyz'."\n";
                	print OUT $set_view."\n";
                	print OUT "splot \\"."\n";

                	my $O_x;
                	my $O_y;
                	my $O_z;
                	for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
                	        my @data = split(/\s+/, $lines[$var + $j]);
                	        if ($data[0] eq $absorbing_atom){
                	                $O_x = $data[1];
                	                $O_y = $data[2];
                	                $O_z = $data[3];
                	        }
                	}
                	for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
                	        my @data = split(/\s+/, $lines[$var + $j]);
                	        print OUT "sphere u (@".
                	        $data[0]."x+ ".($data[1]-$O_x)."):(@".
                	        $data[0]."y+ ".($data[2]-$O_y)."):(@".
                	        $data[0]."z+ ".($data[3]-$O_z)."):(@".$data[0].') w pm3d , \\'."\n";
			}
			close(OUT);
		}
		
		if ($mode == 2 || $mode == 3){
			my $gnuplot_spe = "./plot_spectra/$output_file-".sprintf("%03s", $i).".plt";

			open (SPE_OUT, ">", $gnuplot_spe) or die $!;
                	print SPE_OUT "file = \"plot-data/STEP$i.dat\"\n";
                	print SPE_OUT "set angles degree\n";
                	print SPE_OUT "set view equal xyz\n";
                	#print SPE_OUT "set view 90, 0, 2, 2\n";
			#print SPE_OUT "unset title\n";
                	print SPE_OUT "$set_view\n";
                	print SPE_OUT "unset key\n";
                	#print SPE_OUT "set origin 0, 0\n";
                	print SPE_OUT "\n";
                	print SPE_OUT "unse border\n";
                	print SPE_OUT "unse xtics\n";
                	print SPE_OUT "unse ytics\n";
                	print SPE_OUT "unse ztics\n";
                	print SPE_OUT "set xrange[$xmin:$xmax]\n";
                	print SPE_OUT "set yrange[$ymin:$ymax]\n";
                	print SPE_OUT "set zrange[$zmin:$zmax]\n";
                	print SPE_OUT "\n";
                	print SPE_OUT "set pm3d\n";
                	print SPE_OUT "set style fill transparent solid 0.15 noborder\n";
                	print SPE_OUT "set pm3d depthorder\n";
                	print SPE_OUT "set pm3d lighting specular 0.5\n";
                	print SPE_OUT "se palette rgbformulae 7,5,15\n";
                	print SPE_OUT "set palette cubehelix start -0.15 cycles 1 saturation 3\n";
                	print SPE_OUT "set palette gamma 3\n";
                	print SPE_OUT "unse colorbox\n";
                	print SPE_OUT "scale = $scale\n";
                	print SPE_OUT "set cbr[0:$cbrmax]";
                	print SPE_OUT "\n";
                	print SPE_OUT "splot file u \\\n";
                	print SPE_OUT "(scale*(\$3+\$6+\$9)/3.0)*sin(\$1)*cos(\$2): \\\n";
                	print SPE_OUT "(scale*(\$3+\$6+\$9)/3.0)*sin(\$1)*sin(\$2): \\\n";
                	print SPE_OUT "(scale*(\$3+\$6+\$9)/3.0)*cos(\$1): \\\n";
                	print SPE_OUT "(scale*(\$3+\$6+\$9)/3.0) \\\n";
                	print SPE_OUT "w pm3d \n";
                	#print SPE_OUT "(scale*(\$3+\$6+\$9)/3.0)*cos(\$1): \\ \n";
                	#print SPE_OUT "scale*(\$3+\$6+\$9)/3.0 w pm3d \n";
                	close(SPE_OUT);
		}

                open(MK_PDF, ">", "mk_pdf.plt");
                print MK_PDF "set terminal pdfcairo\n";
                print MK_PDF "set output \"./pdf/$output_file-".sprintf("%03s", $i).".pdf\"\n";
                print MK_PDF "set multiplot\n";
		if ($mode == 1 || $mode == 3){
	                print MK_PDF "load \"./plot_atom/$output_file-".sprintf("%03s", $i).".plt\"\n";
		}
		if ($mode == 2 || $mode == 3){
                	print MK_PDF "load \"./plot_spectra/$output_file-".sprintf("%03s", $i).".plt\"\n";
		}
                close(MK_PDF);
                system("gnuplot mk_pdf.plt");
                system("magick -density 300 $pdf_file -layers flatten $png_file");
                my $print_STEP = $STEP-1;
                print("Finished $i/$print_STEP\n");
        }

        my $command_PNGtoGIF = "magick -delay 100 ./png/$output_file-*.png ./output/$output_file.gif";
        system($command_PNGtoGIF);
        print "Finished png to gif.\n";

        my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/$output_file.gif".
                                "  -movflags faststart -pix_fmt yuv420p -vf ".
                                "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/$output_file.mp4";

        system($command_GIFtoMP4);
        print "Finished gif to mp4.\n";
	if ($log_01 = 0){
        	system("rm mk_pdf.plt");
	}
}
