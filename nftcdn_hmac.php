#!/usr/bin/env php

<?php
function nftcdn_url($domain, $key, $asset, $uri = "/image", $params = array())
{
  $params['tk'] = '';
  $url = build_url($domain, $asset, $uri, $params);
  $params['tk'] = base64url_encode(hash_hmac("sha256", $url, $key, true));
  return build_url($domain, $asset, $uri, $params);
}

function build_url($domain, $asset, $uri, $params)
{
  $query = http_build_query($params);
  return "https://{$asset}.{$domain}.nftcdn.io{$uri}?{$query}";
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

$asset = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv";

# Original image
echo nftcdn_url($domain, $key, $asset) . PHP_EOL;

# Resized 512x512 WebP image
echo nftcdn_url($domain, $key, $asset, "/image", array('size' => 512)) . PHP_EOL;

# Resized 256x256 WebP image expiring in 1 week
$params = array(
  'size' => 256,
  'ts' => time(), # unix timestamp for now
  'exp' => 60 * 60 * 24 * 7 # 1 week in seconds
);
echo nftcdn_url($domain, $key, $asset, "/image", $params) . PHP_EOL;

?>
