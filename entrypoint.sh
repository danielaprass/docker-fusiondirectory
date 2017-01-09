#!/bin/bash
set -e

printf "Starting FusionDirectory ... ";

LDAP_DOMAIN=${LDAP_ENV_LDAP_DOMAIN:-${LDAP_DOMAIN}}
if [ -z ${LDAP_DOMAIN} ] ; then
    printf "\n\nLDAP_DOMAIN is not defined!\n"
    exit 1
fi

LDAP_HOST=${LDAP_PORT_389_TCP_ADDR:-${LDAP_HOST}}
if [ -z ${LDAP_HOST} ] ; then
    printf "\n\nLDAP_HOST is not defined!\n"
    exit 1
fi

LDAP_ADMIN_PASSWORD=${LDAP_ENV_LDAP_ADMIN_PASSWORD:-${LDAP_ADMIN_PASSWORD}}
if [ -z ${LDAP_ADMIN_PASSWORD} ] ; then
    printf "\n\nLDAP_ADMIN_PASSWORD is not defined!\n"
    exit 1
fi

IFS='.' read -a domain_elems <<< "${LDAP_DOMAIN}"

suffix=""
for elem in "${domain_elems[@]}" ; do
    if [ "x${suffix}" = x ] ; then
        suffix="dc=${elem}"
    else
        suffix="${suffix},dc=${elem}"
    fi
done

if [ -z ${LDAP_ADMIN_DN} ] ; then
    BASE_DN="dc=$(echo ${LDAP_DOMAIN} | sed 's/^\.//; s/\.$//; s/\./,dc=/g')"
    : ${LDAP_ADMIN:="admin"}
    LDAP_ADMIN_DN="cn=${LDAP_ADMIN},${BASE_DN}"

    printf "\n\nLDAP_ADMIN_DN is not defined and set to '${LDAP_ADMIN_DN}'\n"
fi

LDAP_TLS=${LDAP_TLS:-"false"}
LDAP_TLS=${LDAP_ENV_LDAP_TLS:-${LDAP_TLS}}

LDAP_SCHEME=${LDAP_SCHEME:-"ldap"}
LDAP_COMM_PORT=${LDAP_COMM_PORT:-389}
if ${LDAP_TLS}; then
    LDAP_SCHEME="ldaps"
    LDAP_COMM_PORT=636
fi

cat <<EOF > /etc/fusiondirectory/fusiondirectory.conf
<?xml version="1.0"?>
<conf>
  <!-- Main section **********************************************************
       The main section defines global settings, which might be overridden by
       each location definition inside.

       For more information about the configuration parameters, take a look at
       the FusionDirectory.conf(5) manual page.
  -->
  <main default="default"
        logging="TRUE"
        displayErrors="FALSE"
        forceSSL="FALSE"
        templateCompileDirectory="/var/spool/fusiondirectory/"
        debugLevel="0"
    >

    <!-- Location definition -->
    <location name="default"
    >
        <referral URI="${LDAP_SCHEME}://${LDAP_HOST}:${LDAP_COMM_PORT}/${suffix}"
                        adminDn="${LDAP_ADMIN_DN}"
                        adminPassword="${LDAP_ADMIN_PASSWORD}" />
    </location>
  </main>
</conf>
EOF

chmod 640 /etc/fusiondirectory/fusiondirectory.conf
chown root:www-data /etc/fusiondirectory/fusiondirectory.conf

yes Yes | fusiondirectory-setup --check-config

exec "$@"
