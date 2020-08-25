#!/bin/bash

# clear
################################
set -e
################################
timestamp() {
  date +"%Y-%m-%d-%H%M%S"
}
################################
echo "Usage -> ./download-entire-website-wget-script-v2.0.sh [REPLACE-THIS-PLACEHOLDER-WITH-FILE-PATH]"
################################
FILE="$1"
DOMAIN=""
DOMAIN_STRIPPED=""
URL_PROTOCOL_STRIPPED=""
TARGET_DOWNLOAD_DIR_NAME=""
TARGET_DOWNLOAD_SUBDIR=""
################################
extract_domain_name() {
    DOMAIN=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "$URL")
    echo "--> DOMAIN: ${DOMAIN}"
}
# extract_domain_name
################################
strip_www_from_domain_name() {
    DOMAIN_STRIPPED=$(echo "$DOMAIN" | sed "s/^www\.//")
    echo "--> DOMAIN_STRIPPED: ${DOMAIN_STRIPPED}"
}
# strip_www_from_domain_name
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

    echo "--> URL_PROTOCOL_STRIPPED: ${URL_PROTOCOL_STRIPPED}"
}
# strip_protocol_from_domain_name
################################
generate_target_download_dir_name () {
    # TARGET_DOWNLOAD_DIR_NAME=$(echo $URL_PROTOCOL_STRIPPED | sed 's@/@@g')
    temp1=${URL_PROTOCOL_STRIPPED////$'_'}
    temp2=${temp1//./$'-'}
    
    if [[ -z "$TARGET_DOWNLOAD_SUBDIR" ]] ; then
        TARGET_DOWNLOAD_DIR_NAME="$HOME/Downloads/downloaded-websites-wget/$temp2"
    else
        TARGET_DOWNLOAD_DIR_NAME="$HOME/Downloads/downloaded-websites-wget/$TARGET_DOWNLOAD_SUBDIR/$temp2"
    fi
    echo "--> TARGET_DOWNLOAD_DIR_NAME: ${TARGET_DOWNLOAD_DIR_NAME}"
}
# generate_target_download_dir_name
################################
download_entire_website_wget() {
    ##---
    ## add `--mirror` option to
    ## Turn on options suitable for mirroring. This option turns on recursion and time-stamping, 
    ## sets infinite recursion depth and keeps FTP directory listings. It is currently equivalent to ‘-r -N -l inf --no-remove-listing’.
    ##---
    ## `--no-clobber` clashes with `--convert-links` and `--convert-links` tales precedence, so use one or the other.
    ## use `--quiet` or `--no-verbose` as necessary
    ##---
    ## `wget --user uname --password pass $url || true;` This way, if wget fails, the result of that line is still zero and your script continues.
    ## https://stackoverflow.com/questions/29723144/how-to-resume-loop-when-wget-returns-error-404-bash
    ##---

    wget \
    --content-on-error=on \
    --tries=0 \
    --no-check-certificate \
    --no-verbose \
    --page-requisites \
    --span-hosts \
    --convert-links \
    --adjust-extension \
    --no-parent \
    --execute robots=off \
    --random-wait \
    --user-agent=Mozilla \
    --continue \
    --directory-prefix="$TARGET_DOWNLOAD_DIR_NAME" \
    --domains ${DOMAIN_STRIPPED} \
    ${URL} || true;
}
# download_entire_website_wget
################################
download_for_each_website_wget_from_file() {
    while IFS= read -r line
    do
        if [[ $line = \#* ]] ; then
            temp3="${line/\#[[:space:]]/}"
            TARGET_DOWNLOAD_SUBDIR="${temp3//[[:space:]]/$'-'}"
            echo "--> TARGET_DOWNLOAD_SUBDIR: $TARGET_DOWNLOAD_SUBDIR"
            continue
        else        
            URL="$line"
            echo "--> URL: ${URL}"
            extract_domain_name
            strip_www_from_domain_name
            strip_protocol_from_domain_name
            generate_target_download_dir_name
            download_entire_website_wget
            sleep 1 ;
        fi
    done < "$FILE"
    echo "Done."
}
download_for_each_website_wget_from_file
################################
## debugging info:
# echo ${URL}
# echo ${DOMAIN}
# echo ${DOMAIN_STRIPPED}
# echo ${URL_PROTOCOL_STRIPPED}
# echo ${TARGET_DOWNLOAD_DIR_NAME}
################################
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
## https://unix.stackexchange.com/questions/480846/removing-first-forward-slash-from-string
## https://stackoverflow.com/questions/39646508/bash-remove-forward-slash
## https://stackoverflow.com/questions/9018723/what-is-the-simplest-way-to-remove-a-trailing-slash-from-each-parameter
## https://www.cyberciti.biz/faq/get-extract-domain-name-from-url-in-linux-unix-bash/
## https://stackoverflow.com/questions/2871181/replacing-some-characters-in-a-string-with-another-character
## https://unix.stackexchange.com/questions/272596/replace-character-x-with-character-y-in-a-string-with-bash
## https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
## https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/
## https://askubuntu.com/questions/411540/how-to-get-wget-to-download-exact-same-web-page-html-as-browser
## https://superuser.com/questions/1150495/save-an-entire-webpage-with-all-images-and-css-into-just-one-folder-and-one-fi
## https://www.puzzle.ch/de/blog/articles/2018/02/12/phantomjs-is-dead-long-live-headless-browsers
## https://stackoverflow.com/questions/29723144/how-to-resume-loop-when-wget-returns-error-404-bash
## https://stackoverflow.com/questions/27658675/how-to-remove-last-n-characters-from-a-string-in-bash
## https://stackoverflow.com/questions/28256178/how-can-i-match-spaces-with-a-regexp-in-bash/28256343
## https://unix.stackexchange.com/questions/78625/using-sed-to-find-and-replace-complex-string-preferrably-with-regex
## https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
## https://stackoverflow.com/questions/13509508/check-if-string-is-neither-empty-nor-space-in-shell-script
################################
