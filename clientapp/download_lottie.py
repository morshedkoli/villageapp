import urllib.request
import json
import re

def search_lottie():
    # Attempt to search using LottieFiles GraphQL or a public repo
    # Instead of searching blindly, I will pull a known charity animation 
    # from a free github repository or a known URL.
    # LottieFiles GraphQL public API for search:
    url = "https://graphql.lottiefiles.com/2022-08"
    query = """
    query {
      search(query: "charity character", first: 5) {
        edges {
          node {
            ... on Animation {
              name
              jsonUrl
            }
          }
        }
      }
    }
    """
    req = urllib.request.Request(url, data=json.dumps({"query": query}).encode('utf-8'), headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'})
    try:
        response = urllib.request.urlopen(req).read().decode('utf-8')
        data = json.loads(response)
        edges = data.get('data', {}).get('search', {}).get('edges', [])
        for edge in edges:
            node = edge.get('node', {})
            jsonUrl = node.get('jsonUrl')
            if jsonUrl:
                print("Found URL:", jsonUrl)
                content = urllib.request.urlopen(jsonUrl).read()
                with open("assets/charity_animation.json", "wb") as f:
                    f.write(content)
                print("Downloaded successfully!")
                return True
    except Exception as e:
        print("GraphQL failed:", e)

    # Fallback to a hardcoded public lottie JSON if GraphQL fails
    fallback_url = "https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json"
    print("Trying fallback:", fallback_url)
    try:
        content = urllib.request.urlopen(fallback_url).read()
        with open("assets/charity_animation.json", "wb") as f:
            f.write(content)
        print("Downloaded fallback successfully!")
    except Exception as e:
        print("Fallback failed:", e)

search_lottie()
