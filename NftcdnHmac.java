import java.net.URI;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.util.OptionalInt;

public class NftcdnHmac {

    private static URI nftcdnUrl(String domain, byte[] key, String token, String path)
            throws URISyntaxException, NoSuchAlgorithmException, InvalidKeyException {
        return nftcdnUrl(domain, key, token, path, OptionalInt.empty());
    }

    private static URI nftcdnUrl(String domain, byte[] key, String token, String path, int size)
            throws URISyntaxException, NoSuchAlgorithmException, InvalidKeyException {
        return nftcdnUrl(domain, key, token, path, OptionalInt.of(size));
    }

    private static URI nftcdnUrl(String domain, byte[] key, String token, String path, OptionalInt size)
            throws URISyntaxException, NoSuchAlgorithmException, InvalidKeyException {
        // Build URL without authentication code value
        String sizeParam = size.isPresent() ? "&size=" + size.getAsInt() : "";
        URI url = buildUrl(domain, token, path, "tk=" + sizeParam);

        // Compute SHA256 HMAC authentication code.
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec keySpec = new SecretKeySpec(key, "HmacSHA256");
        mac.init(keySpec);
        byte[] hmac = mac.doFinal(url.toString().getBytes());

        // Return URL with MAC
        String tk = Base64.getUrlEncoder().withoutPadding().encodeToString(hmac);
        return buildUrl(domain, token, path, "tk=" + tk + sizeParam);
    }

    private static URI buildUrl(String domain, String token, String path, String params)
            throws URISyntaxException, NoSuchAlgorithmException, InvalidKeyException {
        URI uri = new URI("https://" + token + "." + domain + ".nftcdn.io" + path + "?" + params);
        return uri;
    }

    public static void main(String[] args)
            throws URISyntaxException, NoSuchAlgorithmException, InvalidKeyException {
        // EXAMPLES

        // Your nftcdn.io subdomain and secret key
        String domain = "preprod";
        byte[] key = Base64.getDecoder().decode("7FoxfBgV2k+RSz6UUts3/fG1edG7oIGXxdtIVCdalaI=");

        String token = "asset1cpfcfxay6s73xez8srvhf0pydtd9yqs8hyfawv";

        // Original image
        System.out.println(nftcdnUrl(domain, key, token, "/image").toString());

        // Resized 256x256 WebP image
        System.out.println(nftcdnUrl(domain, key, token, "/image", 256).toString());

        // Metadata
        System.out.println(nftcdnUrl(domain, key, token, "/metadata").toString());
    }
}