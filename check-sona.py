import urllib.request

#Default cookie value
sessionid = '251l33svkwftvv34ytpsl5p1'

#Start by grabbing auth data from the file:

username = ''
password = ''

#Set up auth
auth_handler = urllib.request.HTTPBasicAuthHandler()
auth_handler.add_password(realm='PDQ Application',
                          uri='https://wlu-ls.sona-systems.com/all_exp_participant.aspx',
                          user=username,
                          passwd=password)

opener = urllib.request.build_opener(auth_handler)
# ...and install it globally so it can be used with urlopen.
urllib.request.install_opener(opener)

req = urllib.request.Request('https://wlu-ls.sona-systems.com/all_exp_participant.aspx')
req.add_header('ASP.NET_SessionId', sessionid)
req.add_header('Cookie', 'language_pref=EN')
# Customize the default User-Agent header value:

retLogin = urllib.request.urlopen(req)
print(retLogin.read())

