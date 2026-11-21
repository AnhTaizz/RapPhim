package cinema;
import java.sql.*;
import java.util.*;

public class PhimDAO extends DAO {
    private Phim phim(ResultSet r) throws SQLException {
        return new Phim(r.getInt("id"),r.getString("tenPhim"),r.getString("theLoai"),r.getInt("thoiLuong"),r.getString("moTa"));
    }
    public List<Phim> dkTimPhim(String keyword) throws SQLException {
        try(var c=open(); var q=c.prepareStatement("SELECT * FROM tblPhim WHERE LOCATE(?,tenPhim)>0 ORDER BY tenPhim")) {
            q.setString(1,keyword);
            var list=new ArrayList<Phim>();
            try(var r=q.executeQuery()) { while(r.next()) list.add(phim(r)); }
            return list;
        }
    }
    public Phim dkChonPhim(int id) throws SQLException {
        try(var c=open(); var q=c.prepareStatement("SELECT * FROM tblPhim WHERE id=?")) {
            q.setInt(1,id);
            try(var r=q.executeQuery()) {return r.next()?phim(r):null;}
        }
    }
    public void dkLuu(Phim p) throws SQLException {
        if(p.tenPhim.isBlank() || p.tenPhim.length()>255) throw new IllegalArgumentException("Tên phim phải có từ 1 đến 255 ký tự.");
        if(p.theLoai.isBlank() || p.theLoai.length()>100) throw new IllegalArgumentException("Thể loại phải có từ 1 đến 100 ký tự.");
        if(p.thoiLuong<1) throw new IllegalArgumentException("Thời lượng phải là số phút nguyên dương.");
        if(p.moTa.getBytes(java.nio.charset.StandardCharsets.UTF_8).length>65535) throw new IllegalArgumentException("Mô tả quá dài.");
        try(var c=open(); var check=c.prepareStatement("SELECT id FROM tblPhim WHERE tenPhim=? AND id<>?");
            var save=c.prepareStatement("UPDATE tblPhim SET tenPhim=?,theLoai=?,thoiLuong=?,moTa=? WHERE id=?")) {
            check.setString(1,p.tenPhim); check.setInt(2,p.id);
            try(var r=check.executeQuery()) {if(r.next()) throw duplicate();}
            save.setString(1,p.tenPhim); save.setString(2,p.theLoai); save.setInt(3,p.thoiLuong);
            save.setString(4,p.moTa); save.setInt(5,p.id);
            try {if(save.executeUpdate()!=1) throw new IllegalArgumentException("Không tìm thấy phim.");}
            catch(SQLException e) {if(e.getErrorCode()==1062) throw duplicate(); throw e;}
        }
    }
    private IllegalArgumentException duplicate() {return new IllegalArgumentException("Tên phim đã tồn tại.");}
}
