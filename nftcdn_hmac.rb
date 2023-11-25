#!/usr/bin/env ruby
# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'uri'

module Nftcdn
  class UrlBuilder
    attr_reader :domain, :key, :token

    def initialize(domain, key, token)
      @domain = domain
      @key = key
      @token = token
    end

    def call(uri, params = {})
      hmac = generate_hmac(uri, params)
      tk = Base64.urlsafe_encode64(hmac).delete('=')
      build_url(uri, params.merge(tk: tk))
    end

    private

    def generate_hmac(uri, params)
      key_decoded = Base64.decode64(key)
      url = build_url(uri, params.merge(tk: ''))
      OpenSSL::HMAC.digest('sha256', key_decoded, url)
    end

    def build_url(uri, params)
      query = URI.encode_www_form(params)
      "https://#{token}.#{domain}.nftcdn.io#{uri}?#{query}"
    end
  end
end

# EXAMPLES

# Your nftcdn.io subdomain, secret key
domain = 'preprod'
key = '7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI='

# The fingerprint of the asset you want to access
token = 'asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv'

# The URL builder
url_builder = Nftcdn::UrlBuilder.new(domain, key, token)

# Original image
puts url_builder.call('/image')

# Resized 256x256 WebP image
puts url_builder.call('/image', { size: 256 })

# Metadata
puts url_builder.call('/metadata')
