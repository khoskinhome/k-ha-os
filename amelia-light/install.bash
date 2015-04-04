#!/bin/bash -v


# copy over the image files.
sudo mkdir -p /var/www/img/
sudo cp ./img/* /var/www/img/

# copy 

sudo mkdir -p /opt/k-ha-os/amelia-light/
sudo cp daemon.pl /opt/k-ha-os/amelia-light/
sudo cp hackit-daemon.pl /opt/k-ha-os/amelia-light/


#sudo mkdir /usr/lib/cgi-bin/

sudo cp light*.pl /usr/lib/cgi-bin/

sudo chown www-data.www-data /usr/lib/cgi-bin/light*.pl
sudo chmod 755 /usr/lib/cgi-bin/light*.pl


