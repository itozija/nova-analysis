#!/usr/bin/env python3
import sys, json, urllib.request, urllib.error

APIFY_TOKEN = "YOUR_APIFY_TOKEN"
url = sys.argv[1] if len(sys.argv) > 1 else ""

if not url:
    print("ERROR: no URL provided")
    sys.exit(1)

payload = json.dumps({"startUrls": [{"url": url}], "maxVideos": 1}).encode()
endpoint = f"https://api.apify.com/v2/acts/streamers~youtube-scraper/run-sync-get-dataset-items?token={APIFY_TOKEN}&timeout=60"

req = urllib.request.Request(endpoint, data=payload, headers={"Content-Type": "application/json"}, method="POST")
try:
    with urllib.request.urlopen(req, timeout=90) as r:
        data = json.loads(r.read())
        if data:
            v = data[0]
            print(f"TITLE: {v.get('title','')}")
            print(f"CHANNEL: {v.get('channelName','')} ({v.get('numberOfSubscribers',0):,} subs)")
            print(f"VIEWS: {v.get('viewCount',0):,}")
            print(f"LIKES: {v.get('likes',0):,}")
            print(f"DURATION: {v.get('duration','')}")
            print(f"MONETIZED: {v.get('isMonetized','unknown')}")
            print(f"DESCRIPTION:\n{v.get('text','')[:2000]}")
        else:
            print("ERROR: no data returned")
except Exception as e:
    print(f"ERROR: {e}")
