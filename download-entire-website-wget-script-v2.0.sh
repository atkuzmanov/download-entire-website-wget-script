#!/bin/bash

# clear

set -e

################################

echo "Usage -> ./download-entire-website-wget-script.sh https://www.example.com/path/"

################################

URL="$1"
DOMAIN=""
DOMAIN_STRIPPED=""
URL_PROTOCOL_STRIPPED=""
TARGET_DOWNLOAD_DIR_NAME=""

################################

extract_domain_name() {
    DOMAIN=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "$URL")
}

extract_domain_name

################################

strip_www_from_domain_name() {
    DOMAIN_STRIPPED=$(echo "$DOMAIN" | sed "s/^www\.//")
}

strip_www_from_domain_name

################################

strip_protocol_from_domain_name() {
    # URL_PROTOCOL_STRIPPED=$(echo "$URL" | sed "s/^www\.//")

    f="$URL"

    ## Remove protocol part of url
    f="${f#http://}"
    f="${f#https://}"
    f="${f#ftp://}"
    f="${f#scp://}"
    f="${f#scp://}"
    f="${f#sftp://}"
    
    ## Remove username and/or username:password part of URL
    f="${f#*:*@}"
    f="${f#*@}"
    
    ## Remove rest of urls
    # f=${f%%/*}

    URL_PROTOCOL_STRIPPED="$f"
}

strip_protocol_from_domain_name

################################

generate_target_download_dir_name () {
    # TARGET_DOWNLOAD_DIR_NAME=$(echo $URL_PROTOCOL_STRIPPED | sed 's@/@@g')
    temp1=${URL_PROTOCOL_STRIPPED////$'_'}
    temp2=${temp1//./$'-'}
    TARGET_DOWNLOAD_DIR_NAME="$HOME/Downloads/downloaded-websites-wget/$temp2"
}

generate_target_download_dir_name

################################

# echo ${URL}
# echo ${DOMAIN}
# echo ${DOMAIN_STRIPPED}
# echo ${URL_PROTOCOL_STRIPPED}
# echo ${TARGET_DOWNLOAD_DIR_NAME}

################################

download_entire_website_wget() {
    wget \
    --page-requisites \
    --span-hosts \
    --convert-links \
    --adjust-extension \
    --no-parent \
    --execute robots=off \
    --random-wait \
    --user-agent=Mozilla \
    --continue \
    --no-clobber \
    --directory-prefix="$TARGET_DOWNLOAD_DIR_NAME" \
    --domains ${DOMAIN_STRIPPED} \
    ${URL}
}

download_entire_website_wget

################################
## 
## References
## https://stackoverflow.com/questions/2497215/how-to-extract-domain-name-from-url
## https://superuser.com/questions/14403/how-can-i-download-an-entire-website
## https://unix.stackexchange.com/questions/428989/allow-full-urls-starting-with-http-https-or-www-in-ping/428990#428990
## https://www.linuxjournal.com/content/downloading-entire-web-site-wget
## https://stackoverflow.com/questions/1078524/how-to-specify-the-location-with-wget
## https://www.gnu.org/software/wget/manual/wget.html#Spanning-Hosts
## https://linux.die.net/man/1/wget
## https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
## https://www.devdungeon.com/content/taking-command-line-arguments-bash
## https://www.lifewire.com/pass-arguments-to-bash-script-2200571
## https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
## http://linuxcommand.org/lc3_wss0120.php
## 
## https://unix.stackexchange.com/questions/480846/removing-first-forward-slash-from-string
## https://stackoverflow.com/questions/39646508/bash-remove-forward-slash
## https://stackoverflow.com/questions/9018723/what-is-the-simplest-way-to-remove-a-trailing-slash-from-each-parameter
## https://www.cyberciti.biz/faq/get-extract-domain-name-from-url-in-linux-unix-bash/
## https://stackoverflow.com/questions/2871181/replacing-some-characters-in-a-string-with-another-character
## https://unix.stackexchange.com/questions/272596/replace-character-x-with-character-y-in-a-string-with-bash
## 
################################
