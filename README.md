# nftcdn.io

- [/image](#image)
    - [Size](#size)
    - [Authentication Code](#authentication-code-tk-token-parameter)
    - [Hotlink Protection & CORS Restrictions](#hotlink-protection--cors-restrictions)
    - [HTTP Status](#http-status)
- [References](#references)

**nftcdn.io** aims at making displaying Cardano NFTs as easy, efficient and secure as possible without requiring knowledge of the underlying standards and storage used.

The first version `/image` endpoint focuses on speed and security over fidelity by providing an optimized still image from CIP25, CIP68 and CNFT v0.01 standards `image` property, as well as the [Token Registry](https://github.com/cardano-foundation/cardano-token-registry) (CIP 68 & Token Registry support incoming).

Later versions will focus on providing a more complete viewing experience.

## /image

**Preview network**
```
https://asset1xxx.preview.nftcdn.io[?size=PIXELS]
```
**Preprod network**
```
https://asset1xxx.preprod.nftcdn.io?tk=HMAC[&size=PIXELS]
```
**Mainnet network**
```
https://asset1xxx.YOUR_SUBDOMAIN.nftcdn.io?tk=HMAC[&size=PIXELS]
```

`asset1xxx` is the [CIP 14](https://cips.cardano.org/cips/cip14/) fingerprint of an asset.

**preview** endpoint is public and does not require URLs to be authenticated.  
**preprod** and **mainnet** ones are secured and require URLs to be authenticated.

### Size

Without `size` parameter, the original image from the NFT `image` property is returned in its original format.

With a `size` parameter in pixels, the image is rescaled if needed to have its largest side equal to `size`, and returned in `WebP` format. If the image is already smaller than the requested size, it is just converted to `WebP`.

⚠️  Only power of two sizes (32, 64, 128, 256, 1024) are supported to optimize global caching and performance. If you need other sizes, please contact us.

**Example:**  
https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256  
```
<img src="https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256">  
```
![asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf](https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256)

***Note:***
*For now, on-chain and SVG images are returned as is. They will very likely be rasterized and rescaled too for the public release.*

### Authentication Code (`tk` token parameter)

On `mainnet`, to protect our users bandwidth and prevent URL forgery, URLs must be authenticated using a SHA256 HMAC authentication code.

On `preprod`, the authentication code is also required for test purpose so the key is public:
```
7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=
```

#### URL authentication process:
1. Build the URL including `tk` parameter with an empty value
2. Generate the URL SHA256 HMAC using your secret key (provided in [base64](https://datatracker.ietf.org/doc/html/rfc4648#section-4))
3. Include the HMAC value encoded in [base64url](https://datatracker.ietf.org/doc/html/rfc4648#section-5) as the `tk` parameter value

⚠️  For a website, you should not expose your secret key in your frontend, so you would typically compute the HMAC codes from your backend, then send them or the whole URLs to your frontend to use them there. Depending on your architecture, it is likely beneficial to send those needed all at once as early as possible to avoid a lot of later requests.

#### Node.js JavaScript example:
```
const crypto = require('crypto');
const { URLSearchParams } = require('url');

function nftcdnUrl(domain, key, asset, uri = "/image", params = {}) {
    // 1. Set an empty value to tk and build the URL
    params.tk = "";
    let url = buildUrl(domain, asset, uri, params);

    // 2. Generate the URL SHA256 HMAC encoded in base64url
    params.tk = crypto.createHmac("sha256", key).update(url).digest("base64url");
    
    // 3. Return the final URL including HMAC set as tk value
    return buildUrl(domain, asset, uri, params);
}

function buildUrl(domain, asset, uri, params) {
    const searchParams = new URLSearchParams(params);
    return `https://${asset}.${domain}.nftcdn.io${uri}?${searchParams.toString()}`;
}
```

Working examples for `preprod` in JavaScript, Python and PHP are included in the repository.

Asset fingerprints can be computed using Open Source libraries, for example https://github.com/Emurgo/cip14-js in JavaScript.

**Example:**  
https://asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv.preprod.nftcdn.io/image?tk=ZZ388CZwJhhLzm2djfRwaaPb8I_w7luNh5hOHJ2Ev4I&size=128  
```
<img src="https://asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv.preprod.nftcdn.io/image?tk=ZZ388CZwJhhLzm2djfRwaaPb8I_w7luNh5hOHJ2Ev4I&size=128">
```
![asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv](https://asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv.preprod.nftcdn.io/image?tk=ZZ388CZwJhhLzm2djfRwaaPb8I_w7luNh5hOHJ2Ev4I&size=128)

***Note:***
*The order of query parameters is not important but the same order must be used when generating the HMAC and when using the URL because it is not possible to guess the initial order when checking the URL authenticity. It is therefore possible to transmit only HMAC values to your frontend instead of full URLs as long as you keep the query parameters in the same order.*

### Hotlink Protection & CORS Restrictions

To further protect users' bandwidth, requests are restricted to a single domain and limited optional related subdomains.

**Hotlink Protection** check that requests [`Referer`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer) header match your domain. `null` referer is permitted as it is used by some privacy browser features or extensions and some proxies, but it is set by clients so a website cannot enforce it globally.

**CORS** [`access-control-allow-origin`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) response header also allows only your domain.

***Note:***  
*`preprod` and `preview` endpoints do not have such restrictions.*

### HTTP Status

* On success, 200 or 304 is returned depending on request headers.
* When the image is not found, 404 is returned (no image for the NFT or not found/acquired image yet from storage).
* On invalid HMAC, Referer or expired URL, 403 is returned.

# References
* [CIP 14 - User-Facing Asset Fingerprint](https://cips.cardano.org/cips/cip14/)
* [CIP 25 - Media NFT Metadata Standard](https://cips.cardano.org/cips/cip25/)
* [CIP 68 - Datum Metadata Standard](https://cips.cardano.org/cips/cip68/)
* [CIP 26 Off-Chain Metadata Registry (mainnet)](https://github.com/cardano-foundation/cardano-token-registry)
