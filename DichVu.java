package SCHEMA;

public class DichVu {
    private String MaDV;
    private String TenDV;
    private String DonViTinh;
    private double GiaTien;

    public DichVu() {}

    public DichVu(String MaDV, String TenDV, String DonViTinh, double GiaTien) {
        this.MaDV = MaDV;
        this.TenDV = TenDV;
        this.DonViTinh = DonViTinh;
        this.GiaTien = GiaTien;
    }

    public String getMaDV() { return MaDV; }
    public void setMaDV(String MaDV) { this.MaDV = MaDV; }
    public String getTenDV() { return TenDV; }
    public void setTenDV(String TenDV) { this.TenDV = TenDV; }
    public String getDonViTinh() { return DonViTinh; }
    public void setDonViTinh(String DonViTinh) { this.DonViTinh = DonViTinh; }
    public double getGiaTien() { return GiaTien; }
    public void setGiaTien(double GiaTien) { this.GiaTien = GiaTien; }
}