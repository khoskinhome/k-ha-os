#!/usr/bin/perl -w
use strict;
use Time::HiRes qw/usleep gettimeofday/;

use Term::ReadKey;
my $use_readkey = 1;

use Data::Dumper;
use JSON;

my $current_prt_level=2;
my $i2c_y = 1; # the i2c bus. some pis have 2 of these.

print "Testrig !! \n\n\n";

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


# IODIR , GPIO , OLAT are names that are refered to in the technical docs to the MCP23017
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

################ 0x27 :-

	test_light_1 => { # relay-1 on pcb
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 0,      # 0 -> 7
        initial  => 1,
		inORout => 0,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	test_light_switch_detect => { # detect 240v on light switch
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 1,      # 0 -> 7
        # intial  => 1, doesn't do anything on an input GPIO.
		inORout => 1,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	test_light_extra_switch_detect => { # an extra 5v input for a switch.
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 2,      # 0 -> 7
        # intial  => 1, doesn't do anything on an input GPIO.
		inORout => 1,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	test_light_2 => {  # relay-2 on pcb
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 3,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

###

	radiator_relay_1 => { # relay-2 on pcb
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 4,      # 0 -> 7
        initial  => 1,
		inORout => 0,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	radiator_relay_2 => {
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'a',     # a or b ONLY
		portnum => 5,      # 0 -> 7
        # intial  => 1, doesn't do anything on an input GPIO.
		inORout => 0,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

####

	test2_light_1 => { # relay-1 on pcb
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 4,      # 0 -> 7
        initial  => 1,
		inORout => 0,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	test2_light_switch_detect => { # detect 240v on light switch
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 3,      # 0 -> 7
        # intial  => 1, doesn't do anything on an input GPIO.
		inORout => 1,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	test2_light_extra_switch_detect => { # an extra 5v input for a switch.
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 2,      # 0 -> 7
        # intial  => 1, doesn't do anything on an input GPIO.
		inORout => 1,       # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},

	test2_light_2 => {  # relay-2 on pcb
		y => $i2c_bus_y,
		i2cAddr => '0x27', # i2c address of the mcp23017
		port    =>'b',     # a or b ONLY
		portnum => 1,      # 0 -> 7
        initial  => 1,
		inORout => 0,      # 0 == out , 1 == in
		current_state => 1, # gets set by prog
	},


};

sub lights_get_state_string {

    my $json_text = $json->pretty->encode ( { gpio_conf => $gpio_conf } );

    return $json_text;

}

sub write_gpio_conf_to_fs{
    burp ( $post_dir."/status", lights_get_state_string());
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

        my $prt_set_state = defined $set_state ? $set_state : '' ; 

            print_debug ( "set_gpio_output_hash port_name=>".($set_port_name||'').", state=>$prt_set_state, g_initial=>".($g_initial||''),2);
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
            warn "port_name=$port_name , set_state=$set_state, g_initial=$g_initial . Can't set state . illegal set_state=$set_state\n";
            return;
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


        write_gpio_conf_to_fs();

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

    sub get_all_inputs {

        # stores the state change in the gpio_conf data structure.
        # also returns a summarised hash of the inputs, their current state, and whether it changed.

        my %gpio_inputs = ();
        my %i2cAddr_got = (); #"y=x:address:register" = result

        my $return_inputs = {};

        for my $port_name ( keys %$gpio_conf ) {

            my $gpio = $gpio_conf->{$port_name};
            #my $y            = "-y ".$gpio->{y};
            my $i2cAddr      = $gpio->{i2cAddr};
            my $portnum      = $gpio->{portnum};
            my $port         = $gpio->{port};
            my $inORout      = $gpio->{inORout};
            my $port_initial = $gpio->{initial};

            my $port_register_hexcode = $mcp23017_registers->{"GPIO".uc($port)};


            next if ( ! $inORout ) ;

            $gpio_inputs{$port_name};

            my $timehiresnow = time; # Time::HiRes::time() ;

#            print "lastchangetime==".$gpio->{last_change_time}." : timehiresnow = $timehiresnow \n";

#            print Time::HiRes::time()."\n";
            my $lastcmp = ($gpio->{last_change_time} ) + 1 ; # + 5000;

            if ( $lastcmp <= $timehiresnow ) { # so inORout is 1 for inputs ..

                my $port_signature = $gpio->{y}."_${i2cAddr}_${port_register_hexcode}";

                if ( ! exists $i2cAddr_got{$port_signature} ){
                    # getting stuff from an i2cget system command is slow so
                    # only get the register once in anyone request to this sub.
                    my $val = qx{i2cget -y $gpio->{y} $i2cAddr ${port_register_hexcode} };
                    chomp ( $val );
                    $i2cAddr_got{$port_signature} = hex( $val );
                }

                my $c_st = $i2cAddr_got{$port_signature} & ( 2 ** $portnum ) ? 1 : 0 ;

                if ( $gpio->{current_state} != $c_st ) {
                    $gpio->{state_changed} = 1;
                    print "$port_name CHANGED !! ".$gpio->{last_change_time}."  ".$timehiresnow ."\n";
                    $gpio->{last_change_time} = $timehiresnow ;
                } else {
                    $gpio->{state_changed} = 0;
                }
                $return_inputs->{$port_name}{state_changed} = $gpio->{state_changed};

#                ($s, $usec) = gettimeofday();

                $gpio->{current_state} = $c_st;
                $return_inputs->{$port_name}{current_state} = $c_st;
                $gpio->{last_change_time} = $timehiresnow if ! exists $gpio->{last_change_time};
            }
        }
        return $return_inputs;
    }

}


run_tests();
sub run_tests {

    my @relays = qw/test_light_1 test_light_2 radiator_relay_1 radiator_relay_2 /;

    for my $gpio_name ( @relays ){
          set_gpio_output_hash($gpio_name, "0" );
    }
    commit_gpio_output();


#    for my $i ( 0..2 ) {
#        for my $gpio_name ( @relays ){
#          set_gpio_output_hash($gpio_name, "invert" );
#          commit_gpio_output();
#          usleep 600000;
#        }
#
#    }

    my $key_conf = {
        1 => 'test_light_1',
        2 => 'test_light_2',
        3 => 'radiator_relay_1',
        4 => 'radiator_relay_2',
        5 => 'test2_light_1',
        6 => 'test2_light_2',

    };

    ReadMode 4 if $use_readkey;
    while (1) {
        my $commit_gpio = 0;

        my $key = $use_readkey ? ReadKey(-1) : '';
        if ( defined $key ){
            chomp $key;
            print_debug("key press = $key", 2 ) if $key;

            if ( exists $key_conf->{$key} ){
                set_gpio_output_hash($key_conf->{$key},'invert');
                $commit_gpio = 1;

            } elsif (lc($key) eq "p"){ # p for print
                print Dumper ( $key_conf)."\n";
            } elsif (lc($key) eq "x"){ # x for exit
                ReadMode 0 if $use_readkey;
                die "THE END ! \n";
            }
        }


        my $get_inputs = get_all_inputs();
#        for my $tmp_input ( keys %{$get_inputs} ){
#
#            my $inp = $get_inputs->{$tmp_input};
#
#            if ( $inp->{state_changed} ) {
#
#                print "$tmp_input .. ";
#                print "STATE CHANGED ";
#                print "\n";
#
#            }
#        }
        commit_gpio_output() if $commit_gpio;

        usleep 1000;

    }

}


# Test plan


# With the wall-switch on

# test-light-1








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

