#!/bin/bash

cd /etc/openvpn/ca

echo "Certificate Generator: 1.Generate Certificate, 2.Generate Certificate (no password), 3.Revoke Certificate"

# Copy Certificate files:

cp.cert.files () {

mkdir /home/wildroger/cert_user_files/$CP
cp /etc/openvpn/ca/pki/issued/$CP.crt /home/wildroger/cert_user_files/$CP/
cp /etc/openvpn/ca/pki/private/$CP.key /home/wildroger/cert_user_files/$CP/
cp /home/wildroger/config_files/vpnserver.kz.ovpn /home/wildroger/cert_user_files/$CP/
cp /home/wildroger/config_files/ca.crt /home/wildroger/cert_user_files/$CP/
cp /home/wildroger/config_files/ta.key /home/wildroger/cert_user_files/$CP/
sed -i "s/cert client_1.crt/cert $CP.crt/" /home/wildroger/cert_user_files/$CP/vpnserver.kz.ovpn
sed -i "s/key client_1.key/key $CP.key/" /home/wildroger/cert_user_files/$CP/vpnserver.kz.ovpn
chmod 777 /home/wildroger/cert_user_files/$CP/$CP.crt
chmod 777 /home/wildroger/cert_user_files/$CP/$CP.key

}

# Generate Certificate:
client.gc () {

if
    read -p "Enter Client Name: "
then
    ./easyrsa gen-req $REPLY
    CP=$REPLY
fi
}

# Generate Certificate (no password):
client.gcnp () {

if
    read -p "Enter Client Name: "
then
    ./easyrsa gen-req $REPLY nopass
    CP=$REPLY
fi
}

# Sign Request:
client.sg () {

if
    read -p "Enter Client Name: "
then
    ./easyrsa sign-req client $REPLY
fi
}

# Delete certificate files?:
del.cert () {

echo "Delete certificate files?"
read -p "enter "yes" or "no": "

if [[ "$REPLY" = "yes" ]]
	
	then 
		rm -R /home/wildroger/cert_user_files/$RM

elif [[ "$REPLY" = "no" ]]
        
    then 
		echo "Certificate files not delete."

elif [[ "$REPLY" != "yes","no" ]]
		
	then 
		del.cert        

fi
}

# Revoke Certificate:
client.rv () {

if
    read -p "Enter Client Name: "
then
    ./easyrsa revoke $REPLY
    RM=$REPLY
fi
}

# Enter Number:
en.num () {

read -p "Enter Number: "
   
	if [[ "$REPLY" = "1" ]]
	
	then 
		client.gc
        client.sg
        cp.cert.files

    elif [[ "$REPLY" = "2" ]]

    then 
		client.gcnp
        client.sg
        cp.cert.files

    elif [[ "$REPLY" = "3" ]]
        
    then 
		client.rv
        del.cert
        
    elif [[ "$REPLY" != "1","2","3" ]]
		
	then 
		echo Enter Number: 1-3!
		en.num
		
	fi
}

en.num

echo "Done!"