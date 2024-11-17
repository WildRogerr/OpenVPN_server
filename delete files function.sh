delete_certificate_files () {
	echo "Delete certificate files?"
	read -p "enter "yes" or "no": "

	if [[ "$REPLY" = "yes" ]]; then 
		rm /etc/openvpn/ca/pki/issued/$1.crt
        rm /etc/openvpn/ca/pki/private/$1.key
        rm /etc/openvpn/ca/pki/regs/$1.req

	elif [[ "$REPLY" = "no" ]];then
		echo "Certificate files not delete."
	
	else
		del.cert     
		
	fi
}