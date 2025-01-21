#!/bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
sudo echo "<h1>Hello I'm Nadeesha Chathumal from my test VM : $(hostname)</h1>" > /var/www/html/index.html