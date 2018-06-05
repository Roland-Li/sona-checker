#!/bin/bash

#Quick 'N Dirty checker for sona
#To be scheduled by crontab 

#_______________________________________________________________________
# USER OPTIONS

#Set a value here for debugs. Empty = no messages
DEBUG=""

#These files must be user defined
#1: Emails file; 1 email address per line. Sends emails to these.
#2: Credentials file; line 1 is username, line 2 is password
EMAILS_FILE="email_list.txt" 
CREDENTIALS_FILE="credentials.txt" 

#Your page to check; modify to your sona instance
#Can technically only use the one page but...
DEFAULT_PAGE="https://wlu-ls.sona-systems.com/default.aspx"
STUDIES_PAGE="https://wlu-ls.sona-systems.com/all_exp_participant.aspx"

#These files will be generated to keep track
ID_FILE="ids.txt"
COOKIE_FILE="cookies.txt"
#_______________________________________________________________________

login() {
    #Default session id
    SESSIONID='251l33svkwftvv34ytpsl5p1'

    #Grab credentials
    USERNAME=$(sed '1q;d' $CREDENTIALS_FILE)
    PASSWORD=$(sed '2q;d' $CREDENTIALS_FILE)
    
    #Login request; returns required cookie into cookies.txt
    DATA="__LASTFOCUS=&__VIEWSTATE=%2FwEPDwUJNjM2MDQ1NTgyZGSHi2XgX%2FUE1%2F9%2BPCRY6NJ4nXYVWCVXfAYIFvqAveLC3A%3D%3D&__VIEWSTATEGENERATOR=CA0B0334&__EVENTTARGET=&__EVENTARGUMENT=&__EVENTVALIDATION=%2FwEdAAVJNJYm0f4uWg7cS6joTPw5UIlPJ3shF6ZfHx5cHAdswX1Gsa4Qp9IFMNZyT1m%2FORlOGPoKvJSxXl507%2BPWyULdk0IaRa81gSyF%2Ft2E7n3iJWU%2BD9YgP8jtn3s5kkIRi4NZc9SrPpif7I8VynwW%2BcCE&ctl00%24ContentPlaceHolder1%24return_experiment_id=&ctl00%24ContentPlaceHolder1%24userid=${USERNAME}&ctl00%24ContentPlaceHolder1%24default_auth_button=Log+In"
    COOKIE="Cookie: language_pref=EN; ASP.NET_SessionId=$SESSIONID; cookie_ck=Y;"

    #Login request; returns required cookie into cookies.txt
    curl --cookie-jar $COOKIE_FILE -s "https://wlu-ls.sona-systems.com/default.aspx" -H "$COOKIE" -d "$DATA" --data-urlencode "ctl00%24ContentPlaceHolder1%24pw=$PASSWORD" > /dev/null

    # Gross way to grab cookie in a hard-coded method
    WEBHOME=$(sed '5q;d' "$COOKIE_FILE" | awk '{print $7}')
    echo "Cookie: language_pref=EN; ASP.NET_SessionId=$SESSIONID; cookie_ck=Y; WEBHOME=$WEBHOME"
}

#Login and save the cookie
COOKIE="$(login)"

#Check the studies page
curl -s "$STUDIES_PAGE" -H "$COOKIE" > studies.html

#Check if loading page successful; if not, send alerts
CHECK1="$(grep "Object moved to" studies.html)"
CHECK2="$(grep "Bad Request" studies.html)"

if [ ! -z "$CHECK1" ] || [ ! -z "$CHECK2" ]; then
    if [ ! -z "$DEBUG" ]; then echo "Failed to login properly, cannot load page."; fi
    
    cat "email_list.txt" | while read -r address; do
        if [ -z "$address" ]; then continue; fi

        SUBJECT="Failed to check studies page. Cookie error?"  
        TEXT="$(echo cookies.txt)"  

        echo -e "$TEXT" | mail  -s "$SUBJECT" "$address"   
    done

    exit
fi

grep 'experiment_id=' studies.html | while read -r id ; do
    #Skip over duplicate div
    if echo "$id" | grep -q "btn"; then continue; fi
    if [ -z "$id" ]; then continue; fi

    # sed -e '1,/TERMINATE/d' studies.html #refernce for later additions

    ID_NUM=$(echo "$id" | sed 's/.*experiment_id=//' | sed 's/">.*//')

    if grep -q "$ID_NUM" "$ID_FILE"; then
        #Already encountered. 
        if [ ! -z "$DEBUG" ]; then echo "ID $ID_NUM already exists"; fi
    else
        #Store variable in file
        echo "$ID_NUM" >> "$ID_FILE"; 

        if [ ! -z "$DEBUG" ]; then echo "Sending out alert emails for $ID_NUM..."; fi

        #Send out email
        cat "email_list.txt" | while read -r address; do
            if [ -z "$address" ]; then continue; fi

            SUBJECT="New Study Available on Sona | ID: $ID_NUM"  
            TEXT="$STUDIES_PAGE"  

            # SENDER='SonaCheckerBot <noreply@sonabot.com>'
            echo -e "$TEXT" | mail  -s "$SUBJECT" "$address"   
        done
    fi
done

#Remove temp html page
# rm studies.html


