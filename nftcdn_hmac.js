#!/usr/bin/env node

const crypto = require('crypto');
const { URLSearchParams } = require('url');

function nftcdnUrl(domain, key, token, uri, params = {}) {
    params.tk = "";
    let url = buildUrl(domain, token, uri, params);
    params.tk = crypto.createHmac("sha256", key).update(url).digest("base64url");
    return buildUrl(domain, token, uri, params);
}

function buildUrl(domain, token, uri, params) {
    const searchParams = new URLSearchParams(params);
    return `https://${token}.${domain}.nftcdn.io${uri}?${searchParams.toString()}`;
}

// EXAMPLES

// Your nftcdn.io subdomain and secret key
let [domain, key] = ["preprod", Buffer.from("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=", "base64")];

let token = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv"

// Original image
console.log(nftcdnUrl(domain, key, token, "/image"));

// Resized 256x256 WebP image
console.log(nftcdnUrl(domain, key, token, "/image", { size: 256 }));

// Metadata
console.log(nftcdnUrl(domain, key, token, "/metadata"));
