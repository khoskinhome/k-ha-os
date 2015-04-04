#!/usr/bin/perl -w
use strict;
use Time::HiRes qw/usleep/;

use Term::ReadKey;
my $use_readkey = 0;

use Data::Dumper;
use JSON;

my $current_prt_level=1;
my $i2c_y = 1; # the i2c bus. some pis have 2 of these.

print "switch relay\n";

use integer;


=pod

need a daemon that listens to instructions such as

    amelia_light_0 "on"
    amelia_light_0 "off"

    amelia_light_all "on"
    amelia_light_all "off"

it will also poll the state of the wall switch and either
switch all lights on or all lights off.

all the lights will be switched on if less than 5 lights are currently on.

all the lights will be switched off if 5 or more lights are currently on.

need an object that

=cut

my $listen_dir = '/tmp/amelia_lights/listen/';
my $post_dir = '/tmp/amelia_lights/post/';

# The /tmp dir really needs to be mounted with tmpfs. too much writing to SD cards will knacker them.

system ( "mkdir -p $listen_dir" ) ;

system ( "sudo chgrp www-data $listen_dir" );
system ( "sudo chmod 775      $listen_dir" );

system ( "mkdir -p $post_dir" ) ;

system ( "sudo modprobe i2c-dev" );
system ( "sudo chmod o+rw /dev/i2c*");

system ( "sudo modprobe -r i2c_bcm2708 && sudo modprobe i2c_bcm2708 baudrate=400000");

mkdir -p $listen_dir;
mkdir -p $post_dir;

my $json = JSON->new->allow_nonref;


my $mcp23017_registers = {

    IODIRA => '0x00', # IODIR A/B are used to set the direction of the gpio pin 0 for output, 1 for input.
    IODIRB => '0x01',

    GPIOA  => '0x12', # GPIO A/B are used to get the input on a gpio port
    GPIOB  => '0x13',

    OLATA  => '0x14', # OLAT A/B are used to switch on and off the outputs on a gpio port.
    OLATB  => '0x15',

};

my $i2c_bus_y = 1;

my $gpio_conf = {

	amelia_light_0 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 0,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_1 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 1,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_2 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 2,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_3 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 3,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_4 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 4,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_5 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 5,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_6 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 6,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_7 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 7,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_8 => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 7,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_change_over => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 6,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},
	amelia_light_switch_detect => {
		y => $i2c_bus_y,
		i2cAddr => '0x20', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 5,      # 0 -> 7
        # intial  => 1, doesn't do anything on an input GPIO.
		inORout => 1,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

};


sub amelia_lights_all_off {
    for my $i (  sort keys %$gpio_conf ) {
        # TODO we have hardcoding in the following line. This is bad.
        if ( $i =~ /^amelia_light_\d/){
            set_gpio_output_hash($i,'0');
        }
    }

    commit_gpio_output();
}

sub amelia_lights_all_on {
    for my $i (  sort keys %$gpio_conf ) {
        # TODO we have hardcoding in the following line. This is bad.
        if ( $i =~ /^amelia_light_\d/){
            set_gpio_output_hash($i,'1');
        }
    }
    commit_gpio_output();
}

sub amelia_lights_all_invert {
    if ( ! amelia_lights_more_on() ) {
        amelia_lights_all_on;
    } else {
        amelia_lights_all_off;
    }
}

sub amelia_lights_get_state_string {
    # return a string representing all the amelia_light_xxxx states.

    my $state_string = '';
    for my $i (  sort keys %$gpio_conf ) {
        # TODO we have hardcoding in the following line. This is bad.
        if ( my ( $part ) = $i =~ /^amelia_light_(.*)/){
            $state_string .= ":" if $state_string;
            $state_string .= "$part=".$gpio_conf->{$i}{current_state};
        }
    }

    # data is duplicated in this structure, but I don't know how I want to use it yet.
    my $data_out = {
        amelia_lights_config       => $gpio_conf,
        amelia_lights_on_count     => amelia_lights_on_count(),
        amelia_lights_switch_state => get_switch_state(),
        amelia_lights_more_on      => amelia_lights_more_on(),
        amelia_lights_state        => $state_string,
    };

#    print "CURRENT STATE\n#######\n";
#    print "switch is               = ".get_switch_state()."\n";
#    print "lights on count         = ".amelia_lights_on_count()."\n";
#    print "more lights on than off = ".amelia_lights_more_on()."\n";
#    print "light states            = ".$state_string."\n";

#my $json = JSON->new->allow_nonref;
    my $json_text = $json->pretty->encode ( $data_out );

    return $json_text;

}

