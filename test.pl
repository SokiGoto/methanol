#!/usr/bin/perl
use strict;
use warnings;

use Math::Trig;
use Math::Trig ":radial";
use POSIX qw(floor ceil);

my $input_file;
my $energy;
my $absorbing_atom;
my $STEP;
my $Number_of_atoms = 6;
my $extra_line = 2;
my $total_line = $Number_of_atoms + $extra_line;

my @O_data;
my @C_data;
my @OC_dicetance;

my $max_intensity = 0;
my $min_intensity = 10**9;

&input_parameter;


open(IN, "<", $input_file) or die ("$input_file : $!");
my @lines = <IN>;
close (IN);
my $lines_len = @lines;
$STEP = $lines_len/($Number_of_atoms+$extra_line);

open(OUT, ">", "R_I.dat");
for (my $i = 0; $i < $STEP; $i++){
	print "STEP$i\n";
	my $var = $i*$total_line;

	for (my $j = $extra_line; $j < $Number_of_atoms + $extra_line; $j++){
        	my @data = split(/\s+/, $lines[$var + $j]);
	        if ($data[0] eq "O"){
			$O_data[$i][1] = $data[1];
			$O_data[$i][2] = $data[2];
			$O_data[$i][3] = $data[3];
	        }
	        if ($data[0] eq "C"){
			$C_data[$i][1] = $data[1];
			$C_data[$i][2] = $data[2];
			$C_data[$i][3] = $data[3];
	        }
	}
	my $OC_x = $C_data[$i][1]-$O_data[$i][1];
	my $OC_y = $C_data[$i][2]-$O_data[$i][2];
	my $OC_z = $C_data[$i][3]-$O_data[$i][3];
	$OC_dicetance[$i] = sqrt($OC_x*$OC_x + $OC_y*$OC_y + $OC_z*$OC_z);
	my ($OC_r, $OC_theta, $OC_phi) = cartesian_to_spherical($OC_x, $OC_y, $OC_z);
	$OC_theta = rad2deg($OC_theta);
	$OC_phi = rad2deg($OC_phi);
	print "$OC_r  $OC_theta   $OC_phi\n";
	

	#print OUT "$OC_dicetance[$i]\n";

	#perl -pi <= theta <= pi   xy
	#msspec 0 <= theta <= 2pi  xy
	#perl 0 <= phi <= pi       z
	#msspec 0 <= phi <= pi     z
	#perl to msspec if theta < 0  (360-theta)
		
	if ($OC_theta < 0){
		$OC_theta = 360 + $OC_theta;
	}
	# r -> [0], theta -> [1], phi -> [2]
	my @OC_point_00;
	my @OC_point_01;
	my @OC_point_10;
	my @OC_point_11;

	($OC_point_00[1], $OC_point_00[2]) = (floor($OC_theta), floor($OC_phi));
	($OC_point_01[1], $OC_point_01[2]) = (floor($OC_theta), ceil($OC_phi));
	($OC_point_10[1], $OC_point_10[2]) = (ceil($OC_theta), floor($OC_phi));
	($OC_point_11[1], $OC_point_11[2]) = (ceil($OC_theta), ceil($OC_phi));

	my $OC_p = $OC_theta - floor($OC_theta);
	my $OC_q = $OC_phi - floor($OC_phi);

	print "$OC_point_00[1], $OC_point_00[2]\n";
	print "$OC_point_01[1], $OC_point_01[2]\n";
	print "$OC_point_10[1], $OC_point_10[2]\n";
	print "$OC_point_11[1], $OC_point_11[2]\n";

	
	my $CO_x = $O_data[$i][1]-$C_data[$i][1];
	my $CO_y = $O_data[$i][2]-$C_data[$i][2];
	my $CO_z = $O_data[$i][3]-$C_data[$i][3];
	my ($CO_r, $CO_theta, $CO_phi) = cartesian_to_spherical($CO_x, $CO_y, $CO_z);
	$CO_theta = rad2deg($CO_theta);
	$CO_phi = rad2deg($CO_phi);
	print "$CO_r  ".rad2deg($CO_theta)."  ".rad2deg($CO_phi)."\n";


	if ($CO_theta < 0){
                $CO_theta = 360 + $CO_theta;
        }
        # r -> [0], theta -> [1], phi -> [2]
        my @CO_point_00;
        my @CO_point_01;
        my @CO_point_10;
        my @CO_point_11;

        ($CO_point_00[1], $CO_point_00[2]) = (floor($CO_theta), floor($CO_phi));
        ($CO_point_01[1], $CO_point_01[2]) = (floor($CO_theta), ceil($CO_phi));
        ($CO_point_10[1], $CO_point_10[2]) = (ceil($CO_theta), floor($CO_phi));
        ($CO_point_11[1], $CO_point_11[2]) = (ceil($CO_theta), ceil($CO_phi));

        my $CO_p = $CO_theta - floor($CO_theta);
        my $CO_q = $CO_phi - floor($CO_phi);

        print "$CO_point_00[1], $CO_point_00[2]\n";
        print "$CO_point_01[1], $CO_point_01[2]\n";
        print "$CO_point_10[1], $CO_point_10[2]\n";
        print "$CO_point_11[1], $CO_point_11[2]\n";




	open(IN_DATA, "<", "plot-data/STEP$i.dat") or die $!;
	while (my $line = <IN_DATA>){
		chomp($line);
		if ($line =~ /^\s*$/){
			next;
		}
		my @data = split(/\s+/, $line);
		#print "$data[1]\n";
		if ($data[1] == $OC_point_00[2] and $data[2] == $OC_point_00[1]){
			print "$line\n";
			$OC_point_00[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $OC_point_01[2] and $data[2] == $OC_point_01[1]){
			print "$line\n";
			$OC_point_01[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $OC_point_10[2] and $data[2] == $OC_point_10[1]){
			print "$line\n";
			$OC_point_10[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $OC_point_11[2] and $data[2] == $OC_point_11[1]){
			print "$line\n";
			$OC_point_11[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $CO_point_00[2] and $data[2] == $CO_point_00[1]){
			print "$line\n";
			$CO_point_00[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $CO_point_01[2] and $data[2] == $CO_point_01[1]){
			print "$line\n";
			$CO_point_01[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $CO_point_10[2] and $data[2] == $CO_point_10[1]){
			print "$line\n";
			$CO_point_10[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
		if ($data[1] == $CO_point_11[2] and $data[2] == $CO_point_11[1]){
			print "$line\n";
			$CO_point_11[0] = ($data[3] + $data[6] + $data[9])/3.0;
		}
	}

	my $OC_intensity = (1-$OC_q)*(1-$OC_p)*$OC_point_00[0] + $OC_p*(1-$OC_q)*$OC_point_10[0] +
		$OC_q*(1-$OC_p)*$OC_point_01[0] + $OC_p*$OC_q*$OC_point_11[0];
	print "$OC_point_00[0]  $OC_point_01[0]  $OC_point_10[0]  $OC_point_11[0] : $OC_intensity\n";
	
	my $CO_intensity = (1-$CO_q)*(1-$CO_p)*$CO_point_00[0] + $CO_p*(1-$CO_q)*$CO_point_10[0] +
		$CO_q*(1-$CO_p)*$CO_point_01[0] + $CO_p*$CO_q*$CO_point_11[0];
	print "$CO_point_00[0]  $CO_point_01[0]  $CO_point_10[0]  $CO_point_11[0] : $CO_intensity\n";

	
	if ($max_intensity < $OC_intensity){
		$max_intensity = $OC_intensity;
	}
	if ($min_intensity > $OC_intensity){
		$min_intensity = $OC_intensity;
	}
	if ($max_intensity < $CO_intensity){
		$max_intensity = $CO_intensity;
	}
	if ($min_intensity > $CO_intensity){
		$min_intensity = $CO_intensity;
	}

	print OUT "$i  $OC_dicetance[$i]  $OC_intensity $CO_intensity\n";
	print "\n";
}
close(OUT);

my $intensity_diff = $max_intensity-$min_intensity;
my $scale = 1/$intensity_diff;
#my $scale = 1/$min_intensity;

my $title1;
my $title2;
if ($absorbing_atom eq "O"){
	$title1 = "forward";
	$title2 = "backword";
} elsif ($absorbing_atom eq "C"){
        $title1 = "backword";
	$title2 = "forward";
}


open(PLT, ">", "T_I.plt");
print PLT "set terminal pdfcairo"."\n";
print PLT "set output \"T_I.pdf\"\n";
print PLT "set ytics nomirror\n";
print PLT "set y2tics nomirror\n";
print PLT "\n";
print PLT "set title \"$absorbing_atom 1s ".$energy."eV\"\n";
print PLT "set format x \"%g\"\n";
print PLT "set format y \"%2.1f\"\n";
print PLT "set format y2 \"%2.1f\"\n";
print PLT "\n";
print PLT "set xlabel \"Time\"\n";
print PLT "set ylabel \"Intensity\"\n";
print PLT "set y2label \"R(t) (a.u.)\"\n";
print PLT "\n";
print PLT "plot \"R_I.dat\" u 1:($scale*\$3) axis x1y1 w l lw 3 title \"$title1\", \\\n";
print PLT "        \"R_I.dat\" u 1:($scale*\$4) axis x1y1 w l lw 3 title \"$title2\", \\\n";
print PLT "        \"R_I.dat\" u 1:(((sin(2*sqrt(2*$energy/27.21162)*\$2 + 0.5 ) + ".
	sprintf("%.1f", ($intensity_diff*$scale)+1).
	")/\$2)) axis x1y1 w l lw 3 title \"sin(2kR+0.5) + ".
	sprintf("%.1f", ($intensity_diff*$scale)+1)."\", \\\n";
print PLT "        \"R_I.dat\" u 1:2 axis x1y2 w l lw 3 title \"R\"\n";
close(PLT);

system("gnuplot T_I.plt");
system("magick -density 300 T_I.pdf -layers flatten T_I.png");
system("rm -rf T_I.pdf");


open(PLT_RI, ">", "R_I.plt");
print PLT_RI "set terminal pdfcairo\n";
print PLT_RI "set output \"R_I.pdf\"\n";
print PLT_RI "set xlabel \"R\"\n";
print PLT_RI "set ylabel \"Intensity\"\n";
print PLT_RI "set title \"$absorbing_atom 1s ".$energy."eV\"\n";
print PLT_RI "set format x \"%g\"\n";
print PLT_RI "set format y \"%2.1f\"\n";
print PLT_RI "plot \"R_I.dat\" u 2:($scale*\$3) w l lw 3 title \"$title1\", \\\n";
print PLT_RI "		\"R_I.dat\" u 2:($scale*\$4) w l lw 3 title \"$title2\", \\\n";
#print PLT_RI "		\"R_I.dat\" u 2:(sin(2*sqrt(2*$energy/27.21162)*\$2)) w l lw 3 title \"sin(2kR)\"\n";
close(PLT_RI);
system("gnuplot R_I.plt");
system("magick -density 300 R_I.pdf -layers flatten R_I.png");
system("rm -rf R_I.pdf");


##### subroutine ############################################################################
sub input_parameter {
        open(IN, "<", "input_methanol.txt") or die "not found input_methanol.txt";
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

