#!/bin/bash

# Installer script for DNASubway AWS cluster

#yum update
mkdir -p /shared/{bin,lib,man,etc,share,var,include}
echo "export PATH=$PATH:/shared/bin" > /etc/profile.d/shared.sh
# http://tecadmin.net/install-python-2-7-on-centos-rhel/

yum install centos-release-SCL
yum install python27
scl enable python27 bash

# DEPENDENCIES

yum clean all

# SGE QUEUE MANAGEMENT

