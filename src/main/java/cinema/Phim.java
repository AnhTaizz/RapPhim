package cinema;
public class Phim {
    public final int id;
    public final String tenPhim, theLoai, moTa;
    public final int thoiLuong;
    public Phim(int id,String ten,String loai,int phut,String moTa) {
        this.id=id; this.tenPhim=ten; this.theLoai=loai; this.thoiLuong=phut; this.moTa=moTa;
    }
}
