#!/usr/bin/env node

const crypto = require('crypto');
const { URLSearchParams } = require('url');

function nftcdnUrl(domain, key, asset, uri = "/image", params = {}) {
    params.tk = "";
    let url = buildUrl(domain, asset, uri, params);
    params.tk = crypto.createHmac("sha256", key).update(url).digest("base64url");
    return buildUrl(domain, asset, uri, params);
}

function buildUrl(domain, asset, uri, params) {
    const searchParams = new URLSearchParams(params);
    return `https://${asset}.${domain}.nftcdn.io${uri}?${searchParams.toString()}`;
}

// EXAMPLES

// Your nftcdn.io subdomain and secret key
let [domain, key] = ["preprod", Buffer.from("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=", "base64")];

let asset = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv"

// Original image
console.log(nftcdnUrl(domain, key, asset));

// Resized 512x512 WebP image
console.log(nftcdnUrl(domain, key, asset, "/image", { size: 512 }));

// Resized 256x256 WebP image expiring in 1 week
let ts = Math.floor(Date.now() / 1000); // now
let exp = 60 * 60 * 24 * 7; // 1 week in seconds
console.log(nftcdnUrl(domain, key, asset, "/image", { size: 256, ts, exp }));

