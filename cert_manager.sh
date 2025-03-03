#!/bin/bash

cd /etc/openvpn/ca

echo "Certificate Generator: 1.Generate Certificate, 2.Generate Certificate (no password), 3.Revoke Certificate"

generate_certificate () {
    echo Certificates list:
    ls -l /home/wildroger/cert_user_files

    if read -p "Enter Client Name: "; then
        ./easyrsa gen-req $REPLY
        _RESULT=$REPLY
    fi
}

generate_certificate_no_password () {
    echo Certificates list:
    ls -l /home/wildroger/cert_user_files

    if read -p "Enter Client Name: "; then
        ./easyrsa gen-req $REPLY nopass
        _RESULT=$REPLY
    fi
}

sign_request () {
    ./easyrsa sign-req client $1
}

revoke_certificate () {
    echo Certificates list:
    ls -l /home/wildroger/cert_user_files

    if read -p "Enter Client Name: "; then
        ./easyrsa revoke $REPLY
        _RESULT=$REPLY
    fi
}

copy_certificate_files () {
    mkdir /home/wildroger/cert_user_files/$1
    cp /home/wildroger/config_files/vpnserver.kz.ovpn /home/wildroger/cert_user_files/$1/
    cp /etc/openvpn/ca/pki/issued/$1.crt /home/wildroger/cert_user_files/$1/
    cp /etc/openvpn/ca/pki/private/$1.key /home/wildroger/cert_user_files/$1/
    cp /home/wildroger/config_files/ca.crt /home/wildroger/cert_user_files/$1/
    cp /home/wildroger/config_files/ta.key /home/wildroger/cert_user_files/$1/
    sed -i "s/#cert client_1.crt/#cert $1.crt/" /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    sed -i "s/#key client_1.key/#key $1.key/" /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    chmod 777 /home/wildroger/cert_user_files/$1/$1.crt
    chmod 777 /home/wildroger/cert_user_files/$1/$1.key

    echo -e \ >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "<ca>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    cat /home/wildroger/config_files/ca.crt >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "</ca>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo -e \ >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "<tls-auth>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    cat /home/wildroger/config_files/ta.key | sed -n 4,21p >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "</tls-auth>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo -e \ >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "<cert>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    cat /home/wildroger/cert_user_files/$1/$1.crt | sed -n 65,85p >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "</cert>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo -e \ >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "<key>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    cat /home/wildroger/cert_user_files/$1/$1.key >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "</key>" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo -e \ >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
    echo "key-direction 1" >> /home/wildroger/cert_user_files/$1/vpnserver.kz.ovpn
}

delete_certificate_files () {
    echo "Delete certificate files?"
    read -p "enter "yes" or "no": "

    if [[ "$REPLY" = "yes" ]]; then
        rm -R /home/wildroger/cert_user_files/$1

    elif [[ "$REPLY" = "no" ]]; then
        echo "Certificate files not delete."
            
    else 
        delete_certificate_files

    fi
}

enter_number () {
    read -p "Enter Number: "
   
	if [[ "$REPLY" = "1" ]]; then
        generate_certificate
        local CLIENT_NAME="$_RESULT"
        sign_request "$CLIENT_NAME"
        copy_certificate_files "$CLIENT_NAME"

    elif [[ "$REPLY" = "2" ]]; then
        generate_certificate_no_password
        local CLIENT_NAME="$_RESULT"
        sign_request "$CLIENT_NAME"
        copy_certificate_files "$CLIENT_NAME"

    elif [[ "$REPLY" = "3" ]]; then
        revoke_certificate
        local CLIENT_NAME="$_RESULT"
        delete_certificate_files "$CLIENT_NAME"
        
    else 
        echo Enter Number: 1-3!
	    enter_number

	fi
}

enter_number

echo "Done!"