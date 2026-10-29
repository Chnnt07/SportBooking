package dal;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;


public class PasswordUtil {
    
    private static final int ITERATIONS = 120000;
    private static final int KEY_LENGTH = 256;

    public static String hashPassword(String password)
            throws Exception {

        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);

        byte[] hash = generateHash(password, salt, ITERATIONS);

        return "pbkdf2_sha256:"
                + ITERATIONS + ":"
                + Base64.getEncoder().encodeToString(salt) + ":"
                + Base64.getEncoder().encodeToString(hash);
    }

    public static boolean verifyPassword(
            String password, String storedHash) throws Exception {

        String[] parts = storedHash.split(":", -1);

        if (parts.length != 4
                || !parts[0].equals("pbkdf2_sha256")) {
            return false;
        }

        int iterations = Integer.parseInt(parts[1]);
        byte[] salt = Base64.getDecoder().decode(parts[2]);
        byte[] expectedHash = Base64.getDecoder().decode(parts[3]);

        byte[] actualHash = generateHash(
                password, salt, iterations);

        return MessageDigest.isEqual(expectedHash, actualHash);
    }

    private static byte[] generateHash(
            String password, byte[] salt, int iterations)
            throws Exception {

        PBEKeySpec spec = new PBEKeySpec(
                password.toCharArray(),
                salt,
                iterations,
                KEY_LENGTH
        );

        try {
            SecretKeyFactory factory =
                    SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");

            return factory.generateSecret(spec).getEncoded();
        } finally {
            spec.clearPassword();
        }
    }
}
