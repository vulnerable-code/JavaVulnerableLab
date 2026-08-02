package org.cysecurity.cspf.jvl.model;

import java.nio.charset.Charset;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

/**
 * Minimal HS256 JWT helper for the lab.
 *
 * sign() produces a genuinely signed token so that a correct verifier (see the
 * A01 slides) would reject any tampering. decodePayload() deliberately reads the
 * claims WITHOUT checking the signature: that omission is the vulnerability the
 * baac/ page demonstrates, not a bug in this helper.
 *
 * DatatypeConverter (JAXB) is used instead of java.util.Base64 so the code runs
 * on the Java 7 target as well as the Java 8 build JDK.
 */
public final class JwtUtil {

    private static final Charset UTF8 = Charset.forName("UTF-8");

    // Demo secret. A real deployment keeps a strong, rotated key server-side only.
    private static final byte[] SECRET = "jvl-demo-hs256-secret-do-not-reuse".getBytes(UTF8);

    private JwtUtil() {
    }

    public static String sign(String subject, String role) {
        String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        long now = System.currentTimeMillis() / 1000L;
        String payload = "{\"sub\":\"" + escape(subject) + "\",\"role\":\"" + escape(role)
                + "\",\"iss\":\"jvl\",\"iat\":" + now + ",\"exp\":" + (now + 3600L) + "}";

        String signingInput = base64Url(header.getBytes(UTF8)) + "." + base64Url(payload.getBytes(UTF8));
        return signingInput + "." + base64Url(hmacSha256(signingInput.getBytes(UTF8)));
    }

    /** Returns the raw claims JSON. Does NOT verify the signature (intentional for the lab). */
    public static String decodePayload(String token) {
        String[] parts = token.split("\\.");
        if (parts.length < 2) {
            return "{}";
        }
        return new String(base64UrlDecode(parts[1]), UTF8);
    }

    private static byte[] hmacSha256(byte[] data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET, "HmacSHA256"));
            return mac.doFinal(data);
        } catch (Exception e) {
            throw new RuntimeException("HMAC failure", e);
        }
    }

    private static String base64Url(byte[] data) {
        return DatatypeConverter.printBase64Binary(data)
                .replace('+', '-').replace('/', '_').replace("=", "");
    }

    private static byte[] base64UrlDecode(String s) {
        String t = s.replace('-', '+').replace('_', '/');
        int rem = t.length() % 4;
        if (rem == 2) {
            t += "==";
        } else if (rem == 3) {
            t += "=";
        }
        return DatatypeConverter.parseBase64Binary(t);
    }

    private static String escape(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
