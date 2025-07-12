#!/bin/bash
#---------------------------------------------------------------------
#Remote Control
#Network Research Project

#Functions Declaration
#---------------------------------------------------------------------
#Declare function to install nipe; as per instructed on github
function nipeInstall() {

	git clone https://github.com/htrgouvea/nipe &> /dev/null
	cd nipe 
	cpanm --installdeps . &> /dev/null
	#automatically say yes when prompted
	yes '' | sudo cpan install Config::Simple &> /dev/null
	sudo perl nipe.pl install &> /dev/null
	#updates database
	sudo updatedb
}

#Declare function to start anonymity
function anonStart() {
	
	sudo perl nipe.pl start
	#variable to check nipe is active
	anonStatus=$(sudo perl nipe.pl status | grep -o true)
	#while loop to restart nipe if status=false
	while true
	do
		if [ ! -z $anonStatus ]
		then
			break
		else
			sudo perl nipe.pl restart
			anonStatus=$(sudo perl nipe.pl status | grep -o true)
		fi
	done
	#variable to extract Spoofed IP Address
	anonIP=$(curl -s ifconfig.io)
	#variable to check country of Spoofed IP Address
	anonCountry=$(geoiplookup $anonIP | awk -F', ' '{print $2}')	
	printf "\n"
	echo "[*] You are anonymous.."
	echo "[*] Your Spoofed IP address is: $anonIP, Spoofed country: $anonCountry"
	sleep 1
		
}

#Declare function to automatically connect to remote server
function connectRemote() {

	echo "[*] Connecting to Remote Server:"
	sleep 1
	remoteUptime=$(sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 'uptime')
	remoteCountry=$(geoiplookup $1 | awk '{print $(NF-0)}')
	echo "Uptime: $remoteUptime"
	echo "IP address: $1"
	echo "Country: $remoteCountry"
	printf "\n"
	
}

#Declare function for logging
function logMe() {
	
	#declare variable for filepath
	logfile="/var/log/nr.log"
	
	#check if the file is available
	if [ ! -f "$logfile" ]
	then
	#creates the logfile
	sudo touch "$logfile"
	#Ensures logfile is writable
	sudo chmod 766 "$logfile"
	fi
	
	#appends to /var/log/nr.log
	sudo echo "$(date '+%a %b %d %r %Z %Y')- [*] $1 data collected for: $2" | sudo tee -a "$logfile" &> /dev/null
	
}

#Declare function to get file via ftp
function ftpGetFile() {

	#starts ftp service
	sudo service vsftpd start
	#automated ftp login; heredocs, -i turns off interactive prompts
	#-n diables auto-login feature
	ftp -in $1 &> /dev/null <<EOF
	user $2 $3
	get $4
	bye
EOF
	#ends ftp service
	sudo service vsftpd stop
}

#Declare function to invoke whois on victim's address
function whoisScan() {
	#log to local machine
	logMe 'whois' $4
	echo "[*] Whoising victim's address: "
	#remotely invoke whois from local machine to remote server
	sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 "whois "$4" > whois_"$4""
	#get file via ftp from remote server to local machine
	ftpGetFile $1 $2 $3 "whois_"$4""
	#outputs file path
	echo "[@] Whois data was saved into " $(readlink -f whois_$4)
	printf "\n"
}

#Declare function to invoke nmap on victim's address
function nmapScan() {
	#log to local machine
	logMe 'nmap' $4
	echo "[*] Scanning victim's address: "
	#remotely invoke nmap from local machine to remote server
	sshpass -p $3 ssh -o StrictHostKeyChecking=no $2@$1 "nmap "$4" > nmap_"$4""
	#get file via ftp from remote server to local machine
	ftpGetFile $1 $2 $3 "nmap_"$4""
	#outputs file path
	echo "[@] nmap scan was saved into " $(readlink -f nmap_$4)
	printf "\n"
	
}

