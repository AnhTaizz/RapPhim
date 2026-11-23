package cinema;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;
import cinema.VeMua.SuatChieu;

public class VeMuaDAO extends DAO {
    private static final String SHOWS="""
        SELECT s.*,p.tenPhim,p.theLoai,p.thoiLuong FROM tblSuatChieu s
        JOIN tblPhim p ON p.id=s.idPhim WHERE s.ngayGioChieu>NOW()
        """;
    private SuatChieu show(ResultSet r) throws SQLException {
        return new SuatChieu(r.getInt("id"),r.getString("tenPhim"),r.getString("theLoai"),r.getInt("thoiLuong"),
            r.getTimestamp("ngayGioChieu").toLocalDateTime(),r.getString("phongChieu"),r.getBigDecimal("giaVe"));
    }
    public List<SuatChieu> dkLayDsSuatChieu() throws SQLException {
        try(var c=open(); var q=c.prepareStatement(SHOWS+" ORDER BY s.ngayGioChieu,s.id"); var r=q.executeQuery()) {
            var list=new ArrayList<SuatChieu>(); while(r.next()) list.add(show(r)); return list;
        }
    }
    private SuatChieu get(Connection c,int id,boolean lock) throws SQLException {
        try(var q=c.prepareStatement(SHOWS+" AND s.id=?"+(lock?" FOR UPDATE OF s":""))) {
            q.setInt(1,id);
            try(var r=q.executeQuery()) {
                if(!r.next()) throw new IllegalArgumentException("Suất chiếu đã bắt đầu hoặc không tồn tại.");
                return show(r);
            }
        }
    }
    public SuatChieu dkChonSuatChieu(int id) throws SQLException {
        try(var c=open()) {return get(c,id,false);}
    }
    private Set<String> sold(Connection c,int id) throws SQLException {
        try(var q=c.prepareStatement("SELECT soGhe FROM tblGheVeMua WHERE idSuatChieu=?")) {
            q.setInt(1,id); var seats=new HashSet<String>();
            try(var r=q.executeQuery()) {while(r.next()) seats.add(r.getString(1));}
            return seats;
        }
    }
    public Set<String> gheDaBan(int id) throws SQLException {try(var c=open()) {return sold(c,id);}}
    public VeMua dkChonGhe(int id,List<String> seats) throws SQLException {
        var order=new VeMua(dkChonSuatChieu(id),seats);
        order.kiemTra(gheDaBan(id)); return order;
    }
    public record Receipt(int id,VeMua order,LocalDateTime purchasedAt) {}
    public Receipt dkXacNhanMua(int customer,int id,List<String> seats) throws SQLException {
        try(var c=open()) {
            c.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
            c.setAutoCommit(false);
            try {
                var order=new VeMua(get(c,id,true),seats);
                order.kiemTra(sold(c,id));
                LocalDateTime purchasedAt;
                try(var clock=c.createStatement(); var result=clock.executeQuery("SELECT NOW()")) {
                    result.next();
                    purchasedAt=result.getObject(1,LocalDateTime.class);
                }
                try(var ticket=c.prepareStatement("INSERT INTO tblVeMua(idThanhVien,idSuatChieu,ngayMua) VALUES(?,?,?)",Statement.RETURN_GENERATED_KEYS);
                    var seat=c.prepareStatement("INSERT INTO tblGheVeMua(idVeMua,idSuatChieu,soGhe) VALUES(?,?,?)")) {
                    ticket.setInt(1,customer); ticket.setInt(2,id); ticket.setObject(3,purchasedAt); ticket.executeUpdate();
                    int ticketId;
                    try(var keys=ticket.getGeneratedKeys()) {keys.next(); ticketId=keys.getInt(1);}
                    for(String number:order.ghe()) {
                        seat.setInt(1,ticketId); seat.setInt(2,id); seat.setString(3,number);
                        try {seat.executeUpdate();}
                        catch(SQLException e) {if(e.getErrorCode()==1062) throw new IllegalArgumentException("Ghế đã bán: "+number+"."); throw e;}
                    }
                    c.commit(); return new Receipt(ticketId,order,purchasedAt);
                }
            } catch(SQLException | RuntimeException e) {c.rollback(); throw e;}
        }
    }
}
