import urllib.request
import re

url = "https://github.com/search?q=charity+lottie+path%3A*.json&type=code"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    links = re.findall(r'href=[\'\"]?(/[^\'\" >]+\.json)', html)
    for link in links:
        print(link)
except Exception as e:
    print(e)
