#!/usr/bin/perl -w
use strict;

my $current_prt_level=5;
my $i2c_y = 1; # the i2c bus. some pis have 2 of these.



#print "switch relay\n";
#do_system( "i2cset -y $i2c_y 0x20 0x00 0x00" ,5);
#do_system( "i2cset -y $i2c_y 0x20 0x01 0x00" ,5);
#
#for my $out ( qw/0x01 0x02 0x04 0x08 0x10 0x20 0x40 0x80/ ) {
##sleep 1;
#	do_system( "i2cset -y $i2c_y 0x20 0x15 $out " ,5);
#}
#


# exit 1;

#######################
print "scan 64 lines of i2c io \n";
# level 1 is the highest import messages.
# level 5 just lots of rubbish.

# speed the i2c bus up a bit :-
do_system("sudo modprobe -r i2c_bcm2708 && sudo modprobe i2c_bcm2708 baudrate=400000" , 5);
#do_system("sudo modprobe -r i2c_bcm2708 && sudo modprobe i2c_bcm2708 baudrate=100000" , 5);






my $i2cAddr = [ "0x20", "0x21", "0x23" ];
#my $i2cAddr = [ "0x20", "0x21", "0x22" ];

my %change = {};
for my $thisi2cadd ( @{$i2cAddr}){
	$change{$thisi2cadd}{a}="0x00";
	$change{$thisi2cadd}{b}="0x00";
	# configure the A port all to input 
	# 0x00 == IODIRA
        # 0xff == set the direction all to input
	do_system( "i2cset -y $i2c_y $thisi2cadd 0x00 0xFF" ,5);

	# 0x01 == IODIRB
	do_system( "i2cset -y $i2c_y $thisi2cadd 0x01 0xFF" ,5);

}

my $out;
my $change = "";
my %get_aORb = ( a=>"0x12", b=>"0x13" );
while (1) {
	$change="";
#	$out = "";
	for my $thisi2cadd ( @{$i2cAddr}){

#		$out .= "$thisi2cadd ";
		for my $aORb ( keys %get_aORb ){	
			my $get_gpio = qx{i2cget -y $i2c_y $thisi2cadd $get_aORb{$aORb} };
			chomp $get_gpio;
			if ( $change{$thisi2cadd}{$aORb} ne $get_gpio ){
				$change .= "$thisi2cadd $aORb $get_gpio : ";
			}
			$change{$thisi2cadd}{$aORb} = $get_gpio;

#			$out .= "$aORb $get_gpio ";
		}
#		$out .= ": ";

	}
	print "CHANGED ".time." $change\n" if $change;
#	print "$out\n";
}

sub do_system {
	my ($cmd , $prt_level ) = @_;

	$prt_level=5 if !defined $prt_level;

	print $cmd."\n" if $prt_level <= $current_prt_level;
	system ( $cmd );
}
