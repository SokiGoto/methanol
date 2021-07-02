#!/usr/bin/perl
use strict;
use Math::Trig;
use Math::Trig ":radial";
use File::Path 'rmtree';


my $Number_of_atoms = 6;
my $extra_line = 2;
my $total_line = $Number_of_atoms + $extra_line;
my $input_file;


#my $energy = 100;

my $energy;
my $peak_wide;


my $OH_peak;
my $CH_peak;
my @save_C;

#my $OH_peak = 59.00;
#my $CH_peak = 61.00;
my $output = 3;

&input_parameter();

my @xrange;
my @yrange;
my $scale_C;
my $scale_O;
if ($energy == 2500){
	@xrange = (-0.0015, 0.0015);
	@yrange = (-0.0015, 0.0015);
	$scale_C = 0.0015;
	$scale_O = 0.003;
} elsif ($energy == 100) {
	@xrange = (-0.2, 0.2);
	@yrange = (-0.2, 0.2);
	$scale_C = 0.2;
	$scale_O = 0.2;
}

open(STR, "<", $input_file) or die $!;
my @lines = <STR>;
chomp(@lines);
@lines = grep(!/^\s*$/, @lines);
my $lines_len = @lines;
my $STEP = $lines_len/$total_line;

if (-d "point"){rmtree("point")};
mkdir("./point");
if (-d "point_pdf"){rmtree("point_pdf")};
mkdir("./point_pdf");
if (-d "./point_png"){rmtree("point_png")};
mkdir("point_png");
if (-d "./point_plt"){rmtree("./point_plt")};
mkdir("point_plt");
mkdir("output");

if (-d "point_plt/atom_triangle/"){rmtree("point_plt/atom_triangle/")}mkdir("point_plt/atom_triangle");

