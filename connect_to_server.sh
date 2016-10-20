#!/bin/bash

########################################################
#               ssh login auf Teles-Maschienen         #
#                       Vesion 1.2                     #
#                       Autor: act                     #
#                                                      #
#                                                      #
#               Befehl: connect_to_server.sh           #
########################################################

#!/bin/bash

neue_ip(){

echo "gib den Namen des neuen Servers an"
read SERVERNAME

echo "gib einen Nutzer fuer den Server an"
read USER

echo "$SERVERNAME=$SERVER=als=$USER" >> ~/bin/IP-Adressen.txt

echo "case \"\$SERVER\" in" > ~/bin/verbinden.txt

#Schleife, welche den Server zur Liste hinzufuegt
for i in `cat ~/bin/IP-Adressen.txt`
 do

        SERVER=$( echo "$i" | cut -d= -f2 )
        SERVERNAME=$( echo "$i" | cut -d= -f1)
        USER=$( echo "$i" | cut -d= -f4)



echo "        $SERVERNAME)
                echo \"Verbinde zu $SERVERNAME IP: $SERVER\"
                ssh $USER@$SERVER
        exit 0
        ;;

" >> ~/bin/verbinden.txt

 done

echo "         *)
                echo \"\$SERVER nicht gefunden\"
        exit 1
esac" >> ~/bin/verbinden.txt

LINE=$(tail -n1 ~/bin/IP-Adressen.txt)

        SERVER=$( echo "$LINE" | cut -d= -f2 )
        SERVERNAME=$( echo "$LINE" | cut -d= -f1)
        USER=$( echo "$LINE" | cut -d= -f4)


echo "moechtest du direkt deinen ssh-key kopieren? y oder n?"
read SSHKEY

if [[ $SSHKEY = y ]] ; then

        ssh-copy-id -i ~/.ssh/id_rsa.pub $USER@$SERVER

        echo "Verbinde zu $SERVERNAME als $USER"
        ssh $USER@$SERVER

 else

        echo "Verbinde zu $SERVERNAME als $USER"
        ssh $USER@$SERVER

fi

}


if [[ ! -f ~/bin/IP-Adressen.txt ]]
then
    touch ~/bin/IP-Adressen.txt
    chmod 664 ~/bin/IP-Adressen.txt
fi

if [[ ! -f ~/bin/verbinden.txt ]]
then
    touch ~/bin/verbinden.txt
    chmod 664 ~/bin/verbinden.txt
fi

#Festlegen der IP-Addressen#

        . ~/bin/IP-Adressen.txt

#Ausgabe der Auswahl

echo "Gib eins der Folgenden Kuerzel ein, um dich zu Verbinden:"

        cat ~/bin/IP-Adressen.txt

echo "Oder gib eine eigene IP an um einen neuen Server einzutragen"

#Eingabe durch Nutzer

        read SERVER

#Falls eine IP-Adresse eingegeben wurde.
if [[ $SERVER =~ ^[0-9]+ ]]; then


        neue_ip

exit 0

 else

#Verbinden zu den Servern

        . ~/bin/verbinden.txt

fi
