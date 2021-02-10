#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


################################
#    ssh login auf Servern
#    Version: 1.5
#    Author: Alexander Schmitz
################################

SCRIPTNAME="`basename \"$0\"`"
SCRIPTPATH="`dirname \"$0\"`"
HOMEDIR=~
DIR="$HOMEDIR/bin"
IPFILE="IP-Adressen.txt"

##################################
connect_server(){
        SERVER=$1
        SERVERNAME="$(grep $SERVER= $DIR/$IPFILE | cut -d= -f1)"
        IP="$(grep $SERVER= $DIR/$IPFILE | cut -d= -f2)"
        USER="$(grep $SERVER= $DIR/$IPFILE | cut -d= -f4)"
        echo "Verbinde zu $SERVERNAME IP: $IP"
        ssh -X $USER@$IP
}

#####################################

neue_ip(){

     echo "gib eine IP Adresse oder hostnamen an an:"
     read SERVER

     echo "gib den Namen des neuen Servers an"
     read SERVERNAME

     echo "gib einen Nutzer fuer den Server an"
     read USER

     echo "$SERVERNAME=$SERVER=als=$USER" >> $DIR/$IPFILE

     LINE=$(tail -n1 $DIR/$IPFILE)

     SERVER=$( echo "$LINE" | cut -d= -f2 )
     SERVERNAME=$( echo "$LINE" | cut -d= -f1)
     USER=$( echo "$LINE" | cut -d= -f4)


     echo "moechtest du direkt deinen ssh-key kopieren? y oder n?"
     read SSHKEY

     if [[ $SSHKEY = y ]] ; then

         ssh-copy-id -i ~/.ssh/id_rsa.pub $USER@$SERVER

         echo "Verbinde zu $SERVERNAME als $USER"
         ssh -X $USER@$SERVER

     else
         echo "Verbinde zu $SERVERNAME als $USER"
         ssh -X $USER@$SERVER

     fi

}
#######################################

ip_loeschen() {

    cat $DIR/$IPFILE
    echo ""
    echo "Gib den Namen des Servers ein, den du loeschen moechtest"

    read DELETESERVER
    if [[ $(grep $DELETESERVER $DIR/$IPFILE)  ]]; then

        sed -i "/^$DELETESERVER/d" $DIR/$IPFILE

        echo " $DELETESERVER wurde entfernt"

    else

        echo " $DELETESERVER nicht gefunden"
        exit 9
    fi
    exit 0

}
#######################################

show_server() {

    cat $DIR/$IPFILE | column -s "=" -t
    $SCRIPTPATH/$SCRIPTNAME
    exit 0
}
#######################################
#######################################

# Dateien erstellen
if [[ ! -f $DIR/$IPFILE ]]
then
    touch $DIR/$IPFILE
    chmod 664 $DIR/$IPFILE
fi

#Option, um die IP Adressen anzuzeigen
if [[ $1 = "-f"  ]]
 then
    show_server
 fi

#Ausgabe der Auswahl

echo "Waehle per eingabe der Zahl den Server, zu dem du dich verbinden moechtest:"

#Eingabe durch Nutzer

select SERVER in Neuer-Server $(cat $DIR/$IPFILE | cut -d= -f1) Zeige-IPs Server-loeschen
 do
        break
 done

if [[ $SERVER = "Zeige-IPs"  ]]; then
        show_server
elif [[ $SERVER = "Neuer-Server"  ]]; then
        neue_ip
elif [[ $SERVER = "Server-loeschen" ]]; then
        ip_loeschen
else
        connect_server $SERVER
fi

exit 0
