# Change these to suit your needs:
ca_country="NL"
ca_state="Gelderland"
ca_location="Nijmegen"
ca_org_unit="Development"
ca_valid_days=365
website_country="NL"
website_state="Gelderland"
website_location="Nijmegen"
website_org_unit="Development"
website_valid_days=365

read -p "CA domain: " ca_domain

ca_key_file=${ca_domain}.key
ca_crt_file=${ca_domain}.crt

if [ -e $ca_key_file -a -e $ca_crt_file ]
then
	use_old='?'
	while [ $use_old != 'y' -a $use_old != 'n' ]
	do
		read -p "CA's key and crt files found. Use existing files? (y/n): " use_old
	done
	
	if [ ${use_old} == 'n' ]
	then
		echo -e "\nOverwriting old CA cert files."
		gen_ca='y'
	else
		gen_ca='n'
	fi
else
	echo "No existing CA certificate found. Generating new."
	gen_ca='y'
fi

if [ $gen_ca == 'y' ]
then
	read -p "CA org name: " ca_org_name
	read -p "CA email: " ca_email
	
	echo "Generating CA's key and self-signed certificate..."
	openssl req -x509 -new -newkey rsa:4096 -days $ca_valid_days -nodes -keyout $ca_key_file -out $ca_crt_file -subj "/C=${ca_country}/ST=${ca_state}/L=${ca_location}/O=${ca_org_name}/OU=${ca_org_unit}/CN=${ca_domain}/emailAddress=${ca_email}"
	
	echo "$ca_key_file and $ca_crt_file generated!"
	#openssl x509 -in $ca_domain.crt -noout -text
fi

wc_generated=""
while true
do
	gen_wc='?'
	while [ $gen_wc != 'y' -a $gen_wc != 'n' ]
	do
		read -p "Generate${wc_generated} website certificate? (y/n): " gen_wc
	done

	if [ $gen_wc == 'n' ]
	then
		break
	fi

	read -p "Website domain: " website_domain
	read -p "Website org name: " website_org_name
	read -p "Website email: " website_email

	website_key_file=${website_domain}.key
	website_csr_file=${website_domain}.csr
	website_ext_file=${website_domain}-ext.cnf
	website_crt_file=${website_domain}.crt

	echo "Generating web server's key and certificate signing request (CSR)"
	openssl req -new -newkey rsa:2048 -nodes -keyout $website_key_file -out $website_csr_file -subj "/C=${website_country}/ST=${website_state}/L=${website_location}/O=${website_org_name}/OU=${website_org_unit}/CN=${website_domain}/emailAddress=${website_email}"

	echo "Generating extension file"
	echo "subjectAltName=DNS:*.${website_domain}" > $website_ext_file

	echo "Using CA's key to sign web server's CSR"
	openssl x509 -req -in $website_csr_file -CA $ca_crt_file -CAkey $ca_key_file -CAcreateserial -days $website_valid_days -out $website_crt_file -extfile $website_ext_file

	wc_generated=" another"

	echo -e "${website_key_file} and ${website_crt_file} generated!\n"
	#openssl x509 -in $website_domain.crt -noout -text
done

echo "Done!"