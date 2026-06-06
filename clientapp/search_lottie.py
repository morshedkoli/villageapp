import urllib.request, urllib.parse, re

url = 'https://html.duckduckgo.com/html/?q=' + urllib.parse.quote('site:github.com lottie animation json charity OR donation')
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
html = urllib.request.urlopen(req).read().decode('utf-8')
links = re.findall(r'href=[\'\"]?(https://github\.com/[^\'\" >]+)', html)
for link in links:
    print(link)
