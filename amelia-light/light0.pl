#!/usr/bin/perl -w
use strict;

# this is put in a cgi-bin dir somewhere. the listen_dir and post_dir paths have to be set up for IPC . I've used sshfs to do this.

use CGI;
use JSON;
use Time::HiRes qw/usleep/;
use Data::Dumper;

##### my $listen_dir = '/home/khoskin/sshfs_khoskin_raspberry_pi/tmp/amelia_lights/listen/';

# TODO some stuff that checks that the sshfs mounts to the following is actually setup :-
#my $listen_dir = "/home/www-data/sshfs_khoskin_raspberry_pi/tmp/amelia_lights/listen/";
#my $post_dir = "/home/www-data/sshfs_khoskin_raspberry_pi/tmp/amelia_lights/post/";

my $imgwebroot = "/img/";

my $listen_dir = "/tmp/amelia_lights/listen/";
my $post_dir = "/tmp/amelia_lights/post/";

#sshfs khoskin@192.168.1.9:/ /home/www-data/sshfs_khoskin_raspberry_pi/

my $q = CGI->new;
    print $q->header('text/html');

if ( ! -d $listen_dir ) {
    print "can't access the listen_dir\n";
    exit 0;
}

if ( ! -d $post_dir ) {
    print "can't access the post_dir\n";
    exit 0;
}

my $json = JSON->new->allow_nonref;
my $data_out = { } ; ##    $room_light_0 => 0, ## or 1,  ## or "invert"

my $room = $q->param("room") || "bathroom";
my $light0exists = $q->param("light0");
if (  defined $light0exists ) {

    $data_out->{"${room}_light_0"} = $q->param("state");

    my $filename = $listen_dir."/".time."data.out";
    my $json_text = $json->pretty->encode ( $data_out );
    burp ( $filename , $json_text );
    system ( "mv $filename $filename.lights.cmd" );
    usleep 150000;

}
my $json_status = slurp ( $post_dir."/status");
my $statty_stuff = $json->decode( $json_status );

#my $serialised_statty_stuff = $statty_stuff->{${room}_lights_state};


my $stylight = ''; #get_style( $statty_stuff->{${room}_lights_config}{"${room}_light_$i"}{current_state});

my $lightimg = get_light_img( $statty_stuff->{gpio_conf}{"${room}_light_0"}{current_state} );


####################################################

my $styswitch = get_style( $statty_stuff->{gpio_conf}{"${room}_light_switch_detect"}{current_state} );
my $wallswitchimg=get_wall_switch_img($statty_stuff->{gpio_conf}{"${room}_light_switch_detect"}{current_state});

sub get_style {
    if ( $_[0] ) {
        return "background-color: yellow";
    } else {
        return "background-color: grey";
    }
}

sub get_light_img {
    if ( $_[0] ) {
        return "$imgwebroot/yellow-light.png";  # on
    } else {
        return "$imgwebroot/grey-light.png";  # off
    }
}

sub get_wall_switch_img {
    if ( $_[0] ) {
        return "$imgwebroot/light-switch-icon-on.jpg";  # on
    } else {
        return "$imgwebroot/light-switch-icon-off.jpg";  # off
    }
}

sub slurp {
    my ( $file ) = @_;
    open( my $fh, $file ) or die "sudden flaming death\n";
    my $text = do { local( $/ ) ; <$fh> } ;
    return $text;
}

sub burp {
    my( $file_name ) = shift ;
    open( my $fh, ">" , $file_name ) ||
                     die "can't create $file_name $!" ;
    print $fh @_ ;
}

my $switchleft  = "$imgwebroot/light-switch-left-cl.jpg";
my $switchright = "$imgwebroot/light-switch-right-cl.jpg";

# image sizing 
my $sizemin = 10;
my $sizemax = 120;

my $size  = $q->param('size') || 40;
$size = $sizemin if ( $size < $sizemin );
$size = $sizemax if ( $size > $sizemax );
my $heightspacer = $size;
my $heightmain   = $size*3;

my $sizesmaller = $size - 5;
my $sizebigger  = $size + 5;

print <<"EOSTR";

<html>

<head>
<title>$room Lights</title>

<!-- <link rel=STYLESHEET type="text/css" href="main.css"> -->

<meta name="author" content="Khoskin">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />

<!-- <script language="JavaScript" src="./mouseover.js" type="text/javascript"></script> -->


<style>

tr {height:$size; }

td.spacer { width:20;}

</style>


</head>

<body>

<!-- <div style='vertical-align:middle;height:100%;margin-left:auto;margin-right:auto;' > -->

<div align='center'>

<br><br><br>

<table style='vertical-align:middle;' border='0' cellpadding='0' cellspacing='0' >

<tr align='center'><td colspan='11'><img src='/blank.jpg' height='$heightspacer' alt='' ></td> </tr>

<tr align='center'>
   <td colspan='2' style='$stylight'><a href='?light0&state=invert&size=$size&room=$room' accesskey="1" ><img src='$lightimg' height='$heightmain' alt='1' ></a></td>
   <td class='spacer'></td>

   <td colspan='2'><a href='/cgi-bin/light0.pl?size=$size&room=$room' ><img src='$imgwebroot/refresh.png' height='$heightmain' alt='REFRESH' ></a></td>
   <td class='spacer'></td>
   <td colspan='2' ><img src='$wallswitchimg' height='$heightmain' alt='SWITCH' ></td>
   <td class='spacer'></td>
   <td colspan='2' ><a href='/cgi-bin/light0.pl?size=$sizesmaller&room=$room' ><img src='$imgwebroot/down-arrow.png' height='$heightmain' alt='Smaller' ></a></td>
   <td class='spacer'></td>
   <td colspan='2' ><a href='/cgi-bin/light0.pl?size=$sizebigger&room=$room'  ><img src='$imgwebroot/up-arrow.png'   height='$heightmain' alt='Bigger'  ></a></td>
</tr>

</table>

</div>

</body>
</html>

EOSTR

;



