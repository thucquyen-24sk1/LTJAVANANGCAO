package SCHEMA;

public class KhachHang {
    private int MaKH;
    private String TenKH;
    private String Email;
    private String DienThoai;
    private double TongChiTieu;

    public KhachHang() {}

    public KhachHang(int MaKH, String TenKH, String Email, String DienThoai, double TongChiTieu) {
        this.MaKH = MaKH;
        this.TenKH = TenKH;
        this.Email = Email;
        this.DienThoai = DienThoai;
        this.TongChiTieu = TongChiTieu;
    }

    // Các hàm Get/Set
    public int getMaKH() { return MaKH; }
    public void setMaKH(int MaKH) { this.MaKH = MaKH; }
    public String getTenKH() { return TenKH; }
    public void setTenKH(String TenKH) { this.TenKH = TenKH; }
    public String getEmail() { return Email; }
    public void setEmail(String Email) { this.Email = Email; }
    public String getDienThoai() { return DienThoai; }
    public void setDienThoai(String DienThoai) { this.DienThoai = DienThoai; }
    public double getTongChiTieu() { return TongChiTieu; }
    public void setTongChiTieu(double TongChiTieu) { this.TongChiTieu = TongChiTieu; }
}