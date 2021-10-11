# Purpose
Use Ansible to Install UniFi Controller on Raspberry Pi4  

## Setup
The following steps can be categorized into two parts:
- Provision a Raspberry Pi4 to accept the repository and Ansible playbook
- Install UniFi Network application on the Pi4  
There is also a playbook to update UifFi Network software  
I modeled the ansible playbook from this excellent guide:
[Step-By-Step Tutorial Raspberry Pi with Unifi Controller](https://community.ui.com/questions/Step-By-Step-Tutorial-Guide-Raspberry-Pi-with-UniFi-Controller-and-Pi-hole-from-scratch-headless/e8a24143-bfb8-4a61-973d-0b55320101dc)

## Download Raspberry Pi OS Lite
Flash SD card, I use Balena Etcher  
![Balena Etcher](/files/balena_unifi_pi.png)  

Add blank file called 'ssh' to Boot partition
```bash
fred@pop-os:/media/fred/boot$ touch ssh
```
Install SD card in Pi, connect network cable and power
## Grab IP address
Using your favorite application, find the IP- I use pfSense so for me it's under the DHCP leases tab
There you will find a device named 'raspberrypi'.  Make note of the IP address  
For the purpose of this example, our IP was found to be 192.168.1.11

## SSH into the device
I have a lot of entries in my .ssh/known-hosts file so I need to add -o IdentitiesOnly=yes
```bash
ssh pi@192.168.1.11 -o IdentiesOnly=yes
```
When prompted for a password the default is 'raspberry'

## Update Pi and change some parameters
For this step I copy and paste the bootstrap.sh file  
This configures the new device with a new name 'unifi_pi' and adds user 'ansible'  
Run the script as root
```bash
sudo su
```  
```bash
nano bootstrap.sh
```
After I copy the contents of [bootstrap.sh](files/bootstrap.sh) into the new file, I save it then to make it executable:
```bash
chmod +x bootstrap.sh
```
Then run the script
```bash
./bootstrap.sh
```
At the end of the script, the device is rebooted to apply the changes
## Reconnect to the Pi
This time connect as the new user 'ansible'
```bash
ssh ansible@192.168.1.11
```
## Prepare the Pi for accepting our ansible playbook
Copy and paste another file to install git, ansible dependencies and ansible  
After this we won't need to copy and paste anymore
Because of the previous script, we do not need to run this script as root
```bash
sudo nano prepare_pi.sh
```
Copy the [prepare_pi.sh](files/prepare_pi.sh) and paste it  

Make it executable:
```bash
sudo chmod +x prepare_pi.sh
``` 
Run the script
```bash
./prepare_pi.sh
```

## Clone the Repository
The device is rebooted again and is ready to receive our playbook  
Connect again via ssh
```bash
ssh ansible@192.168.1.11
```
Now grab the repository
```bash
git clone https://github.com/erevnitis/unifi_pi_ansible.git
```
## Change Directory to 'ansible_unifi_pi:
```bash
cd unifi_pi_ansible
```
## Run the playbook
```bash
ansible-playbook main.yml
```
## Check the status of unifi.service
```bash
systemctl status unifi.service
```
Should display that the service is running.  
Now you're ready to connect to your device at:  
192.168.1.11:8443  
And configure UniFi Network...


# Update UniFi Network
## When an update for the software is available
- Navigate to the [Ubiquiti website](https://www.ui.com/download/unifi)
- Choose the UniFi Network Application for your OS and note the version number  

To update, run the update.yml playbook manually entering the version of the controller software you want the device to update to
```bash
ansible-playbook update.yml -e "version=x.x.xx"
```
One challenge I've not been able to overcome with automating the process is this:  
When manually updating the controller a splash screen asks if the controller has a backup.  
The default answer is yes, so manually pressing 'enter' starts the installation of the new controller.
![update_unifi_quesiton](files/unifi_backup_question.png)  
This occurs about 10 seconds after the start of the "Install UniFi" task.  
The current workaround is to press 'enter' about 10 or 15 seconds after the appearance of "Install UniFi" in the ansible display.  
One day I hope to find a fix for this...  

## Check the status of unifi.service
```bash
systemctl status unifi.service
```
## Hope this helps