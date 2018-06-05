# sona-checker
Checks SONA instance for new studies via ID check. Tracks encountered IDs and sends email alerts for new ones.

How to use:
Open up sona-checker.sh; comments should tell you which files you'll need to define.
<br> 
Requires credentials to login to SONA, email address for alerts.
<br>
This version pushes the requirement for HTML URL encoding the password onto the user.
It must be stored pre-encoded in the credentials file
<br>
To set up continuous checking, use crontab or service.
