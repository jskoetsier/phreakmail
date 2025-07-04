#!/usr/bin/env bash
[[ -f phreakmail.conf ]] && source phreakmail.conf
[[ -f ../phreakmail.conf ]] && source ../phreakmail.conf

if [[ -z ${DBUSER} ]] || [[ -z ${DBPASS} ]] || [[ -z ${DBNAME} ]]; then
	echo "Cannot find phreakmail.conf, make sure this script is run from within the phreakmail folder."
	exit 1
fi

echo -n "Checking MySQL service... "
if [[ -z $(docker ps -qf name=mysql-phreakmail) ]]; then
	echo "failed"
	echo "MySQL (mysql-phreakmail) is not up and running, exiting..."
	exit 1
fi

echo "OK"
read -r -p "Are you sure you want to reset the phreakmail administrator account? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then
	echo -e "\nWorking, please wait..."
  random=$(</dev/urandom tr -dc _A-Z-a-z-0-9 2> /dev/null | head -c${1:-16})
  password=$(docker exec -it $(docker ps -qf name=dovecot-phreakmail) doveadm pw -s SSHA256 -p ${random} | tr -d '\r')
	docker exec -it $(docker ps -qf name=mysql-phreakmail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM admin WHERE username='admin';"
  docker exec -it $(docker ps -qf name=mysql-phreakmail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM domain_admins WHERE username='admin';"
	docker exec -it $(docker ps -qf name=mysql-phreakmail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "INSERT INTO admin (username, password, superadmin, active) VALUES ('admin', '${password}', 1, 1);"
	docker exec -it $(docker ps -qf name=mysql-phreakmail) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM tfa WHERE username='admin';"
	echo "
Reset credentials:
---
Username: admin
Password: ${random}
TFA: none
"
else
	echo "Operation canceled."
fi