sub amelia_lights_write_state_to_fs{
    burp ( $post_dir."/status", amelia_lights_get_state_string());
}

sub can_switch_off_amelia_lights_change_over {

    my $curr_switch_state = get_switch_state();
    my $amelia_lights_on_count = amelia_lights_on_count();

    # if all lights are off, and the wall-switch is off
    # we can give the change-over relay a rest and de-energise it.
    if ( $amelia_lights_on_count == 0 and $curr_switch_state == 0) {
        return 1;
    }

    # if all lights are on, the relays are energised to power up the light
    # the curr_switch_State doesn't really matter, so
    # we can give the change-over relay a rest and de-engergise it
    # TODO we have a magic number of 9 in the following. This is a bad practice.
    if ( $amelia_lights_on_count == 9 ) {
        return 1;
    }

    return 0;

}

sub amelia_lights_array_set {
    my ( $arr , $set_state ) = @_;

    print_debug ( "amelia_lights_array_set '$set_state' with ".Dumper($arr));

    # feed this function with an array of light numbers.
    # with the light numbers of 0 -> 8
    #
    # i.e. $arr = [ 0,3,6] would set all those lights to the $set_state
    #
    # set_State has to be either 1 , 0 or invert.

    if ( $set_state eq 'invert') {
        my $how_many_unique_lights = 0;

        my %hsh = map { $_ => 1 } @$arr;

        my $how_many_unique_lights = scalar keys %hsh;

        my $count_on = 0;

        for my $i ( keys %hsh ){
            $count_on += $gpio_conf->{"amelia_light_$i"}{current_state};
        }

        if ( $count_on*2 > $how_many_unique_lights) {
            # if more than half the lights are currently on, switch them all off
            $set_state='0'
        } else {
            $set_state='1'; # otherwise switch them 'on'
        }

        print_debug ( "amelia_lights_array_set count_on = $count_on\n\n" );
    }

    for my $i ( @$arr ) {
        set_gpio_output_hash("amelia_light_$i", $set_state);
    }

    commit_gpio_output();

}

sub amelia_lights_more_on {

    # returns 1 if more of the lights are on.
    # returns 0 if more of the lights are off.

    # magic number in the following . TODO this should be worked out by the config.
    return amelia_lights_on_count() > 4 ? 1 : 0;
}

sub amelia_lights_on_count {
    # returns a count of how many lights are on.

    my $on_count = 0;
    for my $i (  sort keys %$gpio_conf ) {
        # TODO we have hardcoding in the following line. This is bad.
        next if $i !~ /^amelia_light_\d$/;
        $on_count += $gpio_conf->{$i}{current_state};
    }

    return $on_count;
}

