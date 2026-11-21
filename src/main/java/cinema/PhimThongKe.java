package cinema;
import java.math.BigDecimal;
public final class PhimThongKe extends Phim {
    private BigDecimal doanhThu;
    public PhimThongKe(int id,String ten,String loai,int phut,String moTa) {super(id,ten,loai,phut,moTa);}
    public void setDoanhThu(BigDecimal value) {doanhThu=value;}
    public BigDecimal getDoanhThu() {return doanhThu;}
}
