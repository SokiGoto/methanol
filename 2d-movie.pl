#!/usr/bin/perl
use strict;
use List::Util "max", "min";
my $input_file;
my $energy;
my $scale;
my $total_line = 8;
my $xmax;
my $xmin;
my $ymax;
my $ymin;
my $zmax;
my $zmin;

if(-d "2d-plot-data"){system("rm -r 2d-plot-data")};mkdir("2d-plot-data");
if(-d "2d-pdf"){system("rm -r 2d-pdf")};mkdir("2d-pdf");
if(-d "2d-png"){system("rm -r 2d-png")};mkdir("2d-png");
if(-d "2d-output"){system("rm -r 2d-output")};mkdir("2d-output");

&input_parameter;
if ($energy == 2500){
	$scale = 2500;
} elsif ($energy == 100){
	$scale = 30
}
open(IN_STEP, "<", $input_file);
my @lines = <IN_STEP>;
close(IN_STEP);
my $lines_len = @lines;
my $STEP = $lines_len/$total_line;
my $print_STEP = $STEP-1;

open(IN_RANGE, "<", "plot_atom/output-000.plt");
while(my $line = <IN_RANGE>){
        chomp($line);
        $line =~ s/ //g;
        if ($line =~ /sexr/){
                $line =~ /sexr\[(.*):(.*)\]/;
                $xmax = $2;
		$xmin = $1;
        }
        if ($line =~ /seyr/){
                $line =~ /seyr\[(.*):(.*)\]/;
                $ymax = $2;
		$ymin = $1;
        }
        if ($line =~ /sezr/){
                $line =~ /sezr\[(.*):(.*)\]/;
                $zmax = $2;
		$zmin = $1;
        }
}


for(my $i = 0; $i < $STEP; $i++){
	open(IN, "<", "plot-data/STEP$i.dat")or die $!;
	my @lines = <IN>;
	open(OUT, ">", "2d-plot-data/STEP$i.dat");
	for(my $j = 0; $j <= 180; $j++){
		print OUT $lines[$j*362];
		#print OUT $lines[180 + $j*362]."\n";
	}
	print OUT "\n";
	for(my $j = 0; $j <= 180; $j++){
		print OUT $lines[180 + $j*362];
	}
	close(IN);
	close(OUT);

	open (GNU_OUT, ">", "mk_2d-pdf.plt") or die $!;
        print GNU_OUT "set terminal pdfcairo\n";
        print GNU_OUT "set output \"2d-pdf/STEP$i.pdf\"\n";

        print GNU_OUT "set multiplot\n";
	print GNU_OUT "load \"plot_atom/output-".sprintf("%03s",$i).".plt\"\n";
        print GNU_OUT "reset\n";
        print GNU_OUT "file = \"2d-plot-data/STEP$i.dat\"\n";
	print GNU_OUT "set polar\n";
	print GNU_OUT "set origin 0, 0.045\n";
        print GNU_OUT "set angles degree\n";
	#print GNU_OUT "set view ,,2\n";
	#print GNU_OUT "set title \"STEP$i\"\n";
	#print GNU_OUT "unset title\n";
	#print GNU_OUT "set rrange[0:0.004]\n"; #2500eV
	#print GNU_OUT "set rrange[0:0.2]\n"; #100eV
        print GNU_OUT "set title \" \"\n";
        print GNU_OUT "unset key\n";
	#print GNU_OUT "set origin 0.005, -0.005\n"; #ROT1,2
	#print GNU_OUT "set origin 0.005, 0\n"; #NON-ROT
	print GNU_OUT "se xr[$xmin:$xmax]"."\n";
        print GNU_OUT "se yr[$ymin:$ymax]"."\n";
        print GNU_OUT "se zr[$zmin:$zmax]"."\n";
        print GNU_OUT "se rr[0:".max($xmax,$ymax,$zmax)."]"."\n";
        print GNU_OUT "\n";
        print GNU_OUT "unse border\n";
        print GNU_OUT "unse xtics\n";
        print GNU_OUT "unse ytics\n";
        print GNU_OUT "unse ztics\n";
        print GNU_OUT "\n";

	#print GNU_OUT "set pm3d\n";
        #print GNU_OUT "set style fill transparent solid 0 noborder\n";
        #print GNU_OUT "set pm3d depthorder\n";
        #print GNU_OUT "set pm3d lighting specular 0.5\n";
        #print GNU_OUT "se palette rgbformulae 7,5,15\n";
        #print GNU_OUT "set palette cubehelix start -0.15 cycles 1 saturation 3\n";
        #print GNU_OUT "set palette gamma 3\n";
        #print GNU_OUT "unse colorbox\n";
	
        print GNU_OUT "scale = $scale\n";
        print GNU_OUT "set size square\n";
        print GNU_OUT "set view equal xyz\n";
        print GNU_OUT "set view 90, 0, 1, 1\n";
	#print GNU_OUT "splot file u (scale*(\$3+\$6+\$9)/3.0)*sin(\$1)*cos(\$2):(0*scale*(\$3+\$6+\$9)/3.0)*sin(\$1)*sin(\$2):(scale*(\$3+\$6+\$9)/3.0)*cos(\$1) w l\n";
	print GNU_OUT "plot file u (\$2!=180 ? -\$1+90 : \$1+90):(scale*(\$3+\$6+\$9)/3.0) w l\n";
        #print GNU_OUT "(scale*(\$3+\$6+\$9)/3.0)*cos(\$1): \\ \n";
        #print GNU_OUT "scale*(\$3+\$6+\$9)/3.0 w pm3d \n";
        close(GNU_OUT);
	system("gnuplot mk_2d-pdf.plt");
	my $command_PDFtoPNG = "convert -density 300 -flatten ./2d-pdf/STEP$i.pdf ./2d-png/STEP-".
		sprintf("%03d",$i).".png";
        system($command_PDFtoPNG);
	print "end $i/$print_STEP\n";
}

system("magick -delay 50 ./2d-png/STEP-*.png ./2d-output/output.gif");
my $command_GIFtoMP4 = "ffmpeg -r 2 -i ./2d-output/output.gif  -movflags faststart -pix_fmt yuv420p -vf ".
                                "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./2d-output/output.mp4";
system($command_GIFtoMP4);

sub input_parameter {
	open(IN, "<", "input_methanol.txt");
	while(my $line = <IN>){
		chomp($line);
		$line =~ s/ //g;
		if ($line =~ /structure_file/){
                        $line =~ /structure_file="(.*)"/;
                        $input_file = $1;
                }
		if ($line =~ /energy/){
			$line =~ /energy="(.*)".*/;
			$energy = $1;
		}
	}
}