{

    my $i2cset_register = {};

    my $i2cset_register_committed = 0;

    # get the current output hash,
    # adjust the values.
    # don't push anything to i2cset, to do that you have to commit_gpio_output()
    sub set_gpio_output_hash {

        $i2cset_register_committed = 0;
        my ( $set_port_name , $set_state, $g_initial ) = @_;
        # TODO some mechanism to see if this is called more than once with $initial = 1. die if it is.

        # $gpio_conf as per the standard
        #
        # $set_port_name = something like amelia_light_5 or undef. has to be either undef or a valid portname.
        # $set_state = undef, 1 or 0 or 'invert' , where 1 energises the relay, 0 de-energises, and 'invert' changes it from its current state.
        #
        # $initial is set to 1 , and is called once at the beginning of the script.
        # this will initialise the ports into the initial state.
        # when $initial=1 then anything in $portname and $state is completely ignored.
        if ( $g_initial ) {
            for my $port_name ( keys %$gpio_conf ) {
                _set_gpio_output_hash( $port_name , undef , $g_initial );
            }
        } else {
            _set_gpio_output_hash( $set_port_name, $set_state, undef );

        }
        print_debug ( "Dumper of i2cset register =".Dumper ($i2cset_register),5);

    }

    sub _set_gpio_output_hash {

        my ( $port_name , $set_state, $g_initial ) = @_;

        # TODO parameter checking.
        if (! $g_initial && $set_state ne '0' && $set_state ne '1' && $set_state ne 'invert' ){
            die "port_name=$port_name , set_state=$set_state, g_initial=$g_initial . Can't set state . illegal set_state=$set_state\n";
        }

        my $gpio = $gpio_conf->{$port_name};

        # TODO validate all this stuff :-
        my $y            = "-y ".$gpio->{y};
        my $i2cAddr      = $gpio->{i2cAddr};
        my $portnum      = $gpio->{portnum};
        my $port         = $gpio->{port};
        my $inORout      = $gpio->{inORout};
        my $port_initial = $gpio->{initial};

        my $register = $mcp23017_registers->{"OLAT".uc($port)};

        print_debug ( "$port_name $i2cAddr $portnum $port $inORout", 5) ;

        $i2cset_register->{$y}{$i2cAddr}{$register} = 255 if ! defined $i2cset_register->{$y}{$i2cAddr}{$register};
        #$i2cset_register->{$y}{$i2cAddr}{$register} = 255 if $g_initial;

        my $reg = $i2cset_register->{$y}{$i2cAddr} ;

#        my $bit_state = $regs->{$register} & ( 2 ** $portnum ) ? 1 : 0 ;

        if ( $inORout ){
            # gpio input . Do NOTHING !
        } else {
            # gpio output
            if ( $g_initial ) {
                if ( $port_initial ) {
                    # setting the bit off, switches the relay on !! doh !
                    $reg->{$register} = set_bit_off( $reg->{$register}, $portnum );
                } else {
                    # setting the bit on, switches the relay off !! doh !
                    $reg->{$register} = set_bit_on( $reg->{$register}, $portnum );
                }
            } else {

                if ( $set_state eq '1' ) {
                    # setting the bit off, switches the relay on !! doh !
                    $reg->{$register} =  set_bit_off( $reg->{$register}, $portnum );
                } elsif ( $set_state eq '0' ) {
                    # setting the bit on, switches the relay off !! doh !
                    $reg->{$register} = set_bit_on( $reg->{$register}, $portnum );
                } elsif ( $set_state eq 'invert' ) {
                    $reg->{$register} = set_bit_invert( $reg->{$register}, $portnum );
                } else {
                    die "can't set state . illegal set_state=$set_state\n";
                }
            }

            # the current_state of the relay is the inverse of the bit state, hence the "? 0 : 1 ;" >>
            $gpio->{current_state} = get_bit( $reg->{$register}, $portnum ) ? 0 : 1;
        }
    }

    # so :-
    #   OR with 1 to set something ON
    #   AND with 0 to set something OFF

    sub get_bit {
        my ( $number, $bitnumber ) = @_ ;
        return $number & (2 ** $bitnumber) ? 1 : 0 ;
    }

    sub set_bit_on {
        my ( $number, $bitnumber ) = @_ ;

        # where $number is say 0xF0
        # and $bitnumber is from 0 -> 7
        # returns the 8 bit number with the bitnumber set on.

        return $number | ( 2 ** $bitnumber ) ;

    }

    sub set_bit_off { # this sub will only work on 8 bit numbers.
        my ( $number, $bitnumber ) = @_ ;

        # where $number is say 0xF0
        # and $bitnumber is from 0 -> 7

        # returns the 8 bit number with the bitnumber set off.

        # ex-or 255 with the bitnumber to get all the bits we want to be left on
        # then & this result with $number and the specific bit will be set off.

        return $number & ( 255 ^ (2 ** $bitnumber));
    }

    sub set_bit_invert { # this sub will only work on 8 bit numbers.
        my ( $number, $bitnumber ) = @_ ;

        my $bit_state = $number & ( 2 ** $bitnumber ) ? 1 : 0 ;
        if ( $bit_state ) {
            return set_bit_off( $number, $bitnumber);
        }
        return set_bit_on( $number, $bitnumber);
    }


    # actually push the commands to ic2set.
    sub commit_gpio_output {

        # if it is already fully committed we don't need to i2cset it.
        #return if $i2cset_register_committed;

        # see if we can save the amelia_lights change over from being permanently on.
        if ( can_switch_off_amelia_lights_change_over() ) {
            set_gpio_output_hash("amelia_light_change_over",'0');
        } else {
            set_gpio_output_hash("amelia_light_change_over",'1');
        }

        amelia_lights_write_state_to_fs();

        issue_i2c_cmd ( "i2cset" , $i2cset_register ) ;
        $i2cset_register_committed = 1;
    }

    sub get_i2cset_is_committed {
        return $i2cset_register_committed;
    }

}