open(TEST, ">", "test.dat");
close(TEST);
open(TEST, ">", "point/point_all.dat");
close(TEST);
open(OUT, ">", "theta12.dat");
close(OUT);
for (my $i = 0; $i < $STEP; $i++){
	my $var = $i*$total_line;
	### move_x,y,z is coordinate of O atom in input file.
        my ($move_x, $move_y, $move_z);
	my $C_r;


	my ($C_x, $C_y, $C_z);
	my ($H_x, $H_y, $H_z);
	my ($O_x, $O_y, $O_z);

	my $theta12;

        for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
        	my @data = split(/\s+/, $lines[$var + $j]);
        	if ($data[0] eq "O"){
                         $move_x = $data[1];
                         $move_y = $data[2];
                         $move_z = $data[3];
			 #print "$move_x  :  $move_y : $move_z\n";
			 last;
                }
        }
	for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
		my @data = split(/\s+/, $lines[$var + $j]);
        	if ($data[0] eq "C"){
                	my $C_r_x = $data[1] - $move_x;
                        my $C_r_y = $data[2] - $move_y;
                        my $C_r_z = $data[3] - $move_z;
			$C_r = sqrt($C_r_x*$C_r_x + $C_r_y*$C_r_y + $C_r_z*$C_r_z);
			#print " C_r = $C_r \n";
			last;
        	}
	}
	open(OUT, ">>", "test.dat");
	for (my $j = 0; $j < $extra_line; $j++){
		 print OUT $lines[$var + $j]."\n";
		 #print $lines[$var + $j]."\n";
	}
	for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
		my @data = split(/\s+/, $lines[$var + $j]);
		if ($data[0] eq "O"){
			my $x = $data[1] - $move_x;
                        my $y = $data[2] - $move_y;
                        my $z = $data[3] - $move_z;
                        print OUT $data[0]."  ".sprintf("%9.6f", $x)."  ".
			sprintf("%9.6f", $y)."  ".sprintf("%9.6f", $z)."\n";

			$O_x = $x;
			$O_y = $y;
			$O_z = $z;

                        #print $data[0]."  ".$x."  ".$y."  ".$z."\n";
		} elsif ($data[0] eq "H" && $data[2] == 0){
			my $x = $data[1] - $move_x;
	                my $y = $data[2] - $move_y;
	                my $z = $data[3] - $move_z;
	
	                my $r_;
	                my $theta_;
	                my $phi_;
	                my $x_;
	                my $y_;
	                my $z_;
	                ($r_, $theta_, $phi_) = cartesian_to_spherical($x, $y, $z);
	                ($x_, $y_, $z_) = spherical_to_cartesian($r_/$C_r, $theta_, $phi_);
	                #print $data[0]."  ".$x_."  ".$y_."  ".$z_."\n";
	                print OUT $data[0]."  ".sprintf("%9.6f", $x_)."  ".sprintf("%9.6f", $y_).
			"  ".sprintf("%9.6f", $z_)."\n";

			$H_x = $x_;
			$H_y = $y_;
			$H_z = $z_;
		} elsif ($data[0] eq "C"){
			my $x = $data[1] - $move_x;
	                my $y = $data[2] - $move_y;
	                my $z = $data[3] - $move_z;
			#print "$x : $y : $z \n";
	
	                my $r_;
	                my $theta_;
	                my $phi_;
	                my $x_;
	                my $y_;
	                my $z_;
	                ($r_, $theta_, $phi_) = cartesian_to_spherical($x, $y, $z);
	                ($x_, $y_, $z_) = spherical_to_cartesian($r_/$C_r, $theta_, $phi_);
			($save_C[$i][0], $save_C[$i][1], $save_C[$i][2]) = ($x_, $y_, $z_);
			#print "$save_C[$i][0]  $save_C[$i][1]\n";
	                #print $data[0]."  ".$x_."  ".$y_."  ".$z_."\n";
	                print OUT $data[0]."  ".sprintf("%9.6f", $x_)."  ".sprintf("%9.6f", $y_).
			"  ".sprintf("%9.6f", $z_)."\n";

			$C_x = $x_;
			$C_y = $y_;
			$C_z = $z_;
		} else {
			my $x = $data[1] - $move_x;
                	my $y = $data[2] - $move_y;
                	my $z = $data[3] - $move_z;
			
			my $r_;
			my $theta_;
			my $phi_;
			my $x_;
			my $y_;
			my $z_;
			($r_, $theta_, $phi_) = cartesian_to_spherical($x, $y, $z);
			($x_, $y_, $z_) = spherical_to_cartesian($r_/$C_r, $theta_, $phi_);
			#print $data[0]."  ".$x_."  ".$y_."  ".$z_."\n";
			print OUT $data[0]."  ".sprintf("%9.6f", $x_)."  ".
			sprintf("%9.6f", $y_)."  ".sprintf("%9.6f", $z_)."\n";
		}
	}
	close(OUT);
	my $file = "point/point".sprintf("%03d", $i).".dat";
	open(POINT, ">", $file);
	print POINT "H  ".sprintf("%9.6f", $H_x)."  ".sprintf("%9.6f", $H_y)."  ".sprintf("%9.6f", $H_z)."\n";
	print POINT "C  ".sprintf("%9.6f", $C_x)."  ".sprintf("%9.6f", $C_y)."  ".sprintf("%9.6f", $C_z)."\n";
	print POINT "O  ".sprintf("%9.6f", $O_x)."  ".sprintf("%9.6f", $O_y)."  ".sprintf("%9.6f", $O_z)."\n\n";
	close(POINT);

	
	my $file = "point_plt/atom_triangle/point".sprintf("%03d", $i).".plt";
	open(POINT, ">", $file);
	if ($output == 2){
		print POINT "set terminal pdfcairo\n";
		print POINT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
	}
	print POINT "\n";
	print POINT "set xr[-2:2]\n";
	print POINT "set yr[-2:2]\n";
	print POINT "set arrow 1 from ".sprintf("%9.6f", $H_x).", ".sprintf("%9.6f", $H_z)." to ".sprintf("%9.6f", $C_x).", ".sprintf("%9.6f", $C_z)." nohead linestyle 2 lc \"green\"\n";
	print POINT "set arrow 2 from ".sprintf("%9.6f", $H_x).", ".sprintf("%9.6f", $H_z)." to ".sprintf("%9.6f", $O_x).", ".sprintf("%9.6f", $O_z)." nohead linestyle 2 lc \"green\"\n";
	print POINT "set arrow 3 from ".sprintf("%9.6f", $C_x).", ".sprintf("%9.6f", $C_z)." to ".sprintf("%9.6f", $O_x).", ".sprintf("%9.6f", $O_z)." nohead linestyle 2 lc \"green\"\n";
	print POINT "unset key\n";
	print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $H_x).", ".sprintf("%9.6f", $H_z).") pt 7 lc \"green\" title \"atom\"\n";
	close(POINT);
	if ($output == 2){
 		system("gnuplot $file");
		system("magick -density 300 point_pdf/output-".sprintf("%03d", $i).".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
	}

	open(POINT_ALL, ">>", "point/point_all.dat");
	print POINT_ALL "H  ".sprintf("%9.6f", $H_x)."  ".sprintf("%9.6f", $H_y)."  ".sprintf("%9.6f", $H_z)."\n";
	print POINT_ALL "C  ".sprintf("%9.6f", $C_x)."  ".sprintf("%9.6f", $C_y)."  ".sprintf("%9.6f", $C_z)."\n";
	print POINT_ALL "O  ".sprintf("%9.6f", $O_x)."  ".sprintf("%9.6f", $O_y)."  ".sprintf("%9.6f", $O_z)."\n\n";
	close(POINT_ALL);

	open(OUT, ">>", "theta12.dat");
	#my $H_r = $H_x*$H_x + $H_y*$H_y + $H_z*$H_z;
	#my $O_r = $O_x*$O_x + $O_y*$O_y + $O_z*$O_z;
	#my $C_r = $C_x*$C_x + $C_y*$C_y + $C_z*$C_z;
	my @HO = ($O_x - $H_x, $O_y - $H_y, $O_z - $H_z);
	my @HC = ($C_x - $H_x, $C_y - $H_y, $C_z - $H_z);

	my $HO_r = sqrt($HO[0]*$HO[0] + $HO[1]*$HO[1] + $HO[2]*$HO[2]);
	my $HC_r = sqrt($HC[0]*$HC[0] + $HC[1]*$HC[1] + $HC[2]*$HC[2]);
	my $HOHC = $HO[0]*$HC[0] + $HO[1]*$HC[1] + $HO[2]*$HC[2];
	my $theta12_ = rad2deg(acos(($HOHC)/($HO_r*$HC_r)));
	$theta12 = acos(($HC[0]*$HO[0] + $HC[1]*$HO[1] + $HC[2]*$HO[2])/(sqrt($HC[0]*$HC[0] + $HC[1]*$HC[1] + $HC[2]*$HC[2])*sqrt($HO[0]*$HO[0] + $HO[1]*$HO[1] + $HO[2]*$HO[2])));
	print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", $theta12_)."\n";
	close(OUT);
	#print "finished $i\n";

}
if ($output == 2){
	my $command_PNGtoGIF = "magick -delay 100 ./point_png/output-*.png ./output/output_point.gif";
	system($command_PNGtoGIF);
	print "Finished png to gif.\n";
	my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/output_point.gif".
                        "  -movflags faststart -pix_fmt yuv420p -vf ".
                        "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/atom_triangle.mp4";
	system($command_GIFtoMP4);
	print "Finished gif to mp4.\n";
}

#for (my $i = 0; $i < $STEP; $i++){
#	#print "../C_100eV/2d-plot-data/STEP$i.dat\n";
#	open(IN_C, "<", "../C_100eV/2d-plot-data/STEP$i.dat") or die $!;
#	my @lines = <IN_C>;
#	$data_j = @lines;
#	for (my $j = 0; $j < $data_j; $j++){
#		chomp($lines[$j]);
#		my @line_split = split(/\s+/, $lines[$j]);
#		$data[$i][$j][1] = $line_split[1];
#		$data[$i][$j][2] = $line_split[2];
#		$data[$i][$j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3;
#		#print "$i:$j\n";
#	}
#	close(IN_C);
#}
#if (-d "C_test"){rmtree("C_test")};mkdir("C_test");
#for (my $i = 0; $i < $STEP; $i++){
#	open(OUT_C, ">", "C_test/STEP$i.dat") or die $!;
#	open(OUT_PEAK, ">", "C_test/STEP$i\_PEAK.dat") or die $!;
#	for (my $j; $j < $data_j; $j++){
#		print OUT_C sprintf("%6.2f", $data[$i][$j][1])."  ".sprintf("%6.2f", $data[$i][$j][2])."  ".sprintf("%7.5f", $data[$i][$j][3])."\n";
#		print "  ".($j + 1)%($STEP)." \n";
#		if ($data[$i][$j-1][3] < $data[$i][$j][3] && $data[$i][($j + 1)%($STEP)][3] < $data[$i][$j][3]){
#			$peak[$i][$j][1] = $data[$i][$j][1];
#			$peak[$i][$j][2] = $data[$i][$j][2];
#			$peak[$i][$j][3] = $data[$i][$j][3];
#			print OUT_PEAK sprintf("%6.2f", $peak[$i][$j][1])."  ".sprintf("%6.2f", $peak[$i][$j][2])."  ".sprintf("%7.5f", $peak[$i][$j][3])."\n";
#		}
#
#	}
#	print "end j\n";
#	close(OUT_C);
#	close(OUT_PEAK);
#}

