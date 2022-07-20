# certgen.sh

This is a quick and dirty shell script using openssl to generate self-signed CA and website certificates for development purposes.

## How to use

Make sure you have openssl installed.\
Execute the script in the desired directory. You'll be prompted for a CA domain. If they don't exist yet, a new key and self-signed certificate file will be generated and saved as `{ca_domain}.key` and `{ca_domain}.crt`. If they do exist, you get the option to use the existing files.\
Next, you can generate as many website certificates as you need, using the generated or existing CA key to sign them.\
You'll be prompted for domain, org name and email for both the CA and any website certificates you generate. Country, state, location, org unit and the amount of days until the certificate expires all have default values that are defined in the top of the file and that you can change to suit your needs.\
Website certificates are automatically given a subjectAltName extension for `*.{domain}`.
