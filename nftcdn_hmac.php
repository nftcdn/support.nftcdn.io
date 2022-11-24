#!/usr/bin/env php

<?php
function nftcdn_url($domain, $key, $token, $uri, $params = array())
{
  $params['tk'] = '';
  $url = build_url($domain, $token, $uri, $params);
  $params['tk'] = base64url_encode(hash_hmac("sha256", $url, $key, true));
  return build_url($domain, $token, $uri, $params);
}

function build_url($domain, $token, $uri, $params)
{
  $query = http_build_query($params);
  return "https://{$token}.{$domain}.nftcdn.io{$uri}?{$query}";
}

function base64url_encode($data)
{
  $b64 = base64_encode($data);
  $url = strtr($b64, '+/', '-_');
  return rtrim($url, '=');
}

# EXAMPLES

# Your nftcdn.io subdomain and secret key
[$domain, $key] = ["preprod", base64_decode("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=")];

$token = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv";

# Original image
echo nftcdn_url($domain, $key, $token, "/image") . PHP_EOL;

# Resized 256x256 WebP image
echo nftcdn_url($domain, $key, $token, "/image", array('size' => 256)) . PHP_EOL;

# Metadata
echo nftcdn_url($domain, $key, $token, "/metadata") . PHP_EOL;

?>
