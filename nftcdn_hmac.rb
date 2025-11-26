#!/usr/bin/env ruby

require 'openssl'
require 'Base64'

def nftcdn_url(domain, key, token, path, params={}):
    url = build_url(domain, token, path, dict(params, tk=""))
    mac = base64.urlsafe_b64encode(hmac.new(key, url.encode('ascii'), digestmod=hashlib.sha256).digest())
    return build_url(domain, token, path, dict(params, tk=mac.decode('ascii').rstrip("=")))
end

def build_url(domain, token, path, params):
    query = urllib.parse.urlencode(params)
    return f"https://{token}.{domain}.nftcdn.io{path}?{query}"
end

# EXAMPLES

# Your nftcdn.io subdomain and secret key
(domain, key) = ("preprod", base64.b64decode("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI="))

token = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv"

# Original image
puts nftcdn_url(domain, key, token, "/image")

# Resized 256x256 WebP image
puts nftcdn_url(domain, key, token, "/image", params={'size': 256})

# Metadata
puts nftcdn_url(domain, key, token, "/metadata")
