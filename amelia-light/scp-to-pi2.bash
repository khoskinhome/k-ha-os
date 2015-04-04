#!/bin/bash

ssh khoskin@192.168.1.8 'mkdir /tmp/install-amelia-light'

scp -r *  khoskin@192.168.1.8:/tmp/install-amelia-light/
