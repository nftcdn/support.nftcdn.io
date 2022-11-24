# nftcdn.io

- [/image](#image)
    - [Size](#size)
- [/metadata](#metadata)
- [Authentication Code](#authentication-code-tk-token-parameter)
- [Hotlink Protection & CORS Restrictions](#hotlink-protection--cors-restrictions)
- [HTTP Status Codes](#http-status-codes)
- [References](#references)

**nftcdn.io** aims at making displaying Cardano NFTs as easy, efficient and secure as possible without requiring knowledge of the underlying standards and storage used.

The first version `/image` endpoint focuses on speed and security over fidelity by providing an optimized still image from CIP25, CIP68 and CNFT v0.01 standards `image` property, as well as the [Token Registry](https://github.com/cardano-foundation/cardano-token-registry) (CIP 68 & Token Registry support incoming).

Later versions will focus on providing a more complete viewing experience.


## /image

The `/image` endpoint returns a token image usable in an HTML `<img>` tag.

**Preview network**
```
https://asset1xxx.preview.nftcdn.io/image[?size=PIXELS]
```
**Preprod network**
```
https://asset1xxx.preprod.nftcdn.io/image?tk=HMAC[&size=PIXELS]
```
**Mainnet network**
```
https://asset1xxx.YOUR_SUBDOMAIN.nftcdn.io/image?tk=HMAC[&size=PIXELS]
```

`asset1xxx` is the [CIP 14](https://cips.cardano.org/cips/cip14/) fingerprint of a token.

**preview** endpoint is public and does not require URLs to be authenticated.  
**preprod** and **mainnet** ones are secured and require URLs to be authenticated.

The `tk` authentication code is described [here](#authentication-code-tk-token-parameter).

### Size

Without `size` parameter, the original image from the NFT `image` property is returned in its original format.

With a `size` parameter in pixels, the image is rescaled if needed to have its largest side equal to `size`, and returned in `WebP` format. If the image is already smaller than the requested size, it is just converted to `WebP`. For animated images like GIFs, the first frame is used.

⚠️  Only power of two sizes (32, 64, 128, 256, 1024) are supported to optimize global caching and performance. If you need other sizes, please contact us.

**Example:**  
https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256  
```
<img src="https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256">  
```
![asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf](https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256)

***Note:***
*For now, on-chain and SVG images are returned as is. They will very likely be rasterized and rescaled too for the public release.*


## /metadata

The `/metadata` endpoint returns a token metadata in JSON format including a normalized display name.

**Preview network**
```
https://asset1xxx.preview.nftcdn.io/metadata
```
**Preprod network**
```
https://asset1xxx.preprod.nftcdn.io/metadata?tk=HMAC
```
**Mainnet network**
```
https://asset1xxx.YOUR_SUBDOMAIN.nftcdn.io/metadata?tk=HMAC
```

`asset1xxx` is the [CIP 14](https://cips.cardano.org/cips/cip14/) fingerprint of a token.

**preview** endpoint is public and does not require URLs to be authenticated.  
**preprod** and **mainnet** ones are secured and require URLs to be authenticated.

The `tk` authentication code is described [here](#authentication-code-tk-token-parameter).

### Properties

* `id`: Token ID (so-called "asset name" on Cardano)
* `name`: Token display name (to be displayed to users)
* `policy`: Policy ID
* `fingerprint`: CIP-14 Fingerprint
* `metadata`: Token original metadata

**Example:**  
https://asset1rhmwfllvhgczltxm0y7rdump6g5p5ax4c25csq.poolpm.nftcdn.io/metadata?tk=rGnnDpPZyq_UJvUF0w-UhPkFJ_SoSKA5c1aqfIQ-3wU

```
{
    "id": "537061636542756430",
    "name": "SpaceBud #0",
    "policy": "d5e6bf0500378d4f0da4e8dde6becec7621cd8cbf5cbb9b87013d4cc",
    "fingerprint": "asset1rhmwfllvhgczltxm0y7rdump6g5p5ax4c25csq",
    "metadata": {
        "arweaveId": "4zXmWOWjzVZUCoEzhIzy7iCg2xs_EkdCvT0I6TYOoGg",
        "image": "ipfs://QmNyHUZxfRxGpwg9QSbe3cMDkaT8so17TRvzXpNio5gbGf",
        "name": "SpaceBud #0",
        "traits": [
            "Star Suit",
            "Chestplate",
            "Belt",
            "Covered Helmet"
        ],
        "type": "Frog"
    }
}
```

***Notes:***  
* *For CIP-68 tokens, the `id` and `fingerprint` are the reference token ones.*


## Authentication Code (`tk` token parameter)

On `mainnet`, to protect our users bandwidth and prevent URL forgery, URLs must be authenticated using a SHA256 HMAC authentication code.

On `preprod`, the authentication code is also required for test purpose so the key is public:
```
7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=
```

### URL authentication process:
1. Build the URL including `tk` parameter with an empty value
2. Generate the URL SHA256 HMAC using your secret key (provided in [base64](https://datatracker.ietf.org/doc/html/rfc4648#section-4))
3. Include the HMAC value encoded in [base64url](https://datatracker.ietf.org/doc/html/rfc4648#section-5) as the `tk` parameter value

⚠️  For a website, you should not expose your secret key in your frontend, so you would typically compute the HMAC codes from your backend, then send them or the whole URLs to your frontend to use them there. Depending on your architecture, it is likely beneficial to send those needed all at once as early as possible to avoid a lot of later requests.

### Node.js JavaScript example:
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


## Hotlink Protection & CORS Restrictions

To further protect users' bandwidth, requests are restricted to a single domain and limited optional related subdomains.

**Hotlink Protection** check that requests [`Referer`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer) header match your domain. `null` referer is permitted as it is used by some privacy browser features or extensions and some proxies, but it is set by clients so a website cannot enforce it globally.

**CORS** [`access-control-allow-origin`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) response header also allows only your domain.

***Note:***  
*`preprod` and `preview` endpoints do not have such restrictions.*


## Custom URL query parameters
Custom URL query parameters are allowed as long as they are included when generating an URL HMAC.

This can be useful to add internal details helping for later investigation as we plan to provide access to logs in the customer interface.


## HTTP Status Codes

* **`200`** or **`304`** is returned on success depending on request headers.
* **`400`** is returned on invalid requests (incorrect URL format or missing query parameters).
* **`403`** is returned on invalid HMAC or Referer.
* **`404`** is returned when the token, image or metadata is not found.

# References
* [CIP 14 - User-Facing Asset Fingerprint](https://cips.cardano.org/cips/cip14/)
* [CIP 25 - Media NFT Metadata Standard](https://cips.cardano.org/cips/cip25/)
* [CIP 68 - Datum Metadata Standard](https://cips.cardano.org/cips/cip68/)
* [CIP 26 Off-Chain Metadata Registry (mainnet)](https://github.com/cardano-foundation/cardano-token-registry)
