package cinema;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

public record VeMua(SuatChieu suat,List<String> ghe) {
    public record SuatChieu(int id,String phim,String loai,int phut,LocalDateTime gio,String phong,BigDecimal gia) {}
    public VeMua {
        if(ghe==null || ghe.isEmpty()) throw new IllegalArgumentException("Vui lòng chọn ít nhất một ghế.");
        var unique=new TreeSet<String>();
        for(String seat:ghe) {
            if(!seat.matches("[A-F][1-8]") || !unique.add(seat)) throw new IllegalArgumentException("Danh sách ghế không hợp lệ.");
        }
        ghe=List.copyOf(unique);
    }
    public BigDecimal tinhTien() {return suat.gia().multiply(BigDecimal.valueOf(ghe.size()));}
    public void kiemTra(Set<String> sold) {
        var conflicts=new ArrayList<>(ghe);
        conflicts.retainAll(sold);
        if(!conflicts.isEmpty()) throw new IllegalArgumentException("Ghế đã bán: "+String.join(", ",conflicts)+".");
    }
}
