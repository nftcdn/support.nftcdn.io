# nftcdn.io

- [Supported Standards](#supported-standards)
- [/image](#image)
    - [Size](#size)
- [/preview](#preview-beta)
- [/metadata](#metadata)
- [/files](#files)
- [Authentication Code](#authentication-code-tk-token-parameter)
- [Hotlink Protection & CORS Restrictions](#hotlink-protection--cors-restrictions)
- [HTTP Status Codes](#http-status-codes)
- [References](#references)

**nftcdn.io** aims at making displaying Cardano NFTs as easy, efficient and secure as possible without requiring knowledge of the underlying standards and storage used.

## Supported standards
- CNFT v0.01 (used during the first months of Mary era while CIP-0025 was still a draft)
- [CIP-0025](https://cips.cardano.org/cip/CIP-0025) version 1/2
- [CIP-0026](https://cips.cardano.org/cip/CIP-0026) [Mainnet Token Registry](https://github.com/cardano-foundation/cardano-token-registry) & [Testnet Token Registry](https://github.com/input-output-hk/metadata-registry-testnet)
- [CIP-0068](https://cips.cardano.org/cip/CIP-0068) 222/333/444 version 1/2/3
- [Ada $handles](https://public.koralabs.io/documentation/HandleResolution.pdf) including virtual sub-handles


## /image

The `/image` endpoint returns a token image usable in an HTML `<img>` tag.

When `size` parameter is used, the returned image is always a rescaled and optimized still image (1 frame) in WebP format. Are all images are then transcoded, this is the most secure way to display NFTs.

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

⚠️  Only power of two sizes (32, 64, 128, 256, 512, 1024) are supported to optimize global caching and performance. If you need other sizes, please contact us.

### Example
https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256  
```
<img src="https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256">  
```
![asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf](https://asset1cf4y9alel09d4xzheqcjn29mrla8f3k8pnzrdf.preview.nftcdn.io/image?size=256)


## /preview (beta)

The `/preview` endpoint returns an image usable in an HTML `<img>` tag.

It is similar to [`/image`](#image) with the following difference:
* GIF images are rescaled and transcoded to WebP but stay animated
* SVG images pass through and are therefore not converted to WebP (this may require additional CSS to position them correctly)
* If a supposedly high resolution image is available in metadata `files[0]`, it is used instead of `/image` when the requested size is above 512 (excluded).

Overall, compared to `/image`, it favors fidelity over consistency, security, size and speed.

The endpoint is in *beta* status because some changes are still considered.
For example it is planned to return a preview of the rendered HTML for HTML NFTs.

**Preview network**
```
https://asset1xxx.preview.nftcdn.io/preview[?size=PIXELS]
```
**Preprod network**
```
https://asset1xxx.preprod.nftcdn.io/preview?tk=HMAC[&size=PIXELS]
```
**Mainnet network**
```
https://asset1xxx.YOUR_SUBDOMAIN.nftcdn.io/preview?tk=HMAC[&size=PIXELS]
```

**preview** endpoint is public and does not require URLs to be authenticated.  
**preprod** and **mainnet** ones are secured and require URLs to be authenticated.

The `tk` authentication code is described [here](#authentication-code-tk-token-parameter).  
The `size` parameter is described [here](#size)

### Example
https://asset16jtevv5j9t3cv0u5usv26nypqjj3qge7mfcvjx.cardano.nftcdn.io/preview?size=128&tk=3iQicBdtjNFy2hYvpdH3oGjPItbnNgzEXBbvumz1cZE
```
<img src="https://asset16jtevv5j9t3cv0u5usv26nypqjj3qge7mfcvjx.cardano.nftcdn.io/preview?size=128&tk=3iQicBdtjNFy2hYvpdH3oGjPItbnNgzEXBbvumz1cZE">
```
![asset16jtevv5j9t3cv0u5usv26nypqjj3qge7mfcvjx](https://asset16jtevv5j9t3cv0u5usv26nypqjj3qge7mfcvjx.cardano.nftcdn.io/preview?size=128&tk=3iQicBdtjNFy2hYvpdH3oGjPItbnNgzEXBbvumz1cZE)


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
* `decimals`: Optional number of decimals (0 by default)
* `metadata`: Token original metadata

### Example
https://asset1rhmwfllvhgczltxm0y7rdump6g5p5ax4c25csq.cardano.nftcdn.io/metadata?tk=_06PkNXFjEFxvuOKJdac-iVVyQW9m6na0c8IeU2pskE

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

## /files
The `/files` endpoint returns CIP25 or CIP68 additional files when available.

**Preview network**
```
https://asset1xxx.preview.nftcdn.io/files/INDEX/
```
**Preprod network**
```
https://asset1xxx.preprod.nftcdn.io/files/INDEX/?tk=HMAC
```
**Mainnet network**
```
https://asset1xxx.YOUR_SUBDOMAIN.nftcdn.io/files/INDEX/?tk=HMAC
```

`asset1xxx` is the [CIP 14](https://cips.cardano.org/cips/cip14/) fingerprint of a token.

`INDEX` is the file index in the metadata, starting from 0.

The terminating `/` is required to correctly render NFTs that load assets from the same IPFS directory or Arweave manifest using relative links, for example some HTML NFTs.

**preview** endpoint is public and does not require URLs to be authenticated.  
**preprod** and **mainnet** ones are secured and require URLs to be authenticated.

The `tk` authentication code is described [here](#authentication-code-tk-token-parameter).

### Security

To improve security, privacy and NFTs lifetime, all files are served with a [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) set to:
```
default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob:
```
This basically prevents NFTs to make requests or load assets from/to external domains, forcing them to be self-contained. Beyond the security & privacy benefits, this also gives more guarantees that the NFT rendering does not depend on external centralized servers to work properly. This is particularly useful for HTML or SVG files that can include JavaScript scripts.

In addition, the [`sandbox`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#sandbox) property can also be used for additional restrictions when rendering an HTML NFT using an `<iframe>`.

### Examples

#### Audio file
```
<audio controls src="https://asset1yzm65ncsv6kafcnlusxfx05wjr2edradpjyu97.cardano.nftcdn.io/files/0?tk=aZXZEBsQnhfsGazF-43CmDNtPDyqSdqhxqIriPxZjqk"></audio>
```
https://asset1yzm65ncsv6kafcnlusxfx05wjr2edradpjyu97.cardano.nftcdn.io/files/0/?tk=U7xPuMRArqtnhNe_8V9hU2s3nmdHyqNqr7cvz1ajXYY

#### Video file
```
<video controls src="https://asset1zgc5ggqjxyj9nxw79hwzp5h499yrf52lpd77rk.cardano.nftcdn.io/files/0/?tk=RjTkto2VR92sSECKGzd0SunAZJzju4xQPR0Q5Te5Oi4"></video>
```
https://asset1zgc5ggqjxyj9nxw79hwzp5h499yrf52lpd77rk.cardano.nftcdn.io/files/0/?tk=RjTkto2VR92sSECKGzd0SunAZJzju4xQPR0Q5Te5Oi4

#### HTML NFT
```
<iframe sandbox="allow-scripts allow-downloads" src="https://asset15ww77n3qdp64estz23px26z6quek25p82a4cje.cardano.nftcdn.io/files/0/?tk=wWu0ePP5vYSHcnFQvowu2aMpIN1MSBxRi_k-hA3batE"></iframe>
```
https://asset15ww77n3qdp64estz23px26z6quek25p82a4cje.cardano.nftcdn.io/files/0/?tk=wWu0ePP5vYSHcnFQvowu2aMpIN1MSBxRi_k-hA3batE


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

### Node.js 16+ JavaScript example:
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

// Your nftcdn.io subdomain and secret key
let [domain, key] = ["preprod", Buffer.from("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=", "base64")];

// Test
console.log(nftcdnUrl(domain, key, "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv", "/image", { size: 256 }));
```

Working examples for `preprod` in [JavaScript](nftcdn_hmac.js), [Python](nftcdn_hmac.py), [Ruby](nftcdn_hmac.rb) and [PHP](nftcdn_hmac.php) are included in [the repository](/).

Asset fingerprints can be computed using Open Source libraries, for example https://github.com/Emurgo/cip14-js in JavaScript.

### Example
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