my $data_j;
my @data;
my @peak_C;
if (-d "C_test"){rmtree("C_test")};mkdir("C_test");
if (-d "point_plt/C/"){rmtree("point_plt/C/")}mkdir("point_plt/C");
if (-d "point_png/"){rmtree("point_png/")}mkdir("point_png/");
if (-d "point_pdf/"){rmtree("point_pdf/")}mkdir("point_pdf/");
for(my $i = 0; $i < $STEP; $i++){
        open(IN, "<", "../C_".$energy."eV/plot-data/STEP$i.dat")or die $!;
        my @lines = <IN>;
	chomp(@lines);
        for(my $j = 0; $j <= 180; $j++){
		my $line = $lines[$j*362];
		#chomp($line);
		#print "$line\n";
                my @line_split = split(/\s+/, $line);
		$data[$i][$j][1] = $line_split[1];
                $data[$i][$j][2] = $line_split[2];
                $data[$i][$j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3.0;
		#print "@line_split\n";
		#print "$data[$i][$j][3]\n";
		#print OUT $lines[$j*362];
                #print OUT $lines[180 + $j*362]."\n";
        }
        print OUT "\n";
        for(my $j = 0; $j <= 180; $j++){
		#my $line = $lines[-$j*362 - 2];
		my $line = $lines[-$j*362-182];
		#chomp($line);
		#print "$line\n";
                my @line_split = split(/\s+/, $line);
                $data[$i][180 + $j][1] = $line_split[1];
                $data[$i][180 + $j][2] = $line_split[2];
                $data[$i][180 + $j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3.0;
		#print "@line_split\n"
        }
        close(IN);
	
	open(OUT_DIFF, ">", "C_test/STEP$i\_diff.dat") or die $!;
	for(my $j = 0; $j <= 180; $j++){
		my $diff = $data[$i][$j][3] - $data[$i][360 - $j][3];
		print OUT_DIFF sprintf("%6.2f", $data[$i][$j][1]).
		         "  ".sprintf("%6.2f", $data[$i][$j][2])."  ".sprintf("%9.6f", $diff)."\n"
		#my ($diff_x, $diff_y, $diff_z) = spherical_to_cartesian($diff,
                #                        deg2rad($peak_C[$i][$j][2]), deg2rad($peak_C[$i][$j][1]));
		#print OUT_DIFF sprintf("%9.6f", $diff_x + $save_C[$i][0]).
		#	"  ".sprintf("%9.6f", $diff_z + $save_C[$i][2])."\n";
	}
	close(OUT_DIFF);
}
for (my $i = 0; $i < $STEP; $i++){
        open(OUT_C, ">", "C_test/STEP$i.dat") or die $!;
        open(OUT_PEAK, ">", "C_test/STEP$i\_PEAK.dat") or die $!;
	open(OUT_VALLEY, ">", "C_test/STEP$i\_VALLEY.dat") or die $!;

	### make .plt ###
	open(PLT, ">", "point_plt/C/STEP$i.plt") or die $!;
	#print PLT "set terminal pdfcairo\n";
	#print PLT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
	print PLT "file = \"C_test/STEP$i.dat\"\n";
	print PLT "set title \"STEP$i\"\n";
	print PLT "set polar\n";
	print PLT "set angles degree\n";
	#print PLT "set xr[-0.002:0.002]\n";
	#print PLT "set yr[-0.002:0.002]\n";
	print PLT "set xr[$xrange[0]:$xrange[1]]\n";
	print PLT "set yr[$yrange[0]:$yrange[1]]\n";
	print PLT "set size square\n";
	print PLT "unset key\n";
	print PLT "\n";
	### end .plt ###


        for (my $j = 0; $j <= 2 * 180; $j++){
                print OUT_C sprintf("%6.2f", $data[$i][$j][1])."  ".sprintf("%6.2f", $data[$i][$j][2])."  ".sprintf("%10.8f", $data[$i][$j][3])."\n";
		#print "".($j%(2*180)-1)."  ".($j)%(2*180)."  ".($j + 1)%(2*180)." \n";
		#print "STEP $i  theta $j \n";
		#print "$data[$i][$j-1][3]    $data[$i][$j][3]   $data[$i][($j + 1)%(2*180)][3] \n";
                if ($data[$i][$j-1][3] < $data[$i][$j][3] && $data[$i][($j + 1)%(2*180)][3] < $data[$i][$j][3]){
                        $peak_C[$i][$j][1] = $data[$i][$j][1];
                        $peak_C[$i][$j][2] = $data[$i][$j][2];
                        $peak_C[$i][$j][3] = $data[$i][$j][3];
                        print OUT_PEAK sprintf("%6.2f", $peak_C[$i][$j][1])."  ".sprintf("%6.2f", $peak_C[$i][$j][2])."  ".sprintf("%9.6f", $peak_C[$i][$j][3])."\n";


			### make .plt ###
			my ($x, $y, $z) = spherical_to_cartesian($peak_C[$i][$j][3], $peak_C[$i][$j][1], $peak_C[$i][$j][2]);
			#print PLT "set arrow from 0,0 to ".($peak[$i][$j][1]).",".($peak[$i][$j][3])." nohead \n";
			### end .plt #####
                }
		if ($data[$i][$j-1][3] > $data[$i][$j][3] && $data[$i][($j + 1)%(2*180)][3] > $data[$i][$j][3]){
                        print OUT_VALLEY sprintf("%6.2f", $data[$i][$j][1])."  ".sprintf("%6.2f", $data[$i][$j][2])."  ".sprintf("%9.6f", $data[$i][$j][3])."\n";
                }

        }
	print PLT "plot file u (\$2!=180  ? - \$1+90 : \$1+90):3 w l ,\\\n";
	print PLT " \"C_test/STEP$i\_PEAK.dat\" u (\$2!=180  ? - \$1+90 : \$1+90):3 with impulses,\\\n";
	print PLT " \"C_test/STEP$i\_VALLEY.dat\" u (\$2!=180  ? - \$1+90 : \$1+90):3 with impulses\n";
	#print "STEP = $i\n";
	#print "scalar".scalar(@{$peak[$i]})."\n";
        close(OUT_C);
        close(OUT_PEAK);
	close(PLT);

	#==== move output =====
	if($output == 1){
		my $file = "point_plt/C/STEP$i.plt";
		system("gnuplot $file");
        	system("magick -density 300 point_pdf/output-".sprintf("%03d", $i).
			".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
	}
	#=========================
}

#========================================= movie output =======================================
if ($output == 1){
	if (-d "output"){rmtree("output")};mkdir("output");
	my $command_PNGtoGIF = "magick -delay 100 ./point_png/output-*.png ./output/output_point.gif";
	system($command_PNGtoGIF);
	print "Finished png to gif.\n";
	
	my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/output_point.gif".
	                        "  -movflags faststart -pix_fmt yuv420p -vf ".
	                        "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/C_peak.mp4";
	
	system($command_GIFtoMP4);
	print "Finished gif to mp4.\n";
}
#==============================================================================================

my $data_j;
my @data;
my @peak_O;
#=============== O =============
if (-d "O_test"){rmtree("O_test")};mkdir("O_test");
#if (-d "point_plt"){rmtree("point_plt")}mkdir("point_plt");
if (-d "point_plt/O"){rmtree("point_plt/O")}mkdir("point_plt/O");
if (-d "point_png/"){rmtree("point_png/")}mkdir("point_png/");
if (-d "point_pdf/"){rmtree("point_pdf/")}mkdir("point_pdf/");

for(my $i = 0; $i < $STEP; $i++){
        open(IN, "<", "../".$energy."eV/plot-data/STEP$i.dat")or die $!;
        my @lines = <IN>;
	chomp(@lines);
        for(my $j = 0; $j <= 180; $j++){
		my $line = $lines[$j*362];
		#chomp($line);
		#print "$line\n";
                my @line_split = split(/\s+/, $line);
		$data[$i][$j][1] = $line_split[1];
                $data[$i][$j][2] = $line_split[2];
                $data[$i][$j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3;
		#print "@line_split\n";
		#print "$data[$i][$j][3]\n";
		#print OUT $lines[$j*362];
                #print OUT $lines[180 + $j*362]."\n";
        }
        print OUT "\n";
        for(my $j = 0; $j <= 180; $j++){
		#my $line = $lines[-$j*362 - 2];
		my $line = $lines[-$j*362-182];
		#chomp($line);
		#print "$line\n";
                my @line_split = split(/\s+/, $line);
                $data[$i][180 + $j][1] = $line_split[1];
                $data[$i][180 + $j][2] = $line_split[2];
                $data[$i][180 + $j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3;
		#print "@line_split\n"
        }
        close(IN);

	open(OUT_DIFF, ">", "O_test/STEP$i\_diff.dat") or die $!;
	for(my $j = 0; $j < 180; $j++){
		my $diff = $data[$i][$j][3] - $data[$i][360 - $j][3];
		print OUT_DIFF sprintf("%6.2f", $data[$i][$j][1]).
			"  ".sprintf("%6.2f", $data[$i][$j][2])."  ".sprintf("%9.6f", $diff)."\n";
		#my ($diff_x, $diff_y, $diff_z) = spherical_to_cartesian($diff,
		#                        deg2rad($peak_C[$i][$j][2]), deg2rad($peak_C[$i][$j][1]));
		#print OUT_DIFF sprintf("%9.6f", $diff_x)."  ".sprintf("%9.6f", $diff_z)."\n";
	}
	close(OUT_DIFF);
}

for (my $i = 0; $i < $STEP; $i++){
        open(OUT_C, ">", "O_test/STEP$i.dat") or die $!;
        open(OUT_PEAK, ">", "O_test/STEP$i\_PEAK.dat") or die $!;
	open(OUT_VALLEY, ">", "O_test/STEP$i\_VALLEY.dat") or die $!;

	### make .plt ###
	open(PLT, ">", "point_plt/O/STEP$i.plt") or die $!;
	#	print PLT "set terminal pdfcairo\n";
	#	print PLT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
	print PLT "file = \"O_test/STEP$i.dat\"\n";
	print PLT "set title \"STEP$i\"\n";
	print PLT "set polar\n";
	print PLT "set angles degree\n";
	print PLT "set xr[$xrange[0]:$xrange[1]]\n";
	print PLT "set yr[$yrange[0]:$yrange[1]]\n";
	print PLT "set size square\n";
	print PLT "unset key\n";
	print PLT "\n";


        for (my $j = 0; $j <= 2 * 180; $j++){
                print OUT_C sprintf("%6.2f", $data[$i][$j][1]).
			"  ".sprintf("%6.2f", $data[$i][$j][2])."  ".sprintf("%9.6f", $data[$i][$j][3])."\n";
                if ($data[$i][$j-1][3] < $data[$i][$j][3] && $data[$i][($j + 1)%(2*180)][3] < $data[$i][$j][3]){
                        $peak_O[$i][$j][1] = $data[$i][$j][1];
                        $peak_O[$i][$j][2] = $data[$i][$j][2];
                        $peak_O[$i][$j][3] = $data[$i][$j][3];
                        print OUT_PEAK sprintf("%6.2f", $peak_O[$i][$j][1])."  ".
				sprintf("%6.2f", $peak_O[$i][$j][2])."  ".sprintf("%9.6f", $peak_O[$i][$j][3])."\n";


			### make .plt ###
			my ($x, $y, $z) = spherical_to_cartesian($peak_O[$i][$j][3], 
				$peak_O[$i][$j][1], $peak_O[$i][$j][2]);
			#print PLT "set arrow from 0,0 to ".($peak[$i][$j][1]).",".($peak[$i][$j][3])." nohead \n";
			### end .plt #####
                }
		if ($data[$i][$j-1][3] > $data[$i][$j][3] && $data[$i][($j + 1)%(2*180)][3] > $data[$i][$j][3]){
                        print OUT_VALLEY sprintf("%6.2f", $data[$i][$j][1])."  ".sprintf("%6.2f", $data[$i][$j][2]).
				"  ".sprintf("%9.6f", $data[$i][$j][3])."\n";
		}

        }
	print PLT "pi = 3.1415 \n";
	#print PLT "plot file u (\$3 * sin((\$1/180) * pi) * cos(\$2/180*pi)):((\$3 * cos((\$1/180)*pi))+1) w l\\\n";
	print PLT "plot file u (\$2!=180  ? - \$1+90 : \$1+90):3 w l ,\\\n";
	print PLT " \"O_test/STEP$i\_PEAK.dat\" u (\$2!=180  ? - \$1+90 : \$1+90):3 with impulses ,\\\n";
	print PLT " \"O_test/STEP$i\_VALLEY.dat\" u (\$2!=180  ? - \$1+90 : \$1+90):3 with impulses\n";
	### end .plt ###
	
	#print "STEP = $i\n";
	#print "scalar".scalar(@{$peak[$i]})."\n";
        close(OUT_C);
        close(OUT_PEAK);
	close(PLT);

	#==== move output =====
	if($output == 1){
		my $file = "point_plt/O/STEP$i.plt";
		system("gnuplot $file");
        	system("magick -density 300 point_pdf/output-".
			sprintf("%03d", $i).".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
	}
	#=========================
}

#========================================= movie output =======================================
if($output == 1){
	my $command_PNGtoGIF = "magick -delay 100 ./point_png/output-*.png ./output/output_point.gif";
	system($command_PNGtoGIF);
	print "Finished png to gif.\n";
	
	my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/output_point.gif".
	                        "  -movflags faststart -pix_fmt yuv420p -vf ".
	                        "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/O_peak.mp4";
	
	system($command_GIFtoMP4);
	print "Finished gif to mp4.\n";
}
#==============================================================================================


#if (-d "point_plt"){rmtree("point_plt")}mkdir("point_plt");
#for(my $i = 0; $i < $STEP; $i++){
#	open(PLT, ">", "point_plt/STEP$i.plt");
#	print PLT "file = C_test/STEP0.dat\n";
#	print PLT "set polar\n";
#	print PLT "set angles degree\n";
#	print PLT "\n";
#	my $tmp = scalar(@{$peak[$i]});
#	for (my $j = 1; $j <= $tmp; $j++){
#		my ($x,$y,$z);
#                ($x, $y, $z) = spherical_to_cartesian($peak[$i][$j][3], $peak[$i][$j][1], $peak[$i][$j][2]);
#		print PLT "set arrow from 0,0 to ".($x).",".($z)." nohead \n";
#	}
#	print PLT "plot file u (\$2!=180  ? - \$1+90 : \$1+90):3 w l"
#}
#


if (-d "point_plt/spectra_triangle"){rmtree("point_plt/spectra_triangle")}mkdir("point_plt/spectra_triangle");
if (-d "point_png/"){rmtree("point_png/")}mkdir("point_png/");
if (-d "point_pdf/"){rmtree("point_pdf/")}mkdir("point_pdf/");

open(OUT, ">", "theta12_spectra.dat");
close(OUT);

&brode_triangle();

sub triangle{
	open(IN, "<", "input_triangle_O.dat") or die $!;
	my @force_peak_O;
	my @force_peak_O_in = <IN>;
	print "O force peak\n";
	for(my $i = 0; $i <= $#force_peak_O_in; $i++){
		chomp($force_peak_O_in[$i]);
		my @line_split = split(/\s+/, $force_peak_O_in[$i]);
		$force_peak_O[$i][0] = $line_split[0];
		$force_peak_O[$i][1] = $line_split[1];
		print "$force_peak_O[$i][0]   $force_peak_O[$i][1]\n";
	}
	open(IN, "<", "input_triangle_C.dat") or die $!;
	my @force_peak_C;
	my @force_peak_C_in = <IN>;
	print "C force peak\n";
	for(my $i = 0; $i <= $#force_peak_C_in; $i++){
		chomp($force_peak_C_in[$i]);
		my @line_split = split(/\s+/, $force_peak_C_in[$i]);
		$force_peak_C[$i][0] = $line_split[0];
		$force_peak_C[$i][1] = $line_split[1];
		print "$force_peak_C[$i][0]   $force_peak_C[$i][1]\n";
	}
	
	my $count_C = 0;
	my $count_O = 0;
	
	for(my $i = 0; $i < $STEP; $i++){
		#open(IN_PEAK_C, ">", "C_test/STEP$i\_PEAK.dat") or die $!;
	        #open(IN_PEAK_O, ">", "O_test/STEP$i\_PEAK.dat") or die $!;
		#my @O_lines = <IN_PEAK_O>;
		#my $O_lines_len = $O_lines;
		#my @C_lines = <IN_PEAK_C>;
		#my $C_lines_len = $C_lines;
	
		#for(my $j = 0; $j < $O_lines_len; $j ++){
	        my ($x_C, $y_C, $z_C);
	        my ($x_O, $y_O, $z_O);
	
	
		my $tmp = scalar(@{$peak_C[$i]});
		my $theta_C;
		my $delta = 360;
		my $theta_keep;
		if ($force_peak_C[$count_C][0] == $i){
			$CH_peak = $force_peak_C[$count_C][1];
			#print "C $force_peak_C[$count_C][1] \n";
			$count_C += 1
		}
		for (my $j = 1; $j <= $tmp; $j++){
			$theta_C = $peak_C[$i][$j][1];
			if ($peak_C[$i][$j][2] == 180){
				$theta_C = -$peak_C[$i][$j][1];
			}
			if ($delta > abs($CH_peak - $theta_C)){
				#print "j = $j : $theta_C $CH_peak\n";
				$theta_keep = $theta_C;
				$delta = abs($CH_peak - $theta_C);
				#print "$delta\n";
	                	($x_C, $y_C, $z_C) = spherical_to_cartesian(1,
				       	deg2rad($peak_C[$i][$j][2]), deg2rad($peak_C[$i][$j][1]));
			}
		}
		$CH_peak = $theta_keep;
		print "STEP$i C $CH_peak\n";
	
		my $tmp = scalar(@{$peak_O[$i]});
		my $theta_O;
		my $delta = 360;
		my $theta_keep;
		if ($force_peak_O[$count_O][0] == $i){
			$OH_peak = $force_peak_O[$count_O][1];
			#print "O $force_peak_O[$count_O][1] \n";
			$count_O += 1
		}
		for (my $j = 1; $j <= $tmp; $j++){
			$theta_O = $peak_O[$i][$j][1];
			if ($peak_O[$i][$j][2] == 180){
				$theta_O = -$peak_O[$i][$j][1];
			}
			if ($delta > abs($OH_peak - $theta_O)){
				#print "j = $j : $theta_O $OH_peak\n";
				$theta_keep = $theta_O;
				$delta = abs($OH_peak - $theta_O);
	                	($x_O, $y_O, $z_O) = spherical_to_cartesian(1,
				       	deg2rad($peak_O[$i][$j][2]), deg2rad($peak_O[$i][$j][1]));
			}
		}
		$OH_peak = $theta_keep;
		print "STEP$i O $OH_peak\n";
		#print "$OH_peak\n";
	
		
		#print "x_C = $x_C : y_C = $y_C : z_C = $z_C \n";
		#print "x_O = $x_O : y_O = $y_O : z_O = $z_O \n";
	
		open(OUT, ">>", "theta12_spectra.dat");
	
		my $HO_r = sqrt($x_O*$x_O + $y_O*$y_O + $z_O*$z_O);
		my $HC_r = sqrt($x_C*$x_C + $y_C*$y_C + $z_C*$z_C);
		my $HOHC = $x_O*$x_C + $y_O*$y_C + $z_O*$z_C;
	
		my $theta12_ = rad2deg(acos(($HOHC)/($HO_r*$HC_r)));
		print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", $theta12_)."\n";
		#
		#print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", abs($OH_peak-$CH_peak))."\n";
		close(OUT);
		#print "finished $i\n";
		
		
		($x_C, $y_C, $z_C) = ($x_C + $save_C[$i][0], $y_C + $save_C[$i][1], $z_C + $save_C[$i][2]);#p4
		#($save_C[$i][0], save[$i][1], save[$i][2])#p2
		#($x_O, $y_O, $z_O)#p3
		#(0, 0, 0)#p1
		#print "CH_spectra   $x_C    $y_C    $z_C\n";
		#print "OH_spectra   $x_O    $y_O    $z_O\n\n";
	
		my $S1 = (($x_C - $save_C[$i][0])*(0 - $save_C[$i][2]) - ($z_C - $save_C[$i][2])*(0 - $save_C[$i][0]))/2;
		my $S2 = (($x_C - $save_C[$i][0])*($save_C[$i][2] - $z_O) - ($z_C - $save_C[$i][2])*($save_C[$i][0] - $x_O))/2;
		#print "$i $S1   ,$S2\n";
		#print "$x_C, $z_C, $x_O, $z_O\n";
		if ($S1+$S2 == 0){
			print "OH and CH are parallel in STEP$i.\n";
			exit;
		}
		my $intersection_x = 0 + ($x_O - 0) * $S1 / ($S1 + $S2);
		my $intersection_y = 0 + ($z_O - 0) * $S1 / ($S1 + $S2);
		my $file = "point_plt/spectra_triangle/point".sprintf("%03d", $i).".plt";
	        open(POINT, ">", $file);
		print POINT "file_O = \"O_test/STEP$i.dat\"\n";
		print POINT "file_C = \"C_test/STEP$i.dat\"\n";
		print POINT "set title \"STEP-$i\"\n";
		print POINT "set terminal pdfcairo\n";
		print POINT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
	        print POINT "\n";
		print POINT "set size square\n";
		print POINT "set xr[-2:2]\n";
	        print POINT "set yr[-2:2]\n";
		print POINT "pi = 3.1415 \n";
	        print POINT "unset key\n";
		print POINT "set arrow 1 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
		" to ".sprintf("%9.6f", $intersection_x).", ".sprintf("%9.6f", $intersection_y)." nohead linestyle 2 lc \"purple\"\n";
	
	        print POINT "set arrow 2 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
		" to ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2])." nohead linestyle 2 lc \"purple\"\n";
	
	        print POINT "set arrow 3 from ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2]).
		" to ".sprintf("%9.6f", $intersection_x).", ".sprintf("%9.6f", $intersection_y)." nohead linestyle 2 lc \"purple\"\n";
	        print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $intersection_x).
			", ".sprintf("%9.6f", $intersection_y).") pt 7 title \"spectra\"\n";
	
		
			#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $x_O).
			#	", ".sprintf("%9.6f", $z_O).") pt 7\n";
	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $x_C).
			#	", ".sprintf("%9.6f", $z_C).") pt 7 lc \"green\"\n";
	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", 0).
			#	", ".sprintf("%9.6f", 1).") pt 7 lc \"green\"\n";
	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", 0).
			#	", ".sprintf("%9.6f", 0).") pt 7\n";
		
	
		
	        print POINT "plot file_C u (((\$3/$scale_C) * sin((\$1/180) * pi) * cos(\$2/180*pi)) + $save_C[$i][0]):(((\$3/$scale_C) * cos((\$1/180)*pi)) + $save_C[$i][2]) w l\n";
	        print POINT "plot file_O u ((\$3/$scale_O) * sin((\$1/180) * pi) * cos(\$2/180*pi)):(((\$3/$scale_O) * cos((\$1/180)*pi))) w l\n";
		#print POINT "reset\n";
		print POINT "load \"point_plt/atom_triangle/point".sprintf("%03d", $i).".plt\"\n";
	        close(POINT);
	        if ($output == 3){
	                system("gnuplot $file");
	                system("magick -density 300 point_pdf/output-".sprintf("%03d", $i).".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
		}
	
	
	}
	if ($output == 3){
		system("rm -rf ./output/spectra_triangle.mp4");
		my $command_PNGtoGIF = "magick -delay 100 ./point_png/output-*.png ./output/output_point.gif";
		system($command_PNGtoGIF);
		print "Finished png to gif.\n";
		my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/output_point.gif".
	                        "  -movflags faststart -pix_fmt yuv420p -vf ".
	                        "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/spectra_triangle.mp4";
		system($command_GIFtoMP4);
		print "Finished gif to mp4.\n";
	}
}


sub brode_triangle {
	open(IN, "<", "input_triangle_O.dat") or die $!;
	my @force_peak_O;
	my @force_peak_O_in = <IN>;
	print "O force peak\n";
	for(my $i = 0; $i <= $#force_peak_O_in; $i++){
		chomp($force_peak_O_in[$i]);
		my @line_split = split(/\s+/, $force_peak_O_in[$i]);
		$force_peak_O[$i][0] = $line_split[0];
		$force_peak_O[$i][1] = $line_split[1];
		print "$force_peak_O[$i][0]   $force_peak_O[$i][1]\n";
	}
	my $OH_peak_theta = $force_peak_O[0][1];
	#my $OH_peak_r = $data[0][$force_peak_O[0][0]][3];
	open(IN, "<", "input_triangle_C.dat") or die $!;
	my @force_peak_C;
	my @force_peak_C_in = <IN>;
	print "C force peak\n";
	for(my $i = 0; $i <= $#force_peak_C_in; $i++){
		chomp($force_peak_C_in[$i]);
		my @line_split = split(/\s+/, $force_peak_C_in[$i]);
		$force_peak_C[$i][0] = $line_split[0];
		$force_peak_C[$i][1] = $line_split[1];
		print "$force_peak_C[$i][0]   $force_peak_C[$i][1]\n";
	}
	my $CH_peak_theta = $force_peak_C[0][1];
	#my $CH_peak_r = $data[0][$force_peak_C[0][0]][3];


	my $peak_wide_C;
	my $peak_wide_O;
	if ($energy == "2500"){
		$peak_wide_C = $peak_wide;
		$peak_wide_O = $peak_wide;
	} elsif ($energy == "100"){
		$peak_wide_C = 30;
		$peak_wide_O = 30;
	}
	
	for(my $i = 0; $i < $STEP; $i++){
	        my ($x_C, $y_C, $z_C);
	        my ($x_O, $y_O, $z_O);
		my $CH_peak_r = 0;
		my $OH_peak_r = 0;
	
	
		my $peak_C_jlen = scalar(@{$peak_C[$i]});
		my $theta_C;
		my $theta_keep_C;
		for (my $j = 1; $j <= $peak_C_jlen; $j++){
			$theta_C = $peak_C[$i][$j][1];
			if ($peak_C[$i][$j][2] == 180){
	                        $theta_C = -$peak_C[$i][$j][1];
	                }
			#if ($theta_C > $CH_peak_theta - $peak_wide and $theta_C < $CH_peak_theta + $peak_wide){
			if ($theta_C > $CH_peak_theta - $peak_wide_C and $theta_C < $CH_peak_theta + $peak_wide_C){
				if ($peak_C[$i][$j][3] > $CH_peak_r){
					$theta_keep_C = $theta_C;
					$CH_peak_r = $peak_C[$i][$j][3];
					($x_C, $y_C, $z_C) = spherical_to_cartesian(1,
		                                deg2rad($peak_C[$i][$j][2]), deg2rad($peak_C[$i][$j][1]));
				}
			}
		}
		if ($theta_keep_C == ""){
			print "not found STEP $i C peak\n";
			exit;
		}
		$CH_peak_theta = $theta_keep_C;
		print "STEP$i C $CH_peak_theta\n";
	
	
	
		my $peak_O_jlen = scalar(@{$peak_O[$i]});
	        my $theta_O;
		my $theta_keep_O;
	        for (my $j = 1; $j <= $peak_O_jlen; $j++){
	                $theta_O = $peak_O[$i][$j][1];
	                if ($peak_O[$i][$j][2] == 180){
	                        $theta_O = -$peak_O[$i][$j][1];
	                }
			#if ($theta_O > $OH_peak_theta - $peak_wide and $theta_O < $OH_peak_theta + $peak_wide){
			if ($theta_O > $OH_peak_theta - $peak_wide_O and $theta_O < $OH_peak_theta + $peak_wide_O){
	                        if ($peak_O[$i][$j][3] > $OH_peak_r){
	                                $theta_keep_O = $theta_O;
	                                $OH_peak_r = $peak_O[$i][$j][3];
	                                ($x_O, $y_O, $z_O) = spherical_to_cartesian(1,
	                                        deg2rad($peak_O[$i][$j][2]), deg2rad($peak_O[$i][$j][1]));
	                        }
	                }
	        }
		if ($theta_keep_O == ""){
			print "not found STEP $i O peak\n";
			exit;
		}
	        $OH_peak_theta = $theta_keep_O;
	        print "STEP$i O $OH_peak_theta\n";
	
		
		#print "x_C = $x_C : y_C = $y_C : z_C = $z_C \n";
		#print "x_O = $x_O : y_O = $y_O : z_O = $z_O \n";
	
		open(OUT, ">>", "theta12_spectra.dat");
	
		my $HO_r = sqrt($x_O*$x_O + $y_O*$y_O + $z_O*$z_O);
		my $HC_r = sqrt($x_C*$x_C + $y_C*$y_C + $z_C*$z_C);
		my $HOHC = $x_O*$x_C + $y_O*$y_C + $z_O*$z_C;
	
		my $theta12_ = rad2deg(acos(($HOHC)/($HO_r*$HC_r)));
		print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", $theta12_)."\n";
		#
		#print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", abs($OH_peak-$CH_peak))."\n";
		close(OUT);
		#print "finished $i\n";
		
		
		($x_C, $y_C, $z_C) = ($x_C + $save_C[$i][0], $y_C + $save_C[$i][1], $z_C + $save_C[$i][2]);#p4


		#($save_C[$i][0], save[$i][1], save[$i][2])#p2
		#($x_O, $y_O, $z_O)#p3
		#(0, 0, 0)#p1
		#print "CH_spectra   $x_C    $y_C    $z_C\n";
		#print "OH_spectra   $x_O    $y_O    $z_O\n\n";
	
		my $S1 = (($x_C - $save_C[$i][0]) *
			(0 - $save_C[$i][2]) - ($z_C - $save_C[$i][2]) * (0 - $save_C[$i][0])) / 2;

		my $S2 = (($x_C - $save_C[$i][0]) *
			($save_C[$i][2] - $z_O) - ($z_C - $save_C[$i][2])*($save_C[$i][0] - $x_O)) / 2;
		#print "$i $S1   ,$S2\n";
		#print "$x_C, $z_C, $x_O, $z_O\n";
		if ($S1+$S2 == 0){
			print "OH and CH are parallel in STEP$i.\n";
			exit;
		}
		my $intersection_x = 0 + ($x_O - 0) * $S1 / ($S1 + $S2);
		my $intersection_y = 0 + ($z_O - 0) * $S1 / ($S1 + $S2);
		my $file = "point_plt/spectra_triangle/point".sprintf("%03d", $i).".plt";
	        open(POINT, ">", $file);
		print POINT "file_O = \"O_test/STEP$i.dat\"\n";
		print POINT "file_C = \"C_test/STEP$i.dat\"\n";
		print POINT "file_O_diff = \"O_test/STEP$i\_diff.dat\"\n";
		print POINT "file_C_diff = \"C_test/STEP$i\_diff.dat\"\n";
		print POINT "set title \"STEP-$i\"\n";
		print POINT "set terminal pdfcairo\n";
		print POINT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
	        print POINT "\n";
		print POINT "set size square\n";
		print POINT "set xr[-2:2]\n";
	        print POINT "set yr[-2:2]\n";
		print POINT "pi = 3.1415 \n";
	        print POINT "unset key\n";
		if ($CH_peak_theta - $OH_peak_theta < 0){
			print POINT "set arrow 1 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
                        	" to ".sprintf("%9.6f", $x_O).", ".sprintf("%9.6f", $z_O).
                        	" nohead linestyle 2 lc \"purple\"\n";

			print POINT "set arrow 2 from ".sprintf("%9.6f", $save_C[$i][0]).", ".
				sprintf("%9.6f", $save_C[$i][2])." to ".sprintf("%9.6f", $x_C).", ".
				sprintf("%9.6f", $z_C)." nohead linestyle 2 lc \"purple\"\n";
		} else {
			print POINT "set arrow 1 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
				" to ".sprintf("%9.6f", $intersection_x).", ".sprintf("%9.6f", $intersection_y).
				" nohead linestyle 2 lc \"purple\"\n";
	
	        	print POINT "set arrow 2 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
				" to ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2]).
				" nohead linestyle 2 lc \"purple\"\n";
	
	        	print POINT "set arrow 3 from ".sprintf("%9.6f", $save_C[$i][0]).", ".
				sprintf("%9.6f", $save_C[$i][2])." to ".sprintf("%9.6f", $intersection_x).
				", ".sprintf("%9.6f", $intersection_y)." nohead linestyle 2 lc \"purple\"\n";

	        	print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $intersection_x).
				", ".sprintf("%9.6f", $intersection_y).") pt 7 title \"spectra\"\n";
		}
		
			#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $x_O).
			#	", ".sprintf("%9.6f", $z_O).") pt 7\n";
	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $x_C).
			#	", ".sprintf("%9.6f", $z_C).") pt 7 lc \"green\"\n";
	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", 0).
			#	", ".sprintf("%9.6f", 1).") pt 7 lc \"green\"\n";
	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", 0).
			#	", ".sprintf("%9.6f", 0).") pt 7\n";
	
		#print POINT "plot file_C_diff w l\n";
		#print POINT "plot file_O_diff w l\n";
	        print POINT "plot file_C_diff u ".
			"(((\$3/$scale_C + 0.5) * sin((\$1/180) * pi) * cos(\$2/180 * pi)) + $save_C[$i][0]):".
			"(((\$3/$scale_C + 0.5) * cos((\$1/180) * pi)) + $save_C[$i][2]) w l lc \"blue\"\n";
	        print POINT "plot file_O_diff u ".
			"((\$3/$scale_O + 0.5) * sin((\$1/180) * pi) * cos(\$2/180*pi)):".
			"((\$3/$scale_O + 0.5) * cos((\$1/180)*pi)) w l lc \"red\"\n";
	
		
	        print POINT "plot file_C u ".
			"(((\$3/$scale_C) * sin((\$1/180) * pi) * cos(\$2/180 * pi)) + $save_C[$i][0]):".
			"(((\$3/$scale_C) * cos((\$1/180) * pi)) + $save_C[$i][2]) w l\n";
	        print POINT "plot file_O u ".
			"((\$3/$scale_O) * sin((\$1/180) * pi) * cos(\$2/180*pi)):".
			"((\$3/$scale_O) * cos((\$1/180) * pi)) w l\n";
		#print POINT "reset\n";
		print POINT "load \"point_plt/atom_triangle/point".sprintf("%03d", $i).".plt\"\n";
	        close(POINT);
	        if ($output == 3){
	                system("gnuplot $file");
	                system("magick -density 300 point_pdf/output-".
				sprintf("%03d", $i).".pdf -layers flatten point_png/output-".
				sprintf("%03d", $i).".png");
		}
	
	
	}
	if ($output == 3){
		system("rm -rf ./output/spectra_triangle.mp4");
		my $command_PNGtoGIF = "magick -delay 100 ./point_png/output-*.png ./output/output_point.gif";
		system($command_PNGtoGIF);
		print "Finished png to gif.\n";
		my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/output_point.gif".
	                        "  -movflags faststart -pix_fmt yuv420p -vf ".
	                        "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/spectra_triangle.mp4";
		system($command_GIFtoMP4);
		print "Finished gif to mp4.\n";
	}
}


###################################
sub input_parameter {
	open(IN, "<", "input_methanol.txt") or die "No found input_methanol.txt\n";
	while(my $line = <IN>){
		chomp($line);
		$line =~ s/ |\t//g;
		if ($line =~ /^structure_file/){
                        $line =~ /structure_file="(.*)"/;
                        $input_file = $1;
                }
		if ($line =~ /^energy/){
                        $line =~ /energy="(.*)"/;
                        $energy = $1;
                }
		if ($line =~ /^peak_wide/){
			$line =~ /peak_wide="(.*)"/;
			$peak_wide = $1;
		}
	}
}
