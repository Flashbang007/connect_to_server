#!/bin/bash

########################################################
#                  ssh login auf Servern               #
#                       Vesion 1.4                     #
#                       Autor: act                     #
#                                                      #
#                                                      #
#               Befehl: connect_to_server.sh           #
########################################################

HOMEDIR=~
DIR="$HOMEDIR/bin"
IPFILE="IP-Adressen.txt"
VERBINDENFILE="verbinden.txt"

##################################
verbinden_aktualisieren(){
echo "case \"\$SERVER\" in" > $DIR/$VERBINDENFILE

#Schleife, welche den Server zur Liste hinzufuegt
for i in `cat $DIR/$IPFILE`
 do

        SERVER=$( echo "$i" | cut -d= -f2 )
        SERVERNAME=$( echo "$i" | cut -d= -f1)
        USER=$( echo "$i" | cut -d= -f4)



echo "        $SERVERNAME)
                echo \"Verbinde zu $SERVERNAME IP: $SERVER\"
                ssh -X $USER@$SERVER
        exit 0
        ;;

" >> $DIR/$VERBINDENFILE

 done

echo "         *)
                echo \"\$SERVER nicht gefunden\"
        exit 1
esac" >> $DIR/$VERBINDENFILE
}
#####################################

neue_ip(){

echo "gib eine IP Adresse an:"
        read SERVER
 #Falls eine IP-Adresse eingegeben wurde.
 if [[ $SERVER =~ ^[0-9]+ ]]; then

echo "gib den Namen des neuen Servers an"
read SERVERNAME

echo "gib einen Nutzer fuer den Server an"
read USER

echo "$SERVERNAME=$SERVER=als=$USER" >> $DIR/$IPFILE
#####################################
verbinden_aktualisieren
#####################################

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

else
 #Verbinden zu den Servern
        . $DIR/$VERBINDENFILE
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

if [[ ! -f $DIR/$VERBINDENFILE ]]
 then
    touch $DIR/$VERBINDENFILE
    chmod 664 $DIR/$VERBINDENFILE
 fi

#Option, um die IP Adressen anzuzeigen
if [[ $1 = "-f"  ]]
 then
        show_server
 fi

#Festlegen der IP-Addressen#

        . $DIR/$IPFILE
        verbinden_aktualisieren

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
        . $DIR/$VERBINDENFILE
fi

exit 0
