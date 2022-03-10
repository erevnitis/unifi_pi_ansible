#! /bin/bash
# You should run this script as root: sudo su

purple='\033[1;35m'
nocolor='\033[0m'
device_name="unifipi"
username="ansible"
groupname="wheel"
ssh_dir="/home/$username/.ssh"
sudo_permissions="$username ALL=(ALL) NOPASSWD: ALL"
ssh_key="Insert_SSH_Key_Here"
pass=$(perl -e 'print crypt($ARGV[0], "password")' Insert_Your_Password_Here)

echo -e "{$purple}Set the timezone\n\n{$nocolor}"
timedatectl set-timezone "America/Detroit"
echo $(timedatectl)

echo -e "{$purple}I'm going to update the OS now.....\n\n{$nocolor}"
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

echo -e "{$purple}Change hostname in hostname file\n\n{$nocolor}"
echo -e "{$purple}And hange hostname in hosts file\n\n{$nocolor}"
if grep -q ubuntu "/etc/hostname"; then    
    sed -i "s/ubuntu/$device_name/" /etc/hostname
    sed -i "s/localhost/$device_name/" /etc/hosts  
elif grep -q raspberry "/etc/hostname"; then
    sed -i "s/raspberrypi/$device_name/" /etc/hostname 
    sed -i "s/raspberrypi/$device_name/" /etc/hosts
    sed -i "s/localhost/$device_name/" /etc/hosts
fi

echo -e "{$purple}Add group $groupname\n\n{$nocolor}"
sudo groupadd $groupname

echo -e "{$purple}Add user\n\n{$nocolor}"
useradd -m -p $pass $username -g $groupname -G adm,sudo -s /bin/bash

echo -e "{$purple}Add sudo permissions for $username\n\n{$nocolor}"
echo $sudo_permissions > /etc/sudoers.d/$username

echo -e "{$purple}Make .ssh directory for $username\n\n{$nocolor}"
if [ -d "$ssh_dir" ]; then
echo "Directory already exists\n" ;
else
`mkdir -p $ssh_dir`;
fi
echo "New .ssh directory is created\n\n"

echo -e "{$purple}Add ssh key for user{$nocolor}"
echo $ssh_key > /home/$username/.ssh/authorized_keys

echo -e "{$purple}I'm going to restart the device now\n\n{$nocolor}"
sudo reboot now