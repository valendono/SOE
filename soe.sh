#!/bin/bash
# Base2 SOE Script by dono v1
#COLOR=red
#COLOR1=black
#setterm -term linux -back $COLOR -fore white -clear

until [[ $password == "SOE" ]]; do
read -p "Please type SOE :" password
done

# add user base2
echo "Adding user base2 ..."
set -x
useradd base2
echo "base2 ALL = NOPASSWD: ALL" >> /etc/sudoers
mkdir /home/base2/.ssh
chmod 0700 /home/base2/.ssh
touch /home/base2/.ssh/authorized_keys
set +x

# add key base2
echo "Injecting base2 ssh key ..."
touch /home/base2/.ssh/authorized_keys
chmod 0600 /home/base2/.ssh/authorized_keys
cat /home/base2/.ssh/authorized_keys
chown -R base2:base2 /home/base2/

set -x
# soe
yum install -y telnet screen nagios-plugins-all mc incron lvm2 nrpe mlocate
yum install -y s3cmd --enablerepo=epel


# enter the hostname
until [[ ! $host == "" ]]; do
read -p "Enter Hostname: " host
done
echo "Hostname $host"
hostname $host
echo $host > /etc/hostname

# bash env
echo "export PS1='\[\033[01;32m\]\u@\H\[\033[01;34m\] \W \$\[\033[00m\] '" >> /home/base2/.bashrc
echo "export PS1='\[\033[01;31m\]\u@\H\[\033[01;34m\] \W \$\[\033[00m\] '" >> /root/.bashrc
echo "export PS1='\[\033[01;32m\]\u@\H\[\033[01;34m\] \W \$\[\033[00m\] '" >> /etc/skel/.bashrc

# bash history env
echo "ENV_TYPE=PRODUCTION" >> /etc/profile.d/env.sh
echo "export HISTTIMEFORMAT=\"%F %T \" " >> /etc/profile.d/env.sh
chmod +x /etc/profile.d/env.sh

#setterm -term linux -back $COLOR1 -fore white -clear
echo "Base2 SOE not finish yet!"
echo "Please check/test: 1. base2 Login 2. hostname "
echo "Next Step, open with another shell using base2 login and sudo -i, run ./next.sh"


# Creating Next Step
echo "
until [[ \$password1 == \"READY\" ]]; do
read -p \"Are you already create xvdf and xvdg attach to this Machine? Type READY if you are.\" password1
done

# base2services
mkdir /opt/base2

# base2
vgcreate opt_base2 /dev/xvdf
lvcreate --extents 100%VG opt_base2
mkfs.ext4 /dev/opt_base2/lvol0

# backup
vgcreate opt_base2_backups /dev/xvdg
lvcreate --extents 100%VG opt_base2_backups
mkfs.ext4 /dev/opt_base2_backups/lvol0

sleep 5
# mount it
mount /dev/opt_base2/lvol0 /opt/base2
sleep 5
mkdir /opt/base2/backups
mount /dev/opt_base2_backups/lvol0 /opt/base2/backups
sleep 5
mount -avv /opt/base2/backups

# folder what we need
mkdir /opt/base2/bin
mkdir /opt/base2/archive
mkdir /opt/base2/scripts
mkdir /opt/base2/configuration
mkdir /opt/base2/configuration/nrpe
mkdir /opt/base2/backups


# install ditto
cd /opt/base2/
wget https://github.com/base2Services/ditto/archive/master.tar.gz
mkdir ditto
tar -xvf master --strip 1 -C /opt/base2/ditto
rm -rf /opt/base2/ditto/backups; ln -sf /opt/base2/backups /opt/base2/ditto/backups

ln -s /opt/base2/configuration/nrpe/001-volumes.cfg /etc/nrpe.d/
ln -s /opt/base2/configuration/nrpe/002-generic.cfg /etc/nrpe.d/

# auto run
chkconfig rsyslog on
chkconfig crond on
chkconfig nrpe on
set +x

# run nrpe
service nrpe restart

# del default user (can not do this when you login with ec2-user)
userdel ec2-user
rm -rf /var/spool/mail/ec2-user
rm -rf /home/ec2-user

echo \"Please check/test: 1. ec2-user 2. df -h 3. nrpe 4. ditto 5. And check mounting and fstab 6. History\"
" > next.sh
chmod 755 next.sh
