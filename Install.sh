#!/bin/bash

# Welcome-text and information
whiptail --title "Docker & Docker Compose installer" --msgbox "This script will check if Docker and Docker Compose is installed, if not it will install both. Docker will autostart at boot and will run in the context of the current user; "$USER 10 78
psw=$(whiptail --title "Sudo required" --passwordbox "Enter your password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
  # Clear current (if any) sudo timestamp
  sudo -k
  # Use user supplied sudo password and create a new timestamp (gives 15 min sudo)
  echo $psw | sudo -v -S
  # Clear password from running memory
  psw=""
  i=0
  while [ "$i" -lt "100" ]; do
    #Get dist up to date
    statustext="Running updates"
    sudo apt-get update && sudo apt-get upgrade -y
    i=10
    echo $i
    # Install Docker
    if ! [ -x "$(command -v docker)" ]; then
  	statustext="Installing Docker"
      curl -fsSL test.docker.com -o get-docker.sh && sh get-docker.sh
  	i=25
  	echo $i
      # Install newuidmap & newgidmap binaries
  	statustext="Setting up Docker"
      sudo apt-get install -y uidmap
  	i=30
  	echo $i
      # Setup docker to run rootless
      dockerd-rootless-setuptool.sh install
  	i=35
  	echo $i
      export PATH=/usr/bin:$PATH
      export DOCKER_HOST=unix:///run/user/1000/docker.sock
      sudo loginctl enable-linger $USER
      i=40
  	echo $i
      # Setup user with Docker priv
      sudo usermod -aG docker $USER
      i=50
  	echo $i
    else
      # Docker already installed
      i=50
  	echo $i
    fi
    
    # Install Docker Compose
    if ! [ -x "$(command -v docker-compose)" ]; then
      statustext="Installing Docker Compose"
      sudo apt-get install libffi-dev libssl-dev -y
      i=60
  	echo $i
      sudo apt install python3-dev -y
      i=70
  	echo $i
      sudo apt-get install -y python3 python3-pip -y
      i=80
  	echo $i
      sudo pip3 install docker-compose
      i=90
  	echo $i
      sudo systemctl enable docker
      i=100
  	echo $i
    else
      # Docker-compose already installed
      i=100
  	echo $i
    fi
  done | whiptail --title "Docker & Docker Compose installer" --gauge "Please wait while we are installing..." 10 60 0

  if (whiptail --title "Restart Required" --yesno "It is recommended that you restart your device now to complete the installation" 8 78 --yes-button "Restart" --no-button "Don't restart" ); then
      sudo reboot
  else
	  sudo -k
	  clear
  fi
else
        whiptail --title "Sudo required" --msgbox "Sudo credentials not entered, exiting" 10 60
fi