sub set_gpio_iodir {

    my $i2cset_data = {};

    for my $port_name ( keys %$gpio_conf ) {

        my $gpio = $gpio_conf->{$port_name};

        # TODO validate all this stuff :-
        my $y       = "-y ".$gpio->{y};
        my $i2cAddr = $gpio->{i2cAddr};
        my $portnum = $gpio->{portnum};
        my $port    = $gpio->{port};
        my $inORout = $gpio->{inORout};

        my $iodir = $mcp23017_registers->{"IODIR".uc($port)};

        print_debug( "set_gpio_dir : $port_name $i2cAddr $portnum $port $inORout" );

        $i2cset_data->{$y}{$i2cAddr}{$iodir} = 0 if ! defined $i2cset_data->{$y}{$i2cAddr}{$iodir};

        if ( $inORout ){
            $i2cset_data->{$y}{$i2cAddr}{$iodir} = $i2cset_data->{$y}{$i2cAddr}{$iodir}
                | ( 2 ** $portnum );
        }

    }
    issue_i2c_cmd ( "i2cset" , $i2cset_data ) ;
}

{
    my %rets ;

    sub issue_i2c_cmd {
        %rets = ();
        _issue_i2c_cmd(@_, "");
        return %rets;
    }

    sub _issue_i2c_cmd {
        my ( $i2c_cmd , $data , $txt) = @_;

        if ( ref $data eq 'HASH' ) {
            for my $d ( keys %$data ){
                my $run_this = _issue_i2c_cmd( $i2c_cmd, $data->{$d}, "$txt $d" );

                # are we going to use this method for getting input ?
                # this was going to get put into the %rets.

                do_system($run_this, 5 );
            }
        } else {
            return "$i2c_cmd $txt 0x".sprintf( "%02x", $data );
        }
    }
}

sub do_system {
	my ($cmd , $prt_level ) = @_;

	$prt_level=5 if ! defined $prt_level;

	print $cmd."\n" if $prt_level <= $current_prt_level;
	return qx{ $cmd };
}

