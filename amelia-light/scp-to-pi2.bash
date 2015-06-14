#!/bin/bash

if [[ ! $1 ]]; then

    echo "you need to feed this script with either pimain, piloft , piold or pioldwifi"
    exit 1

#    PIHOST=pimain

else
    PIHOST=$1
fi

USER=khoskin

PI_INSTALL_DIR="/tmp/install-amelia-light/"


ssh $USER@$PIHOST "if [ ! -d $PI_INSTALL_DIR ] ; then sudo mkdir -p $PI_INSTALL_DIR; fi;"

# sanity checks to make sure we're in the correct place :
if [ ! -f scp-to-pi2.bash ]; then

    echo "can't find scp-to-pi2.bash you mush be running this script from the wrong dir"
    exit 1;

fi

if [ ! -d img ]; then

    echo "can't find dir 'img' you mush be running this script from the wrong dir"
    exit 1;

fi

echo "#############################################################"
echo "tar-ing over to $USER@$PIHOST:$PI_INSTALL_DIR"
echo "#############################################################"

cd ./install

tar zcf - ./ | ssh $USER@$PIHOST "( cd $PI_INSTALL_DIR ; sudo tar zxvf - )"

## scp -r *  khoskin@$PIHOST:/tmp/install-amelia-light/
