#!/bin/bash

#Quick 'N Dirty checker for sona
#To be scheduled by crontab 

#Defining permenant files that will be used
ID_FILE="ids.txt"
COOKIE_FILE="cookies.txt"
EMAILS_FILE="email_list.txt"

login() {
    #Default session id
    SESSIONID='251l33svkwftvv34ytpsl5p1'

    #Grab credentials
    USERNAME=$(sed '1q;d' credentials.txt)
    PASSWORD=$(sed '2q;d' credentials.txt)

    #Fields to pass to curl
    DATA="__LASTFOCUS=&__VIEWSTATE=%2FwEPDwUJNjM2MDQ1NTgyZGSHi2XgX%2FUE1%2F9%2BPCRY6NJ4nXYVWCVXfAYIFvqAveLC3A%3D%3D&__VIEWSTATEGENERATOR=CA0B0334&__EVENTTARGET=&__EVENTARGUMENT=&__EVENTVALIDATION=%2FwEdAAVJNJYm0f4uWg7cS6joTPw5UIlPJ3shF6ZfHx5cHAdswX1Gsa4Qp9IFMNZyT1m%2FORlOGPoKvJSxXl507%2BPWyULdk0IaRa81gSyF%2Ft2E7n3iJWU%2BD9YgP8jtn3s5kkIRi4NZc9SrPpif7I8VynwW%2BcCE&ctl00%24ContentPlaceHolder1%24return_experiment_id=&ctl00%24ContentPlaceHolder1%24userid=${USERNAME}&ctl00%24ContentPlaceHolder1%24pw=${PASSWORD}%21&ctl00%24ContentPlaceHolder1%24default_auth_button=Log+In"
    COOKIE="Cookie: language_pref=EN; ASP.NET_SessionId=$SESSIONID; cookie_ck=Y;"

    #Login request; returns required cookie into cookies.txt
    curl --cookie-jar $COOKIE_FILE -s "https://wlu-ls.sona-systems.com/default.aspx" -H "$COOKIE" -d "$DATA" >> /dev/null

    # Gross way to grab cookie in a hard-coded method
    WEBHOME=$(sed '5q;d' $COOKIE_FILE | awk '{print $7}')
    echo "Cookie: language_pref=EN; ASP.NET_SessionId=$SESSIONID; cookie_ck=Y; WEBHOME=$WEBHOME"
}

#Login and save the cookie
COOKIE="$(login)"

#Check the studies page
curl "https://wlu-ls.sona-systems.com/all_exp_participant.aspx" -H "$COOKIE" -s > studies.html

grep 'experiment_id=' studies.html | while read -r id ; do
    #Skip over duplicate div
    if echo "$id" | grep -q "btn"; then continue; fi
    if [ -z "$id" ]; then continue; fi

    ID_NUM=$(echo "$id" | sed 's/.*experiment_id=//' | sed 's/">.*//')

    if grep -q "$ID_NUM" "$ID_FILE"; then
        #Already encountered. Decide if want to do something
        echo "ID $ID_NUM already exists"
    else
        #Store variable in file
        echo "$ID_NUM" >> "$ID_FILE" 

        #Send out email
        echo "Sending out alert emails for $ID_NUM..."

        cat "email_list.txt" | while read -r address; do
            echo "Sending mail: $address"

            SUBJECT="New Study Available on Sona | ID: $ID_NUM"  
            TEXT="https://wlu-ls.sona-systems.com/default.aspx"  

            # SENDER='SonaCheckerBot <noreply@sonabot.com>'
            echo -e "$TEXT" | mail  -s "$SUBJECT" "$address"   
        done
    fi
done

#Remove garbage
rm studies.html