sub print_debug {
    my ( $txt, $prt_level ) = @_;

	$prt_level=5 if ! defined $prt_level;

	print $txt."\n" if $prt_level <= $current_prt_level;

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


# now we can setup up the ports
set_gpio_iodir ( );

# set them to their initial state
set_gpio_output_hash ( undef, undef, 1 ) ; # initialise the outputs .
commit_gpio_output();

# and get the current state of the switch 

{
    my $curr_switch_state = get_switch_state();
    sub switch_state_changed {
        my $new_state = get_switch_state();


        if ($new_state ne $curr_switch_state){
            $curr_switch_state = $new_state;
            print_debug ( "switch_state is now = $new_state\n" , 5 );
            return 1;
        }

        $curr_switch_state = $new_state;
        return 0;

    }

    sub get_switch_state {
#       this really should use the config, and not be hard coded. TODO , with great urgency.

#		y => $i2c_bus_y,
#		i2cAddr => '0x20', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 5,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,      # 0 == out , 1 == in

        # HACKY , it is hard coded to use the following i2cget command :-
        my $switch_state = qx{i2cget -y $i2c_bus_y 0x20 0x12};

        chomp $switch_state;

        $switch_state = hex($switch_state);

        # HACKY !!! Not using the config.
        # it is hard coded to use port 5
        my $c_st = $switch_state & ( 2 ** 5 ) ? 1 : 0 ;

	    $gpio_conf->{amelia_light_switch_detect}{current_state} = $c_st;

        return $c_st;
    }
}


## all subs ,and setup done.

## so now actually run this stuff.

run();

sub run {
    
    ReadMode 4 if $use_readkey;

    my $all_toggle = 0;

    while (1) {
        my $key = $use_readkey ? ReadKey(-1) : '';

        if ( defined $key ){
            chomp $key;
            print_debug("key press = $key", 2 );

            if ( $key =~ m/^\d$/ && $key ){ #  invert the light at the number
                $key--;

                set_gpio_output_hash("amelia_light_$key",'invert');
                commit_gpio_output();

            } elsif ($key eq 's' ){ #display current states.

                print_debug ( amelia_lights_get_state_string(), 1 );

            } elsif ( lc($key) eq 'o'){ # o for ON
                amelia_lights_all_on() ;
            } elsif ( lc($key) eq 'p'){ # p for OFF ! ( coz its next to 'o' )
                amelia_lights_all_off() ;
            } elsif ( lc($key) eq 'i'){ # i for invert
                amelia_lights_all_invert() ;
            } elsif (lc($key) eq "x"){ # x for exit
                ReadMode 0 if $use_readkey;
                die "THE END ! \n";
            }
        }

        if (  switch_state_changed() ) {
            amelia_lights_all_invert() ;
            print_debug ( "switched !!" );
        };

        # look in the "listen_dir" and see if there are any files with commands in them.
        while ( my $file = <$listen_dir/*> ) {
            if ( $file =~ m/.lights.cmd$/ ){
                # so write a file out to some name that doesn't end in ".lights.cmd",
                # then do a "mv old-filename filename-suffixed-with.lights.cmd"
                # and it shouldn't get prematurely read and deleted by this.
                my $json_txt = slurp ( $file ) ;
                print "$file : $json_txt\n";
                unlink $file;

                my $commands = $json->decode( $json_txt );

use Data::Dumper;print STDERR "\nvidekahnum dumper of  commands  =".Dumper ($commands); # TODO rm this line
               
                for my $t_cmd ( sort keys %$commands ){
                    if ( $t_cmd =~ m/^amelia_light_(\d)$/ ) {
                        set_gpio_output_hash($t_cmd, $commands->{$t_cmd} );
                    }
                    elsif ( $t_cmd eq 'amelia_lights_all_invert' ) {
                        amelia_lights_all_invert();
                    } elsif ( $t_cmd eq 'amelia_lights_all_on' ) {
                        amelia_lights_all_on();
                    } elsif ( $t_cmd eq 'amelia_lights_all_off' ) {
                         amelia_lights_all_off();
                    } elsif ( $t_cmd eq 'amelia_lights_array_on' ) {
                         amelia_lights_array_set($commands->{$t_cmd},"1");
                    } elsif ( $t_cmd eq 'amelia_lights_array_off' ) {
                         amelia_lights_array_set($commands->{$t_cmd},"0");
                    } elsif ( $t_cmd eq 'amelia_lights_array_invert' ) {
                         amelia_lights_array_set($commands->{$t_cmd},"invert");
                    } else {
                        print "unrecognised command $t_cmd\n";
                    }
                }

                commit_gpio_output();

            }
        }

        usleep 1000;

    }

}

#sub set_to_output {
##	( $ic2_y )
#
#	do_system( "i2cset -y $i2c_y 0x20 0x00 0x00" ,5);
#	do_system( "i2cset -y $i2c_y 0x20 0x01 0x00" ,5);
#}
#
#for my $out ( qw/0x01 0x02 0x04 0x08 0x10 0x20 0x40 0x80/ ) {
##sleep 1;
#	do_system( "i2cset -y $i2c_y 0x20 0x15 $out " ,5);
#	usleep ( 50000 );
#}
#
#
#	do_system( "i2cset -y $i2c_y 0x20 0x15 0x00 " ,5);
#
#
#exit 1;
########################
#print "scan 64 lines of i2c io \n";
## level 1 is the highest import messages.
## level 5 just lots of rubbish.
#
## speed the i2c bus up a bit :-
#do_system("sudo modprobe -r i2c_bcm2708 && sudo modprobe i2c_bcm2708 baudrate=400000" , 5);
##do_system("sudo modprobe -r i2c_bcm2708 && sudo modprobe i2c_bcm2708 baudrate=100000" , 5);
#

=pod hex conv stuff

bin  h  dec
0000 0   0
0001 1   1
0010 2   2
0011 3   3
0100 4   4
0101 5   5
0110 6   6
0111 7   7
1000 8   8
1001 9   9
1010 a  10
1011 b  11
1100 c  12
1101 d  13
1110 e  14
1111 f  15

=cut 

