package cinema;
import java.sql.*;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.util.HexFormat;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class ThanhVienDAO extends DAO {
    public record ThanhVien(int id, String name, String role) {}
    public ThanhVien login(String user, String password) throws SQLException, GeneralSecurityException {
        try (var c=open(); var q=c.prepareStatement("SELECT * FROM tblThanhVien WHERE tenDangNhap=?")) {
            q.setString(1,user);
            try(var r=q.executeQuery()) {
                if (!r.next() || password==null) return null;
                String[] parts=r.getString("matKhau").split(":");
                var key=new PBEKeySpec(password.toCharArray(),parts[0].getBytes(StandardCharsets.UTF_8),120000,256);
                byte[] hash=SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(key).getEncoded();
                if (!MessageDigest.isEqual(hash,HexFormat.of().parseHex(parts[1]))) return null;
                return new ThanhVien(r.getInt("id"),r.getString("hoTen"),r.getString("vaiTro"));
            }
        }
    }
}