#Declare function to check for apps
function checkApps() {
	
	#check if geoiplookup is installed
	if ! command -v geoiplookup &> /dev/null;
	then
		echo "[#] geoip-bin is NOT installed. Proceeding with installation... Please wait..."
		sleep 1
		sudo apt-get install geoip-bin -y &> /dev/null
		echo "[#] geoip-bin has been installed."
		sleep 1
		else
			echo "[#] geoip-bin is already installed."
			sleep 1
	fi
	#check if tor is installed
	if ! command -v tor &> /dev/null;
	then
		echo "[#] tor is NOT installed. Proceeding with installation... Please wait..."
		sleep 1
		sudo apt-get install tor -y &> /dev/null
		echo "[#] tor has been installed."
		sleep 1
		else
			echo "[#] tor is already installed."
			sleep 1
	fi
	#check if sshpass is installed	
	if ! command -v sshpass &> /dev/null;
	then
		echo "[#] sshpass is NOT installed. Proceeding with installation... Please wait..."
		sleep 1
		sudo apt-get install sshpass -y &> /dev/null
		echo "[#] sshpass has been installed."
		sleep 1
		else
			echo "[#] sshpass is already installed."
			sleep 1
	fi
	#check if vsftpd is installed	
	if ! command -v vsftpd &> /dev/null;
	then
		echo "[#] vsftpd is NOT installed. Proceeding with installation... Please wait..."
		sleep 1
		sudo apt-get install vsftpd -y &> /dev/null
		echo "[#] vsftpd has been installed."
		sleep 1
		else
			echo "[#] vsftpd is already installed."
			sleep 1
	fi
	#check if nipe is installed	
	if ! locate nipe.pl &> /dev/null;
	then
		echo "[#] nipe is NOT installed. Proceeding with installation... Please wait..."
		nipeInstall
		echo "[#] nipe has been installed."
		sleep 1
		else
			#change to nipe directory if it is already installed.
			echo "[#] nipe is already installed."
			nipeLocation=$(locate nipe.pl | awk -F"/nipe.pl" '{print $1}')
			cd $nipeLocation
			sleep 1
	fi

}

#----------------------------START HERE----------------------------

#verify login by sudo
if [[ $EUID -ne 0 ]]
then
# to display if sudo is not used, exits script
    echo "This script must be run with sudo or as root."
    exit
fi
# to display when script ran with sudo
echo "Script is running with sudo. Proceeding..."

figlet RemoteControl

#update system packages
sudo apt-get update -y &> /dev/null

#invoke function to check for the necessary apps, install them if not available.
checkApps

#invoke function to be anonymous
anonStart

#while loop to ensure valid credentials are given
while true
do 

	printf "\n"
	echo "[*] Enter Credentials for the Remote Server"
	#while loop to ensure IP Address is correctly formatted
	while true
	do
		read -p "[?] Enter Remote IP Address: " remoteIp
		if [[ $remoteIp =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
		then
			break
		else
			echo "[*] Invalid IP Address format.. Please try again.."
		fi
	done	
	read -p "[?] Enter Remote User: " remoteUser
	#password is silent for security
	read -sp "[?] Enter Remote Password: " remotePswd
	#starts ssh service
	sudo service ssh start
	#get a readout from server side. outputs only when valid; StrictHostKeyChecking=no to accept any incoming RSA key 
	loginStatus=$(sshpass -p $remotePswd ssh -o StrictHostKeyChecking=no $remoteUser@$remoteIp 'whoami' 2> /dev/null)
	#if statement to check validity of username and password
	if [ ! -z $loginStatus ]
	then
		break
	else
		printf "\n"
		echo "[*] Invalid Credentials.. Please try again.."
	fi
done

#while loop for repeated scanning. Input by user.
while true
do
	#while loop to check that domain is valid/invalid. Break when valid
	while true
	do
		printf "\n"
		printf "\n"
		read -p "[?] Specify a Domain/IP address to scan: " domainToScan
		checkDomain=$(sshpass -p $remotePswd ssh -o StrictHostKeyChecking=no $remoteUser@$remoteIp "whois "$domainToScan"")
		invalidDomain=$(echo $checkDomain | grep -o "No whois server")
		validDomain=$(echo $checkDomain | grep -o "DNSSEC")
		tempFailureDomain=$(echo $checkDomain | grep -o "Temporary failure")

		if [[ ! -z $invalidDomain ]]
		then
			echo "Domain is Invalid. Please try another..."
		elif [[ ! -z $tempFailureDomain ]]
		then
			echo "Temporary failure in name resolution. Please try again..."
		elif [[ ! -z $validDomain ]]
		then
			break
		else
			echo "Domain is not available in database. Please try another..."	
		fi
	done

	#invokes function to connect to remote server
	connectRemote $remoteIp $remoteUser $remotePswd
	#invokes function to whois victim's IP Address/ domain
	whoisScan $remoteIp $remoteUser $remotePswd $domainToScan 
	#invokes function to nmap victim's IP Address/ domain
	nmapScan $remoteIp $remoteUser $remotePswd $domainToScan 
	
	#while loop with nested case statement for user input.
	while true
	do
		read -p "[?] Do you want to continue scanning? [Y\n]: " userInput
		case $userInput in
			y|Y|Yes|yes|YES)
				break
			;;
			n|N|No|no|NO)
				echo "[*] Thank you for using Remote Control."
				figlet Good-Bye!
				#ends ssh service
				sudo service ssh stop
				sudo perl nipe.pl stop
				exit
			;;
			*)
				echo "[*] Invalid input. Please try again."
				printf "\n"
		esac
	done
done



#-----------------------END OF SCRIPT---------------------------


