#!/bin/bash

sudo_prefix=""
if [[ $UID != 0 ]]; then
    sudo_prefix="sudo "
fi;

$sudo_prefix apt-get update
$sudo_prefix apt-get install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
$sudo_prefix apt-get install -y tigervnc-standalone-server tigervnc-common autocutsel

echo "Please set a VNC Password for this ${USER}..."
vncserver

echo "Generating ${HOME}/.vnc/xstartup file..."

echo "#!/bin/bash" >> ${HOME}/.vnc/xstartup
echo "" >> ${HOME}/.vnc/xstartup
echo "xrdb $HOME/.Xresources" >> ${HOME}/.vnc/xstartup
echo "autocutsel -fork" >> ${HOME}/.vnc/xstartup
echo "vncconfig -iconic &" >> ${HOME}/.vnc/xstartup
echo "vncconfig -nowin &" >> ${HOME}/.vnc/xstartup
echo "startxfce4 &" >> ${HOME}/.vnc/xstartup

echo "Let Tiger-VNC-Server be a background service..."

if [[ ! -f ${PWD}/tiger-vnc-server.service ]]; then
    echo "${PWD}/tiger-vnc-server.service is missed. Please create it."
    exit 1;
fi;

cp ${PWD}/tiger-vnc-server.service /tmp/tiger-vnc-server.service

sed -i -e "s/<user>/${USER}/g" /tmp/tiger-vnc-server.service

$sudo_prefix cp /tmp/tiger-vnc-server.service "/etc/systemd/system/tiger-vnc-server@:1.service"

$sudo_prefix systemctl daemon-reload
$sudo_prefix systemctl enable --now "tiger-vnc-server@:1.service"
service_status=$($sudo_prefix systemctl is-enabled "tiger-vnc-server@:1.service")

if [[ ${service_status} != 'enabled' ]]; then
    echo "${service_status}, service status is not enabled..."
    exit 1;
fi;

$sudo_prefix systemctl start "tiger-vnc-server@:1.service"

$sudo_prefix netstat -ntlp | grep '5901'

if [[ $? != 0 ]]; then
    echo "It seems that TigerVNC server is not running on 5901 port number correctly..."
    exit 1
fi;

echo "The TigerVNC server and Xfce4 desktop environment have been installed."
echo "Don't forget to use 'reboot' command to verify above settings are done."
