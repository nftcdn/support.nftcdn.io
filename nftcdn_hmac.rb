#!/usr/bin/env ruby

require "openssl"
require "base64"
require "uri"

def nftcdn_url(domain, key, token, path, params = {})
  url = build_url(domain, token, path, params.merge({ tk: ""}))
  params[:tk] = Base64.urlsafe_encode64(OpenSSL::HMAC.digest('sha256', key, url), padding: false)
  return build_url(domain, token, path, params)
end

def build_url(domain, token, path, params)
  query = URI.encode_www_form(params)
  url = URI::HTTPS.build(host: "#{token}.#{domain}.nftcdn.io", path: path, query: query)
  return url.to_s
end

# EXAMPLES

# Your nftcdn.io subdomain and secret key
domain, key = "preprod", Base64.decode64("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=")

token = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv"

# Original image
puts nftcdn_url(domain, key, token, "/image")

# Resized 256x256 WebP image
puts nftcdn_url(domain, key, token, "/image", { size: 256 })

# Metadata
puts nftcdn_url(domain, key, token, "/metadata")
