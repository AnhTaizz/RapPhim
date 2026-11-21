package cinema;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
public class PhimThongKeDAO extends DAO {
    public List<PhimThongKe> dkThongKe(LocalDate from, LocalDate to) throws SQLException {
        if(from.isAfter(to)) throw new IllegalArgumentException("Từ ngày phải trước hoặc bằng đến ngày.");
        String sql="""
            SELECT p.*,SUM(s.giaVe) AS doanhThu FROM tblGheVeMua g
            JOIN tblVeMua v ON v.id=g.idVeMua JOIN tblSuatChieu s ON s.id=v.idSuatChieu
            JOIN tblPhim p ON p.id=s.idPhim WHERE v.ngayMua>=? AND v.ngayMua < DATE_ADD(?, INTERVAL 1 DAY)
            GROUP BY p.id ORDER BY doanhThu DESC,p.tenPhim
            """;
        try(var c=open(); var q=c.prepareStatement(sql)) {
            q.setObject(1,from); q.setObject(2,to);
            var list=new ArrayList<PhimThongKe>();
            try(var r=q.executeQuery()) {while(r.next()) {
                var p=new PhimThongKe(r.getInt("id"),r.getString("tenPhim"),r.getString("theLoai"),r.getInt("thoiLuong"),r.getString("moTa"));
                p.setDoanhThu(r.getBigDecimal("doanhThu")); list.add(p);
            }}
            return list;
        }
    }
}
