#!/usr/bin/env python3

import base64, hashlib, hmac, time, urllib.parse

def nftcdn_url(domain, key, asset, uri="/image", params={}):
    url = build_url(domain, asset, uri, dict(params, tk=""))
    mac = base64.urlsafe_b64encode(hmac.new(key, url.encode('ascii'), digestmod=hashlib.sha256).digest())
    return build_url(domain, asset, uri, dict(params, tk=mac.decode('ascii').rstrip("=")))

def build_url(domain, asset, uri, params):
    query = urllib.parse.urlencode(params)
    return f"https://{asset}.{domain}.nftcdn.io{uri}?{query}"

# EXAMPLES

# Your nftcdn.io subdomain and secret key
(domain, key) = ("preprod", base64.b64decode("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI="))

asset = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv"

# Original image
print(nftcdn_url(domain, key, asset))

# Resized 512x512 WebP image
print(nftcdn_url(domain, key, asset, params={'size': 512}))

# Resized 256x256 WebP image expiring in 1 week
timestamp = int(time.time()) # unix timestamp for now
expires = 60 * 60 * 24 * 7 # 1 week in seconds
print(nftcdn_url(domain, key, asset, params={'size': 256, 'ts': timestamp, 'exp': expires}))
