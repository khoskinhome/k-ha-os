#!/usr/bin/perl
use strict;
use warnings;

use JSON;

my $amelialight = {
    HomeAutoClass       => "MultiLightSingleWayManual",
    MachineIPAddress    => "192.168.1.8",

    ChangeOver => { # formerly amelia_light_change_over
        enabled         => 1,
		i2cbus          => 1,
		i2cAddress      => '0x20', # i2c address of the mcp23017
		port            => 'a',    # a or b ONLY
		portnum         => 6,      # 0 -> 7
        initial         => 1,
		inORout         => 0,      # 0 == out , 1 == in
		current_state   => 1,      # gets set by prog
    },

    LightSwitchMains => { # formerly amelia_light_switch_detect
        enabled         => 1,
        i2cbus          => 1,
        i2cAddress      => '0x20',
        port            =>'a',     # a or b ONLY
        portnum         => 5,      # 0 -> 7
        # intial   => 1, doesn't do anything on an input GPIO.
        inORout         => 1,      # 0 == out , 1 == in
        current_state   => 1, # gets set by prog

    },
    LightSwitchExtra => { # spare Low Voltage input switch.
        enabled         => 0,
        i2cbus          => 1,
        i2cAddress      => '0x20',
        port            =>'a',     # a or b ONLY
        portnum         => 4,      # 0 -> 7
        # intial   => 1, doesn't do anything on an input GPIO.
        inORout         => 1,      # 0 == out , 1 == in
        current_state   => 1, # gets set by prog

    },

    Lights => [
        { # amelia_light_0
            enabled         => 0,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 0,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1,      # gets set by prog
        },
	    { # amelia_light_1
            enabled         => 1,
	    	i2cbus          => 1,
		    i2cAddress      => '0x20', # i2c address of the mcp23017
    		port            => 'b',     # a or b ONLY
	    	portnum         => 1,      # 0 -> 7
            initial         => 1,
    		inORout         => 0,      # 0 == out , 1 == in
	    	current_state   => 1, # gets set by prog
	    },
        { # amelia_light_2
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 2,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },
        { #	amelia_light_3
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 3,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },
        { #	amelia_light_4
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 4,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },
        { #	amelia_light_5
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 5,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },
        { #	amelia_light_6
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 6,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },
        { #	amelia_light_7
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'b',     # a or b ONLY
            portnum         => 7,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },
        { #	amelia_light_8
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x20', # i2c address of the mcp23017
            port            => 'a',     # a or b ONLY
            portnum         => 7,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1, # gets set by prog
        },

    ],


};


my $bathroomlight = {
    HomeAutoClass       => "SingleLightTwoWayManual",
    MachineIPAddress    => "192.168.1.8",

    ChangeOver => { # formerly bathroom_light_change_over. relay-1 on pcb.
        enabled         => 1,
        i2cbus          => 1,
        i2cAddress      => '0x23', # i2c address of the mcp23017
        port            => 'a',    # a or b ONLY
        portnum         => 0,      # 0 -> 7
        initial         => 1,
        inORout         => 0,      # 0 == out , 1 == in
        current_state   => 1,      # gets set by prog
    },

    LightStateMains => { # formerly bathroom_light_switch_detect
        enabled         => 1,
        i2cbus          => 1,
        i2cAddress      => '0x23',
        port            =>'a',     # a or b ONLY
        portnum         => 1,      # 0 -> 7
        # intial   => 1, doesn't do anything on an input GPIO.
        inORout         => 1,      # 0 == out , 1 == in
        current_state   => 1, # gets set by prog
    },

    LightSwitchExtra => { # spare Low Voltage input switch.. formerly bathroom_light_extra_switch_detect
        enabled         => 0,
        i2cbus          => 1,
        i2cAddress      => '0x23',
        port            =>'a',     # a or b ONLY
        portnum         => 2,      # 0 -> 7
        # intial   => 1, doesn't do anything on an input GPIO.
        inORout         => 1,      # 0 == out , 1 == in
        current_state   => 1, # gets set by prog

    },

    Light => { # formerly bathroom_light_0 , relay-2 on pcb
            enabled         => 1,
            i2cbus          => 1,
            i2cAddress      => '0x23', # i2c address of the mcp23017
            port            => 'a',     # a or b ONLY
            portnum         => 3,      # 0 -> 7
            initial         => 1,
            inORout         => 0,      # 0 == out , 1 == in
            current_state   => 1,      # gets set by prog
    },

};




my $json = JSON->new->allow_nonref;
#print  $json->pretty->encode( $amelialight )."\n";
print  $json->pretty->encode( $bathroomlight )."\n";
#
#my $gpio_conf = {
#
################# 0x20 :-
#
#
############### 0x23 :-
#
##### bathroom :-
#

##### landing :- 
#
#	landing_light_change_over => { # relay-2 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 4,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	landing_light_switch_detect => {
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 5,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	landing_light_extra_switch_detect => {
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 6,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	landing_light_0 => { # relay-1 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 7,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,      # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#####
#	loft_light_0 => { # relay-1 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 0,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,      # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#
#	loft_light_switch_detect => { # detect 240v on main switch
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 1,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	loft_light_extra_switch_detect => {
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 2,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	loft_light_change_over => { # relay-2 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 3,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
######
#
#    alison_light_change_over => { # relay-2 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 4,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	alison_light_switch_detect => { # detect 240v on light switch
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 5,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	alison_light_extra_switch_detect => { # an extra 5v input for a switch.
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 6,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#
#	alison_light_0 => {  # relay-1 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x23', # i2c address of the mcp23017
#		port    =>'b',     # a or b ONLY
#		portnum => 7,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,      # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
############### 0x21 :-
#
#	spare1_light_change_over => { # relay-2 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 0,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	spare1_light_extra_switch_detect => { # an extra 5v input for a switch.
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 1,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	spare1_light_switch_detect => { # detect 240v on light switch
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 2,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	spare1_light_0 => {  # relay-1 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 3,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,      # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
######
#
#	spare2_light_change_over => { # relay-2 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 4,      # 0 -> 7
#        initial  => 1,
#		inORout => 0,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	spare2_light_extra_switch_detect => {
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 5,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	spare2_light_switch_detect => { # detect 240v at wall switch
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 6,      # 0 -> 7
#        # intial  => 1, doesn't do anything on an input GPIO.
#		inORout => 1,       # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#	spare2_light_0 => { # relay-1 on pcb
#        enabled       => 1,
#		i2cbus =>1,
#		i2cAddress => '0x21', # i2c address of the mcp23017
#		port    =>'a',     # a or b ONLY
#		portnum => 7,      # 0 -> 7
#        initial => 1,
#		inORout => 0,      # 0 == out , 1 == in
#		current_state => 1, # gets set by prog
#	},
#
#};
#

