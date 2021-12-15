#!/usr/bin/perl
use strict;
use Math::Trig;
use Math::Trig ":radial";
use File::Path 'rmtree';


my $Number_of_atoms = 6;
my $extra_line = 2;
my $total_line = $Number_of_atoms + $extra_line;
my $input_file;

#my $rO = 0.5794375693;
#my $rC = 0.6239214294;
#my $rH = 0.4555414633;
my $rO = 0.05794375693 * 4;
my $rC = 0.06239214294 * 4;
my $rH = 0.04555414633 * 4;


### ImageMagick path
my $IM = "/opt/imagemagick/7.1.0-17/magick";

#my $energy = 100;

my $C_energy;
my $O_energy;
my $peak_wide;
my $input_peak_wide_O;
my $input_peak_wide_C;
my $CH_peak_theta;
my $OH_peak_theta;


my $OH_peak;
my $CH_peak;
my @save_C;
my @title;

#my $OH_peak = 59.00;
#my $CH_peak = 61.00;
my $output = 3;
my $normalization = 0;
my $atom_plot = 0;
my $average = 0;
my $diff = 0;
my $STEP;

my @xrange = (-5, 5);
my @yrange = (-2, 2);

&option();
&input_parameter();


my $yrange_max = 7;
my $scale_C;
my $scale_O;
if ($C_energy == 2500){
	#@xrange = (-0.0015, 0.0015);
	#@yrange = (-0.0015, 0.0015);
	#$scale_C = 0.0013; #2021-07-04
	#$scale_O = 0.006; #2021-07-04
	#$scale_C = 0.001; #2021-02-04
	$scale_C = 0.0006 #2021-02-04
} elsif ($C_energy == 2748) {
	#@xrange = (-0.0015, 0.0015);
	#@yrange = (-0.0015, 0.0015);
	$scale_C = 0.0008;
} elsif ($C_energy == 100) {
	#@xrange = (-0.2, 0.2);
	#@yrange = (-0.2, 0.2);
	$scale_C = 0.1; #2021-02-04
} elsif ($C_energy == 348) {
	$scale_C = 0.03; #2021-02-04
} elsif ($C_energy == 1000) {
	#@xrange = (-0.2, 0.2);
	#@yrange = (-0.2, 0.2);
	$scale_C = 0.008; #2021-02-04
} elsif ($C_energy == 748) {
	$scale_C = 0.01; #2021-02-04
} elsif ($O_energy == 500) {
	$scale_C = 0.015;
}
if ($O_energy == 2500){
	#@xrange = (-0.0015, 0.0015);
	#@yrange = (-0.0015, 0.0015);
	#$scale_C = 0.0013; #2021-07-04
	#$scale_O = 0.006; #2021-07-04
	$scale_O = 0.0025; #2021-02-04
} elsif ($O_energy == 100) {
	#@xrange = (-0.2, 0.2);
	#@yrange = (-0.2, 0.2);
	$scale_O = 0.07;
} elsif ($O_energy == 1000) {
	#@xrange = (-0.2, 0.2);
	#@yrange = (-0.2, 0.2);
	$scale_O = 0.01;
} elsif ($O_energy == 500) {
	$scale_O = 0.05;
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


	$title[$i] = $lines[$var + 1];
	#print "$title[$i]\n";


	###############         make plt          ##################
	my $file = "point_plt/atom_triangle/point".sprintf("%03d", $i).".plt";
	open(POINT, ">", $file);
	if ($output == 2){
		print POINT "set terminal pdfcairo\n";
		print POINT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
	}
	#print POINT "set title \"STEP-$i\"\n";
	print POINT "set title \"$title[$i]\"\n";
	print POINT "set xtics -1 ,1 , 2\n";
	print POINT "set size ratio -1\n";
	print POINT "\n";
	if ($normalization == 1){
		print POINT "unset xtics\n";
		print POINT "unset ytics\n";
		print POINT "unset rtics\n";
		print POINT "set xr[-2:2]\n";
		print POINT "set yr[-2:2]\n";
	} else {
		print POINT "unset xtics\n";
		print POINT "unset ytics\n";
		print POINT "unset rtics\n";
		#print POINT "set xr[-2:2]\n";
		print POINT "set xr[$xrange[0]:$xrange[1]]\n";
        print POINT "set yr[-2:$yrange_max]\n";
	}
	if ($atom_plot == 1){
 		print POINT 'unse key'."\n";
        print POINT 'set pm3d'."\n";
        print POINT 'set pm3d depthorder'."\n";
        print POINT 'set pm3d lighting specular 0.7'."\n";
        print POINT 'se isosamples 5'."\n";
		#print POINT 'unse border'."\n";
        print POINT 'unse xtics'."\n";
        print POINT 'unse ytics'."\n";
        print POINT 'unse ztics'."\n";
        print POINT 'unse colorbox'."\n";
        print POINT ''."\n";
        print POINT '# 球面データファイル'."\n";
        print POINT 'set parametric'."\n";
        print POINT 'set urange [-0.1:pi]'."\n";
        print POINT 'set vrange [0:2*pi]'."\n";
        print POINT 'set samples 30'."\n";
        print POINT 'set isosamples 30'."\n";
        print POINT 'sphere="sphere_xyz.dat"'."\n";
        print POINT 'set table sphere'."\n";
        print POINT 'splot sin(u)*cos(v), sin(u)*sin(v), cos(u)'."\n";
        print POINT 'unset table'."\n";
        print POINT ''."\n";
        print POINT '# 色分け関数'."\n";
        print POINT 'u0 = pi/4'."\n";
        print POINT 'v0 = 0'."\n";
        print POINT 'x0 = sin(u0)*cos(v0); y0 = sin(u0)*sin(v0); z0 = cos(u0)'."\n";
        print POINT 'rr(x,y,z) = (x-x0)**2 + (y-y0)**2 + (z-z0)**2'."\n";
        print POINT 'f(x,y,z) =  exp(-rr(x,y,z)/2);'."\n";
        print POINT 'H(x,y,z) = 0.2*f(x,y,z) '."\n";
        print POINT 'O(x,y,z) = 0.2*f(x,y,z)+0.38'."\n";
        print POINT 'C(x,y,z) = 0.2*f(x,y,z)+1.0'."\n";
        print POINT ''."\n";
        print POINT 'set palette cubehelix start 0.5 cycles -1.5 saturation 3'."\n";
        print POINT ''."\n";
        print POINT 'set macro'."\n";
        print POINT 'Hx = "rH*($1)"; Hy = "rH*($2)"; Hz = "rH*($3)"; H = "H($1,$2,$3)"'."\n";
        print POINT 'Ox = "rO*($1)"; Oy = "rO*($2)"; Oz = "rO*($3)"; O = "O($1,$2,$3)"'."\n";
        print POINT 'Cx = "rC*($1)"; Cy = "rC*($2)"; Cz = "rC*($3)"; C = "C($1,$2,$3)"'."\n";
        print POINT "rO = $rO"."\n";
        print POINT "rC = $rC"."\n";
        print POINT "rH = $rH"."\n";
        print POINT 'se ticslevel 0'."\n";
		print POINT 'se view equal xyz'."\n";
		#print POINT "set size ratio -1\n";
        print POINT "se view 90, 0, 1, 1 \n";
        print POINT "splot \\"."\n";
	}

	#################################################################
	


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

			if ($atom_plot == 1){
				print POINT "sphere u (@".
                                	$data[0]."x+ ".($x)."):(@".
                                	$data[0]."y+ ".($y)."):(@".
                                	$data[0]."z+ ".($z)."):(@".$data[0].') w pm3d , \\'."\n";
			}
                        #print $data[0]."  ".$x."  ".$y."  ".$z."\n";
		} elsif ($data[0] eq "H" && $data[2] == 0){
			my $x = $data[1] - $move_x;
	                my $y = $data[2] - $move_y;
	                my $z = $data[3] - $move_z;

			#normalization
			if ($normalization == 1){
				#my $r;
		                #my $theta;
		                #my $phi;
			#my $x_;#
	                #my $y_;#
	                #my $z_;#
		                #($r, $theta, $phi) = cartesian_to_spherical($x, $y, $z);
	        	        #($x, $y, $z) = spherical_to_cartesian($r/$C_r, $theta, $phi);
				my $r_norma;
				my $theta_norma;
				my $phi_norma;
				#my $x_;
				#my $y_;
				#my $z_;
				($r_norma, $theta_norma, $phi_norma) = cartesian_to_spherical($x, $y, $z);
				($x, $y, $z) = spherical_to_cartesian($r_norma/$C_r, $theta_norma, $phi_norma);

			}
	                #print $data[0]."  ".$x_."  ".$y_."  ".$z_."\n";
	                print OUT $data[0]."  ".sprintf("%9.6f", $x)."  ".sprintf("%9.6f", $y).
			"  ".sprintf("%9.6f", $z)."\n";

			$H_x = $x;
			$H_y = $y;
			$H_z = $z;
			if ($atom_plot == 1){
				print POINT "sphere u (@".
                                	$data[0]."x+ ".($x)."):(@".
                                	$data[0]."y+ ".($y)."):(@".
                                	$data[0]."z+ ".($z)."):(@".$data[0].') w pm3d , \\'."\n";
			}
		} elsif ($data[0] eq "C"){
			my $x = $data[1] - $move_x;
	                my $y = $data[2] - $move_y;
	                my $z = $data[3] - $move_z;
			#print "$x : $y : $z \n";

			if ($normalization == 1){
				#my $r;
	                	#my $theta;
	                	#my $phi;
				##my $x_;
	                	##my $y_;
	                	##my $z_;
	                	#($r, $theta, $phi) = cartesian_to_spherical($x, $y, $z);
	                	#($x, $y, $z) = spherical_to_cartesian($r/$C_r, $theta, $phi);

				my $r_norma;
				my $theta_norma;
				my $phi_norma;
				#my $x_;
				#my $y_;
				#my $z_;
				($r_norma, $theta_norma, $phi_norma) = cartesian_to_spherical($x, $y, $z);
				($x, $y, $z) = spherical_to_cartesian($r_norma/$C_r, $theta_norma, $phi_norma);

			}
			($save_C[$i][0], $save_C[$i][1], $save_C[$i][2]) = ($x, $y, $z);
			#print "$save_C[$i][0]  $save_C[$i][1]\n";
	                #print $data[0]."  ".$x_."  ".$y_."  ".$z_."\n";
	                print OUT $data[0]."  ".sprintf("%9.6f", $x)."  ".sprintf("%9.6f", $y).
			"  ".sprintf("%9.6f", $z)."\n";

			$C_x = $x;
			$C_y = $y;
			$C_z = $z;
			if ($atom_plot == 1){
				print POINT "sphere u (@".
                                	$data[0]."x+ ".($x)."):(@".
                                	$data[0]."y+ ".($y)."):(@".
                                	$data[0]."z+ ".($z)."):(@".$data[0].') w pm3d , \\'."\n";
			}
		} else {
			my $x = $data[1] - $move_x;
                	my $y = $data[2] - $move_y;
                	my $z = $data[3] - $move_z;
			
			if ($normalization == 1){
				my $r_norma;
				my $theta_norma;
				my $phi_norma;
				#my $x_;
				#my $y_;
				#my $z_;
				($r_norma, $theta_norma, $phi_norma) = cartesian_to_spherical($x, $y, $z);
				($x, $y, $z) = spherical_to_cartesian($r_norma/$C_r, $theta_norma, $phi_norma);
				#print $data[0]."  ".$x_."  ".$y_."  ".$z_."\n";
			}
			print OUT $data[0]."  ".sprintf("%9.6f", $x)."  ".
			sprintf("%9.6f", $y)."  ".sprintf("%9.6f", $z)."\n";
			if ($atom_plot == 1){
				print POINT "sphere u (@".
                                	$data[0]."x+ ".($x)."):(@".
                                	$data[0]."y+ ".($y)."):(@".
                                	$data[0]."z+ ".($z)."):(@".$data[0].') w pm3d , \\'."\n";
			}
		}
	}
	close(OUT);
	#my $file = "point/point".sprintf("%03d", $i).".dat";
	#open(POINT, ">", $file);
	#print POINT "H  ".sprintf("%9.6f", $H_x)."  ".sprintf("%9.6f", $H_y)."  ".sprintf("%9.6f", $H_z)."\n";
	#print POINT "C  ".sprintf("%9.6f", $C_x)."  ".sprintf("%9.6f", $C_y)."  ".sprintf("%9.6f", $C_z)."\n";
	#print POINT "O  ".sprintf("%9.6f", $O_x)."  ".sprintf("%9.6f", $O_y)."  ".sprintf("%9.6f", $O_z)."\n\n";
	#close(POINT);




	###############         make plt          ##################
	print POINT "\n";
	print POINT "set arrow 1 from ".sprintf("%9.6f", $H_x).", ".sprintf("%9.6f", $H_z)." to ".sprintf("%9.6f", $C_x).", ".sprintf("%9.6f", $C_z)." nohead linestyle 2 lc \"green\"\n";
	print POINT "set arrow 2 from ".sprintf("%9.6f", $H_x).", ".sprintf("%9.6f", $H_z)." to ".sprintf("%9.6f", $O_x).", ".sprintf("%9.6f", $O_z)." nohead linestyle 2 lc \"green\"\n";
	print POINT "set arrow 3 from ".sprintf("%9.6f", $C_x).", ".sprintf("%9.6f", $C_z)." to ".sprintf("%9.6f", $O_x).", ".sprintf("%9.6f", $O_z)." nohead linestyle 2 lc \"green\"\n";
	print POINT "unset key\n";
	print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $H_x).", ".sprintf("%9.6f", $H_z).") pt 7 lc \"green\" title \"atom\"\n";
	close(POINT);
	#############################################################






	if ($output == 2){
 		system("gnuplot $file");
		system("$IM -density 300 point_pdf/output-".sprintf("%03d", $i).".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
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
	#print "$HO[0]*$HO[0] + $HO[1]*$HO[1] + $HO[2]*$HO[2]\\n";
	#print "$i  $HO_r  $HC_r\n";
	my $theta12_ = rad2deg(acos(($HOHC)/($HO_r*$HC_r)));
	$theta12 = acos(($HC[0]*$HO[0] + $HC[1]*$HO[1] + $HC[2]*$HO[2])/(sqrt($HC[0]*$HC[0] + $HC[1]*$HC[1] + $HC[2]*$HC[2])*sqrt($HO[0]*$HO[0] + $HO[1]*$HO[1] + $HO[2]*$HO[2])));
	print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", $theta12_)."\n";
	close(OUT);
	#print "finished $i\n";

}
if ($output == 2){
	my $command_PNGtoGIF = "$IM -delay 100 ./point_png/output-*.png ./output/output_point.gif";
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
        open(IN, "<", "../C_".$C_energy."eV/plot-data/STEP$i.dat")or die $!;
        my @lines = <IN>;
	chomp(@lines);
        for(my $j = 0; $j <= 180; $j++){
		my $line = $lines[$j*362];
		#chomp($line);
		#print "$line\n";
			my @line_split = split(/\s+/, $line);
			if ($average == 0) {
				$data[$i][$j][1] = $line_split[1];
				$data[$i][$j][2] = $line_split[2];
				$data[$i][$j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3.0;
			} elsif ($average == 1) {
				$data[$i][$j][1] = $line_split[0];
				$data[$i][$j][2] = $line_split[1];
				$data[$i][$j][3] = $line_split[2];
			}
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
			if ($average == 0) {
            	$data[$i][180 + $j][1] = $line_split[1];
            	$data[$i][180 + $j][2] = $line_split[2];
            	$data[$i][180 + $j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3.0;
			} elsif ($average == 1) {
				$data[$i][180 + $j][1] = $line_split[0];
				$data[$i][180 + $j][2] = $line_split[1];
				$data[$i][180 + $j][3] = $line_split[2];
			}
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
	#print PLT "set title \"STEP$i\"\n";
	print PLT "set title \"$title[$i]\"\n";
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
		system("$IM -density 300 point_pdf/output-".sprintf("%03d", $i).
			".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
	}
	#=========================
}

#========================================= movie output =======================================
if ($output == 1){
	if (-d "output"){rmtree("output")};mkdir("output");
	my $command_PNGtoGIF = "$IM -delay 100 ./point_png/output-*.png ./output/output_point.gif";
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
        open(IN, "<", "../O_".$O_energy."eV/plot-data/STEP$i.dat")or die $!;
        my @lines = <IN>;
	chomp(@lines);
        for(my $j = 0; $j <= 180; $j++){
		my $line = $lines[$j*362];
		#chomp($line);
		#print "$line\n";
			my @line_split = split(/\s+/, $line);
			if ($average == 0) {
				$data[$i][$j][1] = $line_split[1];
				$data[$i][$j][2] = $line_split[2];
				$data[$i][$j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3.0;
			} elsif ($average == 1) {
				$data[$i][$j][1] = $line_split[0];
				$data[$i][$j][2] = $line_split[1];
				$data[$i][$j][3] = $line_split[2];
			}
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
			if ($average == 0) {
            	$data[$i][180 + $j][1] = $line_split[1];
            	$data[$i][180 + $j][2] = $line_split[2];
            	$data[$i][180 + $j][3] = ($line_split[3] + $line_split[6] + $line_split[9])/3.0;
			} elsif ($average == 1) {
				$data[$i][180 + $j][1] = $line_split[0];
				$data[$i][180 + $j][2] = $line_split[1];
				$data[$i][180 + $j][3] = $line_split[2];
			}
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
	#print PLT "set title \"STEP$i\"\n";
	print PLT "set title \"$title[$i]\"\n";
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
        	system("$IM -density 300 point_pdf/output-".
			sprintf("%03d", $i).".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
	}
	#=========================
}

#========================================= movie output =======================================
if($output == 1){
	my $command_PNGtoGIF = "$IM -delay 100 ./point_png/output-*.png ./output/output_point.gif";
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

#sub triangle{
#	open(IN, "<", "input_triangle_O.dat") or die $!;
#	my @force_peak_O;
#	my @force_peak_O_in = <IN>;
#	print "O force peak\n";
#	for(my $i = 0; $i <= $#force_peak_O_in; $i++){
#		chomp($force_peak_O_in[$i]);
#		my @line_split = split(/\s+/, $force_peak_O_in[$i]);
#		$force_peak_O[$i][0] = $line_split[0];
#		$force_peak_O[$i][1] = $line_split[1];
#		print "$force_peak_O[$i][0]   $force_peak_O[$i][1]\n";
#	}
#	open(IN, "<", "input_triangle_C.dat") or die $!;
#	my @force_peak_C;
#	my @force_peak_C_in = <IN>;
#	print "C force peak\n";
#	for(my $i = 0; $i <= $#force_peak_C_in; $i++){
#		chomp($force_peak_C_in[$i]);
#		my @line_split = split(/\s+/, $force_peak_C_in[$i]);
#		$force_peak_C[$i][0] = $line_split[0];
#		$force_peak_C[$i][1] = $line_split[1];
#		print "$force_peak_C[$i][0]   $force_peak_C[$i][1]\n";
#	}
#	
#	my $count_C = 0;
#	my $count_O = 0;
#	
#	for(my $i = 0; $i < $STEP; $i++){
#		#open(IN_PEAK_C, ">", "C_test/STEP$i\_PEAK.dat") or die $!;
#	        #open(IN_PEAK_O, ">", "O_test/STEP$i\_PEAK.dat") or die $!;
#		#my @O_lines = <IN_PEAK_O>;
#		#my $O_lines_len = $O_lines;
#		#my @C_lines = <IN_PEAK_C>;
#		#my $C_lines_len = $C_lines;
#	
#		#for(my $j = 0; $j < $O_lines_len; $j ++){
#	        my ($x_C, $y_C, $z_C);
#	        my ($x_O, $y_O, $z_O);
#	
#	
#		my $tmp = scalar(@{$peak_C[$i]});
#		my $theta_C;
#		my $delta = 360;
#		my $theta_keep;
#		if ($force_peak_C[$count_C][0] == $i){
#			$CH_peak = $force_peak_C[$count_C][1];
#			#print "C $force_peak_C[$count_C][1] \n";
#			$count_C += 1
#		}
#		for (my $j = 1; $j <= $tmp; $j++){
#			$theta_C = $peak_C[$i][$j][1];
#			if ($peak_C[$i][$j][2] == 180){
#				$theta_C = -$peak_C[$i][$j][1];
#			}
#			if ($delta > abs($CH_peak - $theta_C)){
#				#print "j = $j : $theta_C $CH_peak\n";
#				$theta_keep = $theta_C;
#				$delta = abs($CH_peak - $theta_C);
#				#print "$delta\n";
#	                	($x_C, $y_C, $z_C) = spherical_to_cartesian(1,
#				       	deg2rad($peak_C[$i][$j][2]), deg2rad($peak_C[$i][$j][1]));
#			}
#		}
#		$CH_peak = $theta_keep;
#		print "STEP$i C $CH_peak\n";
#	
#		my $tmp = scalar(@{$peak_O[$i]});
#		my $theta_O;
#		my $delta = 360;
#		my $theta_keep;
#		if ($force_peak_O[$count_O][0] == $i){
#			$OH_peak = $force_peak_O[$count_O][1];
#			#print "O $force_peak_O[$count_O][1] \n";
#			$count_O += 1
#		}
#		for (my $j = 1; $j <= $tmp; $j++){
#			$theta_O = $peak_O[$i][$j][1];
#			if ($peak_O[$i][$j][2] == 180){
#				$theta_O = -$peak_O[$i][$j][1];
#			}
#			if ($delta > abs($OH_peak - $theta_O)){
#				#print "j = $j : $theta_O $OH_peak\n";
#				$theta_keep = $theta_O;
#				$delta = abs($OH_peak - $theta_O);
#	                	($x_O, $y_O, $z_O) = spherical_to_cartesian(1,
#				       	deg2rad($peak_O[$i][$j][2]), deg2rad($peak_O[$i][$j][1]));
#			}
#		}
#		$OH_peak = $theta_keep;
#		print "STEP$i O $OH_peak\n";
#		#print "$OH_peak\n";
#	
#		
#		#print "x_C = $x_C : y_C = $y_C : z_C = $z_C \n";
#		#print "x_O = $x_O : y_O = $y_O : z_O = $z_O \n";
#	
#		open(OUT, ">>", "theta12_spectra.dat");
#	
#		my $HO_r = sqrt($x_O*$x_O + $y_O*$y_O + $z_O*$z_O);
#		my $HC_r = sqrt($x_C*$x_C + $y_C*$y_C + $z_C*$z_C);
#		my $HOHC = $x_O*$x_C + $y_O*$y_C + $z_O*$z_C;
#	
#		my $theta12_ = rad2deg(acos(($HOHC)/($HO_r*$HC_r)));
#		print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", $theta12_)."\n";
#		#
#		#print OUT sprintf("%3d", $i)."  ".sprintf("%9.6f", abs($OH_peak-$CH_peak))."\n";
#		close(OUT);
#		#print "finished $i\n";
#		
#		
#		($x_C, $y_C, $z_C) = ($x_C + $save_C[$i][0], $y_C + $save_C[$i][1], $z_C + $save_C[$i][2]);#p4
#		#($save_C[$i][0], save[$i][1], save[$i][2])#p2
#		#($x_O, $y_O, $z_O)#p3
#		#(0, 0, 0)#p1
#		#print "CH_spectra   $x_C    $y_C    $z_C\n";
#		#print "OH_spectra   $x_O    $y_O    $z_O\n\n";
#	
#		my $S1 = (($x_C - $save_C[$i][0])*(0 - $save_C[$i][2]) - ($z_C - $save_C[$i][2])*(0 - $save_C[$i][0]))/2;
#		my $S2 = (($x_C - $save_C[$i][0])*($save_C[$i][2] - $z_O) - ($z_C - $save_C[$i][2])*($save_C[$i][0] - $x_O))/2;
#		#print "$i $S1   ,$S2\n";
#		#print "$x_C, $z_C, $x_O, $z_O\n";
#		if ($S1+$S2 == 0){
#			print "OH and CH are parallel in STEP$i.\n";
#			exit;
#		}
#		my $intersection_x = 0 + ($x_O - 0) * $S1 / ($S1 + $S2);
#		my $intersection_y = 0 + ($z_O - 0) * $S1 / ($S1 + $S2);
#		my $file = "point_plt/spectra_triangle/point".sprintf("%03d", $i).".plt";
#	        open(POINT, ">", $file);
#		print POINT "file_O = \"O_test/STEP$i.dat\"\n";
#		print POINT "file_C = \"C_test/STEP$i.dat\"\n";
#		#print POINT "set title \"STEP-$i\"\n";
#		print POINT "set title \"$title[$i]\"\n";
#		print POINT "set terminal pdfcairo\n";
#		print POINT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
#	        print POINT "\n";
#		print POINT "set size square\n";
#		print POINT "set xr[-2:2]\n";
#	        print POINT "set yr[-2:2]\n";
#		print POINT "pi = 3.1415 \n";
#	        print POINT "unset key\n";
#		print POINT "set arrow 1 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
#		" to ".sprintf("%9.6f", $intersection_x).", ".sprintf("%9.6f", $intersection_y)." nohead linestyle 2 lc \"purple\"\n";
#	
#	        print POINT "set arrow 2 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
#		" to ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2])." nohead linestyle 2 lc \"purple\"\n";
#	
#	        print POINT "set arrow 3 from ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2]).
#		" to ".sprintf("%9.6f", $intersection_x).", ".sprintf("%9.6f", $intersection_y)." nohead linestyle 2 lc \"purple\"\n";
#	        print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $intersection_x).
#			", ".sprintf("%9.6f", $intersection_y).") pt 7 title \"spectra\"\n";
#	
#		
#			#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $x_O).
#			#	", ".sprintf("%9.6f", $z_O).") pt 7\n";
#	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $x_C).
#			#	", ".sprintf("%9.6f", $z_C).") pt 7 lc \"green\"\n";
#	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", 0).
#			#	", ".sprintf("%9.6f", 1).") pt 7 lc \"green\"\n";
#	        	#print POINT "plot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", 0).
#			#	", ".sprintf("%9.6f", 0).") pt 7\n";
#		
#	
#		
#	        print POINT "plot file_C u (((\$3/$scale_C) * sin((\$1/180) * pi) * cos(\$2/180*pi)) + $save_C[$i][0]):(((\$3/$scale_C) * cos((\$1/180)*pi)) + $save_C[$i][2]) w l lc \"blue\"\n";
#	        print POINT "plot file_O u ((\$3/$scale_O) * sin((\$1/180) * pi) * cos(\$2/180*pi)):(((\$3/$scale_O) * cos((\$1/180)*pi))) w l lc \"red\"\n";
#		#print POINT "reset\n";
#		print POINT "load \"point_plt/atom_triangle/point".sprintf("%03d", $i).".plt\"\n";
#	        close(POINT);
#	        if ($output == 3){
#	                system("gnuplot $file");
#	                system("$IM -density 300 point_pdf/output-".sprintf("%03d", $i).".pdf -layers flatten point_png/output-".sprintf("%03d", $i).".png");
#		}
#	
#	
#	}
#	if ($output == 3){
#		system("rm -rf ./output/spectra_triangle.mp4");
#		my $command_PNGtoGIF = "$IM -delay 100 ./point_png/output-*.png ./output/output_point.gif";
#		system($command_PNGtoGIF);
#		print "Finished png to gif.\n";
#		my $command_GIFtoMP4 = "ffmpeg -r 3 -i ./output/output_point.gif".
#	                        "  -movflags faststart -pix_fmt yuv420p -vf ".
#	                        "\"scale=trunc(iw/2)*2:trunc(ih/2)*2\" ./output/spectra_triangle.mp4";
#		system($command_GIFtoMP4);
#		print "Finished gif to mp4.\n";
#	}
#}
#
#
sub brode_triangle {
	#open(IN, "<", "input_triangle_O.dat") or die $!;
	#my @force_peak_O;
	#my @force_peak_O_in = <IN>;
	#print "O force peak\n";
	#for(my $i = 0; $i <= $#force_peak_O_in; $i++){
	#	chomp($force_peak_O_in[$i]);
	#	my @line_split = split(/\s+/, $force_peak_O_in[$i]);
	#	$force_peak_O[$i][0] = $line_split[0];
	#	$force_peak_O[$i][1] = $line_split[1];
	#	print "$force_peak_O[$i][0]   $force_peak_O[$i][1]\n";
	#}
	#my $OH_peak_theta = $force_peak_O[0][1];
	##my $OH_peak_r = $data[0][$force_peak_O[0][0]][3];
	#open(IN, "<", "input_triangle_C.dat") or die $!;
	#my @force_peak_C;
	#my @force_peak_C_in = <IN>;
	#print "C force peak\n";
	#for(my $i = 0; $i <= $#force_peak_C_in; $i++){
	#	chomp($force_peak_C_in[$i]);
	#	my @line_split = split(/\s+/, $force_peak_C_in[$i]);
	#	$force_peak_C[$i][0] = $line_split[0];
	#	$force_peak_C[$i][1] = $line_split[1];
	#	print "$force_peak_C[$i][0]   $force_peak_C[$i][1]\n";
	#}
	#my $CH_peak_theta = $force_peak_C[0][1];
	#my $CH_peak_r = $data[0][$force_peak_C[0][0]][3];


	my $peak_wide_C;
	my $peak_wide_O;
	#if ($energy == "2500"){
	#	$peak_wide_C = $peak_wide;
	#	$peak_wide_O = $peak_wide;
	#} elsif ($energy == "100"){
	#	$peak_wide_C = 35;
	#	$peak_wide_O = 35;
	#}
	if ($peak_wide == 0 or $peak_wide == ""){
		$peak_wide_C = $input_peak_wide_C;
		$peak_wide_O = $input_peak_wide_O;
	} else {
		$peak_wide_C = $peak_wide;
		$peak_wide_O = $peak_wide;
	}
	
	for(my $i = 0; $i < $STEP; $i++){
	        my ($x_C, $y_C, $z_C);
	        my ($x_O, $y_O, $z_O);
		my $CH_peak_r = 0;
		my $OH_peak_r = 0;
	
		#print "@peak_C\n";	
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
		#if ($S1+$S2 == 0){
		#	print "OH and CH are parallel in STEP$i.\n";
		#	exit;
		#}
		my $file = "point_plt/spectra_triangle/point".sprintf("%03d", $i).".plt";
	    open(POINT, ">", $file);
		print POINT "file_O = \"O_test/STEP$i.dat\"\n";
		print POINT "file_C = \"C_test/STEP$i.dat\"\n";
		print POINT "file_O_diff = \"O_test/STEP$i\_diff.dat\"\n";
		print POINT "file_C_diff = \"C_test/STEP$i\_diff.dat\"\n";
		print POINT "set terminal pdfcairo\n";
		print POINT "set output \"point_pdf/output-".sprintf("%03d", $i).".pdf\"\n";
		if ($average == 0) 	{
			print POINT "load \"point_plt/atom_triangle/point".sprintf("%03d", $i).".plt\"\n";
		} elsif ($average == 1) {
			print POINT "reset\n";
			print POINT "file = '../move_h_xyz/STEP$i.dat'\n";
			print POINT "Delta = 0.4\n";
			print POINT "\n";
			print POINT "stats file u 2:4 nooutput\n";
			print POINT "RowCount = STATS_records\n";
			print POINT "array ColX[RowCount]\n";
			print POINT "array ColY[RowCount]\n";
			print POINT "array ColC[RowCount]\n";
			print POINT "\n";
			print POINT "do for [i=1:RowCount] {\n";
			print POINT "	set table \$Dummy\n";
			print POINT "    	plot file u (ColX[\$0+1]=\$2):(ColY[\$0+1]=\$4) with table\n";
			print POINT "	unset table\n";
			print POINT "}\n";
			print POINT "\n";
			print POINT "do for [i=1:RowCount] {\n";
			print POINT "    x0 = ColX[i]\n";
			print POINT "    y0 = ColY[i]\n";
			print POINT "    set table \$Occurrences\n";
			print POINT "		set yrange[0:1]\n";
			print POINT "		set xr[STATS_min_x:STATS_max_x]\n";
			#print POINT "		set xy[STATS_min_y:STATS_max_y]\n";
			print POINT "       plot file u (sqrt((x0-\$2) ** 2 + (y0-\$4) ** 2) < Delta ? 1 : 0):(1) smooth frequency\n";
			print POINT "    unset table\n";
			print POINT "    set table \$Dummmy\n";
			print POINT "		set yr[0:1]\n";
			#print POINT "		set xr[STATS_min_x:STATS_max_x]\n";
			#print POINT "		set xy[STATS_min_y:STATS_max_y]\n";
			print POINT "    	plot \$Occurrences u (\$1 == 1 ? c0=\$2 : \$2):(\$0) with table\n";
			print POINT "    unset table\n";
			print POINT "    ColC[i] = c0\n";
			print POINT "}\n";
			print POINT "\n";
			print POINT "set print \$Data\n";
			print POINT "do for [i=RowCount:1:-1] {\n";
			print POINT '    print sprintf("%g\t\%g\t%g",ColX[i],ColY[i],ColC[i])'."\n";
			print POINT "}\n";
			print POINT "\n";
			#print POINT "set xrange[-2:2]\n";
			#print POINT "set zrange[-2:2]\n";
			#print POINT "set view 90, 0\n";
		}
		print POINT "reset\n";
		print POINT "\n";
		#print POINT "set title \"STEP-$i\"\n";
		print POINT "set title \"$title[$i]\"\n";
		print POINT "set size ratio -1\n";
		print POINT "set xtics -1 ,1 , 2\n";
		#print POINT "set size square\n";
		if ($normalization == 1){
			print POINT "unset xtics\n";
			print POINT "unset ytics\n";
			print POINT "unset rtics\n";
			#print POINT "set xr[-2:2]\n";
			#print POINT "set yr[-2:2]\n";
	        print POINT "set yr[-2:$yrange_max]\n";
		} else {
			print POINT "unset xtics\n";
			print POINT "unset ytics\n";
			print POINT "unset rtics\n";
			print POINT "set xr[$xrange[0]:$xrange[1]]\n";
        	print POINT "set yr[-2:$yrange_max]\n";
		}
		print POINT "pi = 3.1415 \n";
		print POINT "unset key\n";
		#print POINT "stats file_C u (\$3 * sin((\$1/180) * pi) * cos(\$2/180 * pi)) + $save_C[$i][0]):".
		#    "(\$3 * cos((\$1/180) * pi)) + $save_C[$i][2]) nooutput"
	    print POINT "plot file_C u ".
			"(((\$3/$scale_C) * sin((\$1/180) * pi) * cos(\$2/180 * pi)) + $save_C[$i][0]):".
			"(((\$3/$scale_C) * cos((\$1/180) * pi)) + $save_C[$i][2]) w l lc \"blue\"\n";
	    print POINT "replot file_O u ".
			"((\$3/$scale_O) * sin((\$1/180) * pi) * cos(\$2/180*pi)):".
			"((\$3/$scale_O) * cos((\$1/180) * pi)) w l lc \"red\"\n";
		if ($average == 1) {
			print POINT "set cbrange[0:RowCount]\n";
			print POINT "set palette rgb 33,13,10\n";
			print POINT "unset colorbox\n";
			print POINT "\n";
			print POINT "replot \$Data u 1:2:3 w p ps 0.2 pt 7 lc palette z notitle\n";
		};

		if ($CH_peak_theta - $OH_peak_theta <= 0){
			print POINT "set arrow 1 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
                        	" to ".sprintf("%9.6f", $x_O).", ".sprintf("%9.6f", $z_O).
                        	" nohead linestyle 2 lc \"purple\"\n";

			print POINT "set arrow 2 from ".sprintf("%9.6f", $save_C[$i][0]).", ".
				sprintf("%9.6f", $save_C[$i][2])." to ".sprintf("%9.6f", $x_C).", ".
				sprintf("%9.6f", $z_C)." nohead linestyle 2 lc \"purple\"\n";

	    	print POINT "set arrow 2 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
				" to ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2]).
				" nohead linestyle 2 lc \"purple\"\n";
		} else {
			my $intersection_x = 0 + ($x_O - 0) * $S1 / ($S1 + $S2);
			my $intersection_y = 0 + ($z_O - 0) * $S1 / ($S1 + $S2);
			print POINT "set arrow 1 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
				" to ".sprintf("%9.6f", $intersection_x).", ".sprintf("%9.6f", $intersection_y).
				" nohead linestyle 2 lc \"purple\"\n";
	
	    	print POINT "set arrow 2 from ".sprintf("%9.6f", 0).", ".sprintf("%9.6f", 0).
				" to ".sprintf("%9.6f", $save_C[$i][0]).", ".sprintf("%9.6f", $save_C[$i][2]).
				" nohead linestyle 2 lc \"purple\"\n";
	
	        print POINT "set arrow 3 from ".sprintf("%9.6f", $save_C[$i][0]).", ".
				sprintf("%9.6f", $save_C[$i][2])." to ".sprintf("%9.6f", $intersection_x).
				", ".sprintf("%9.6f", $intersection_y)." nohead linestyle 2 lc \"purple\"\n";

	        print POINT "replot sprintf(\"< echo ''%f %f''\", ".sprintf("%9.6f", $intersection_x).
				", ".sprintf("%9.6f", $intersection_y).") lc 'purple' pt 7 title \"spectra\"\n";
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
		if ($diff == 1){
		        print POINT "replot file_C_diff u ".
				"(((\$3/$scale_C + 0.5) * sin((\$1/180) * pi) * cos(\$2/180 * pi)) + $save_C[$i][0]):".
				"(((\$3/$scale_C + 0.5) * cos((\$1/180) * pi)) + $save_C[$i][2]) w l lc \"blue\"\n";
		        print POINT "replot file_O_diff u ".
				"((\$3/$scale_O + 0.5) * sin((\$1/180) * pi) * cos(\$2/180*pi)):".
				"((\$3/$scale_O + 0.5) * cos((\$1/180)*pi)) w l lc \"red\"\n";
		}
	
		
		print POINT "replot\n";
		#print POINT "reset\n";
	    close(POINT);
	    if ($output == 3){
	    	system("gnuplot $file");
	        system("$IM -density 300 point_pdf/output-".
				sprintf("%03d", $i).".pdf -layers flatten point_png/output-".
				sprintf("%03d", $i).".png");
		}
	
	
	}
	if ($output == 3){
		system("rm -rf ./output/spectra_triangle.mp4");
		my $command_PNGtoGIF = "$IM -delay 100 ./point_png/output-*.png ./output/output_point.gif";
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
#sub input_parameter {
#	open(IN, "<", "input_methanol.txt") or die "No found input_methanol.txt\n";
#	while(my $line = <IN>){
#		chomp($line);
#		$line =~ s/ |\t//g;
#		if ($line =~ /^structure_file/){
#                        $line =~ /structure_file="(.*)"/;
#                        $input_file = $1;
#                }
#		if ($line =~ /^energy/){
#                        $line =~ /energy="(.*)"/;
#                        $energy = $1;
#                }
#		if ($line =~ /^peak_wide/){
#			$line =~ /peak_wide="(.*)"/;
#			$peak_wide = $1;
#		}
#	}
#}
sub input_parameter {
	open(IN, "<", "input_methanol_triangle.txt") or die "No found input_methanol.txt\n";
        while(my $line = <IN>){
                chomp($line);
                $line =~ s/ |\t//g;
                if ($line =~ /^structure_file/){
                        $line =~ /structure_file="(.*)"/;
                        $input_file = $1;
                }
                if ($line =~ /^step/){
                        $line =~ /step="(.*)"/;
                        $STEP = $1;
                }
                if ($line =~ /^C_energy/){
                        $line =~ /C_energy="(.*)"/;
						&in_para_check($1, "C_energy");
                        $C_energy = $1;
                }
                if ($line =~ /^O_energy/){
                        $line =~ /O_energy="(.*)"/;
						&in_para_check($1, "O_energy");
                        $O_energy = $1;
                }
                if ($line =~ /^peak_wide/){
                        $line =~ /peak_wide="(.*)"/;
						#&in_para_check($1, "peak_wide");
                        $peak_wide = $1;
                }
                if ($line =~ /^C_peak_wide/){
                        $line =~ /C_peak_wide="(.*)"/;
						&in_para_check($1, "peak_wide_C");
                        $input_peak_wide_C = $1;
                        $peak_wide = 0;
                }
                if ($line =~ /^O_peak_wide/){
                        $line =~ /O_peak_wide="(.*)"/;
						&in_para_check($1, "peak_wide_O");
                        $input_peak_wide_O = $1;
                        $peak_wide = 0;
                }
                if ($line =~ /^C_first_peak/){
                        $line =~ /C_first_peak="(.*)"/;
						&in_para_check($1, "C_first_peak");
                        $CH_peak_theta = $1;
                }
                if ($line =~ /^O_first_peak/){
                        $line =~ /O_first_peak="(.*)"/;
						&in_para_check($1, "O_first_peak");
                        $OH_peak_theta = $1;
                }
        }
}

sub in_para_check {
	if ($_[0] == ""){
		print("ERRER : Check input file in $_[1] line.\n");
		exit(1);
	}
}



sub option{
	if (my ($result) = grep { $ARGV[$_] eq '-help' } 0 .. $#ARGV) {
                print "movie.pl program make atom and spectra movie.\n";
                print "--------------------------------------------------------------------------\n";
                print "options\n";
		#print "  -o [filename]   |name output file\n";
                print "  -norma          |atom distance normalize\n";
                print "  -ave            |not plot atom triangle\n";
                print "  -version, -v    |display version information\n";
                print "  -help           |show help\n";
                exit(0);
        }

	if (my ($result) = grep { $ARGV[$_] eq '-version' || $ARGV[$_] eq '-v' } 0 .. $#ARGV) {
                print "movie.pl 1.0.0\n";
                exit(0);
        }

	#if (my ($result) = grep { $ARGV[$_] eq '-o' } 0 .. $#ARGV) {
	#        if ($ARGV[$result + 1]) {
	#                $output_file = $ARGV[$result + 1];
	#                splice(@ARGV, $result, 2);
	#        } else {
	#                print "Please enter output file name.\n";
	#                exit(1);
	#        }
	#}

	if (my ($result) = grep { $ARGV[$_] eq '-norma' } 0 .. $#ARGV) {
		$normalization = 1;
	        splice(@ARGV, $result, 1);
	}
	
	if (my ($result) = grep { $ARGV[$_] eq '-ave' } 0 .. $#ARGV) {
		$average = 1;
	        splice(@ARGV, $result, 1);
	}
	
	if (my ($result) = grep { $ARGV[$_] eq '-atomplt' } 0 .. $#ARGV) {
		$atom_plot = 1;
	        splice(@ARGV, $result, 1);
	}
	
        if (@ARGV == 1){
                $input_file = $ARGV[0];
        } elsif (@ARGV != 0) {
                print "Please chack option.\n";
                exit(1);
        }
}
