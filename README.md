# sona-checker
Checks SONA instance for new studies via ID check. Tracks encountered IDs and sends email alerts for new ones.
<br>
<br>
Don't want to set it up yourself? Message me your mail address and I'll add it to my mailing list (recommend student email).
<br>
<br>
How to use:
Open up sona-checker.sh; comments should tell you which files you'll need to define.
<br> 
Requires credentials to login to SONA, email address for alerts.
<br>
This version pushes the requirement for HTML URL encoding the password onto the user.
It must be stored pre-encoded in the credentials file
<br>
To set up continuous checking, use crontab or service.
<br>
e.g. Crontab: /15 8-20 * * * cd /u3/r249li/scripts/sona_checker && ./sona-checker.sh;

