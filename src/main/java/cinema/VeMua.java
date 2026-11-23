package cinema;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

public record VeMua(SuatChieu suat,List<String> ghe) {
    public static final char LAST_ROW = 'H';
    public static final int SEATS_PER_ROW = 10;

    public record SuatChieu(int id,String phim,String loai,int phut,LocalDateTime gio,String phong,BigDecimal gia) {}
    public VeMua {
        if(ghe==null || ghe.isEmpty()) throw new IllegalArgumentException("Vui lòng chọn ít nhất một ghế.");
        var unique = new TreeSet<String>(Comparator.comparingInt(seat ->
            (seat.charAt(0) - 'A') * SEATS_PER_ROW + seatNumber(seat)));
        for(String seat:ghe) {
            if(!seat.matches("[A-Z][1-9][0-9]?") || seat.charAt(0) > LAST_ROW ||
                seatNumber(seat) > SEATS_PER_ROW || !unique.add(seat)) {
                throw new IllegalArgumentException("Danh sách ghế không hợp lệ.");
            }
        }
        ghe=List.copyOf(unique);
    }
    private static int seatNumber(String seat) {return Integer.parseInt(seat.substring(1));}
    public BigDecimal tinhTien() {return suat.gia().multiply(BigDecimal.valueOf(ghe.size()));}
    public void kiemTra(Set<String> sold) {
        var conflicts=new ArrayList<>(ghe);
        conflicts.retainAll(sold);
        if(!conflicts.isEmpty()) throw new IllegalArgumentException("Ghế đã bán: "+String.join(", ",conflicts)+".");
    }
}
