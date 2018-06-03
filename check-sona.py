import urllib.request

req = urllib.request.urlopen('https://www.google.com')
print(req.read())

