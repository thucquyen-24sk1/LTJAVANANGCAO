-- ============================================================
--   HE THONG QUAN LY TIEM GIAT - SQL Server Database Schema
--   Ten bang va ten cot su dung tieng Viet khong dau
--   (SQL Server khuyen nghi khong dung ky tu dac biet trong ten)
--
--   Bao gom  : KhachHang, DonHang, DichVu, NhanVien,
--              CaLamViec, ThanhToan, HoaDon, KhoHang
--   Luu y    : Khach hang KHONG tu dung app
--              Chi nhan vien tao don va xuat hoa don
--   Vai tro  : Admin, ChuTiemGiat, NhanVienGiatUi, ThuNgan
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyTiemGiat')
    DROP DATABASE QuanLyTiemGiat;
GO

CREATE DATABASE QuanLyTiemGiat;
GO

USE QuanLyTiemGiat;
GO

-- ============================================================
-- 1. KHACH HANG
--    Nhan vien tao ho so khach, khach khong tu dung app
-- ============================================================
CREATE TABLE KhachHang (
    MaKhachHang     INT             IDENTITY(1,1)   PRIMARY KEY,
    HoTen           NVARCHAR(100)   NOT NULL,
    SoDienThoai     VARCHAR(15)     NOT NULL        UNIQUE,
    Email           VARCHAR(100)                    UNIQUE,
    DiaChi          NVARCHAR(255),
    DiemTichLuy     INT             NOT NULL        DEFAULT 0,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT CHK_KhachHang_SDT    CHECK (SoDienThoai LIKE '[0-9]%' AND LEN(SoDienThoai) BETWEEN 9 AND 15),
    CONSTRAINT CHK_KhachHang_Email  CHECK (Email LIKE '%_@_%._%'),
    CONSTRAINT CHK_KhachHang_Diem   CHECK (DiemTichLuy >= 0)
);
GO

-- ============================================================
-- 2. VAI TRO NHAN VIEN
-- ============================================================
CREATE TABLE VaiTro (
    MaVaiTro        INT             IDENTITY(1,1)   PRIMARY KEY,
    TenVaiTro       NVARCHAR(100)   NOT NULL        UNIQUE,
    MoTa            NVARCHAR(255)
);
GO

INSERT INTO VaiTro (TenVaiTro, MoTa) VALUES
    (N'Admin',              N'Toan quyen quan ly he thong, them/xoa tai khoan nhan vien'),
    (N'Chu tiem giat',      N'Quan ly tiem, xem doanh thu, bao cao, quan ly ca lam viec'),
    (N'Nhan vien giat ui',  N'Nhan do, xu ly don hang, cap nhat trang thai giat, quan ly kho'),
    (N'Thu ngan',           N'Tao don hang, lap hoa don, ghi nhan thanh toan, in hoa don cho khach');
GO

-- ============================================================
-- 3. NHAN VIEN
-- ============================================================
CREATE TABLE NhanVien (
    MaNhanVien      INT             IDENTITY(1,1)   PRIMARY KEY,
    MaVaiTro        INT             NOT NULL,
    HoTen           NVARCHAR(100)   NOT NULL,
    SoDienThoai     VARCHAR(15)     NOT NULL        UNIQUE,
    Email           VARCHAR(100)                    UNIQUE,
    NgayVaoLam      DATE            NOT NULL        DEFAULT CAST(GETDATE() AS DATE),
    LuongCoBan      DECIMAL(12,2)   NOT NULL,
    DangLamViec     BIT             NOT NULL        DEFAULT 1,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT FK_NhanVien_VaiTro   FOREIGN KEY (MaVaiTro)      REFERENCES VaiTro(MaVaiTro),
    CONSTRAINT CHK_NhanVien_SDT     CHECK (SoDienThoai LIKE '[0-9]%' AND LEN(SoDienThoai) BETWEEN 9 AND 15),
    CONSTRAINT CHK_NhanVien_Email   CHECK (Email LIKE '%_@_%._%'),
    CONSTRAINT CHK_NhanVien_Luong   CHECK (LuongCoBan > 0)
);
GO

-- ============================================================
-- 4. CA LAM VIEC
-- ============================================================
CREATE TABLE CaLamViec (
    MaCa            INT             IDENTITY(1,1)   PRIMARY KEY,
    TenCa           NVARCHAR(50)    NOT NULL        UNIQUE,
    GioBatDau       TIME            NOT NULL,
    GioKetThuc      TIME            NOT NULL,

    CONSTRAINT CHK_CaLamViec_Gio    CHECK (GioKetThuc > GioBatDau)
);
GO

INSERT INTO CaLamViec (TenCa, GioBatDau, GioKetThuc) VALUES
    (N'Ca sang',    '06:00', '14:00'),
    (N'Ca chieu',   '14:00', '22:00')
GO

-- ============================================================
-- 5. PHAN CONG CA LAM VIEC
-- ============================================================
CREATE TABLE PhanCongCa (
    MaPhanCong      INT     IDENTITY(1,1)   PRIMARY KEY,
    MaNhanVien      INT     NOT NULL,
    MaCa            INT     NOT NULL,
    NgayLamViec     DATE    NOT NULL,
    CoDiLam         BIT     NOT NULL        DEFAULT 0,

    CONSTRAINT FK_PhanCongCa_NhanVien   FOREIGN KEY (MaNhanVien)    REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT FK_PhanCongCa_Ca         FOREIGN KEY (MaCa)          REFERENCES CaLamViec(MaCa),
    CONSTRAINT UQ_PhanCong_NV_Ca_Ngay   UNIQUE (MaNhanVien, MaCa, NgayLamViec)
);
GO

-- ============================================================
-- 6. DANH MUC DICH VU
-- ============================================================
CREATE TABLE DanhMucDichVu (
    MaDanhMuc       INT             IDENTITY(1,1)   PRIMARY KEY,
    TenDanhMuc      NVARCHAR(100)   NOT NULL        UNIQUE,
    MoTa            NVARCHAR(255)
);
GO

INSERT INTO DanhMucDichVu (TenDanhMuc, MoTa) VALUES
    (N'Giat & Gap',     N'Giat thuong va gap quan ao'),
    (N'Giat kho',       N'Giat kho bang hoa chat cho do vai nhay cam'),
    (N'Ui do',          N'Dich vu ui hoi nuoc'),
    (N'Giat nhanh',     N'Dich vu hoan tra trong ngay'),
    (N'Chan ga goi',    N'Giat chan, ga, goi, dem');
GO

-- ============================================================
-- 7. DICH VU
-- ============================================================
CREATE TABLE DichVu (
    MaDichVu        INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDanhMuc       INT             NOT NULL,
    TenDichVu       NVARCHAR(150)   NOT NULL,
    DonViTinh       NVARCHAR(30)    NOT NULL,
    DonGia          DECIMAL(12,2)   NOT NULL,
    ThoiGianXuLy    INT             NOT NULL,
    DangHoatDong    BIT             NOT NULL        DEFAULT 1,

    CONSTRAINT FK_DichVu_DanhMuc    FOREIGN KEY (MaDanhMuc)     REFERENCES DanhMucDichVu(MaDanhMuc),
    CONSTRAINT CHK_DichVu_DonGia    CHECK (DonGia       > 0),
    CONSTRAINT CHK_DichVu_ThoiGian  CHECK (ThoiGianXuLy > 0)
);
GO

-- ============================================================
-- 8. DON HANG
--    Nhan vien tao don hang thay cho khach
-- ============================================================
CREATE TABLE DonHang (
    MaDonHang       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaKhachHang     INT             NOT NULL,
    MaNhanVien      INT             NOT NULL,
    NgayTaoDon      DATETIME        NOT NULL        DEFAULT GETDATE(),
    NgayTraDuKien   DATETIME,
    NgayHoanThanh   DATETIME,
    TrangThai       NVARCHAR(25)    NOT NULL        DEFAULT N'Cho xu ly',
    GhiChu          NVARCHAR(500),
    TongTien        DECIMAL(12,2)   NOT NULL        DEFAULT 0,
    TienGiam        DECIMAL(12,2)   NOT NULL        DEFAULT 0,
    ThanhTien       AS (TongTien - TienGiam)        PERSISTED,

    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (MaKhachHang)  REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_DonHang_NhanVien  FOREIGN KEY (MaNhanVien)    REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT CHK_DonHang_TrangThai CHECK (TrangThai IN (
                                        N'Cho xu ly',
                                        N'Dang giat',
                                        N'San sang lay',
                                        N'Hoan thanh',
                                        N'Da huy'
                                    )),
    CONSTRAINT CHK_DonHang_TongTien CHECK (TongTien  >= 0),
    CONSTRAINT CHK_DonHang_TienGiam CHECK (TienGiam  >= 0),
    CONSTRAINT CHK_DonHang_NgayTra  CHECK (NgayTraDuKien  IS NULL OR NgayTraDuKien  >= NgayTaoDon),
    CONSTRAINT CHK_DonHang_NgayHT   CHECK (NgayHoanThanh  IS NULL OR NgayHoanThanh  >= NgayTaoDon)
);
GO

-- ============================================================
-- 9. CHI TIET DON HANG
-- ============================================================
CREATE TABLE ChiTietDonHang (
    MaChiTiet       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDonHang       INT             NOT NULL,
    MaDichVu        INT             NOT NULL,
    SoLuong         DECIMAL(10,2)   NOT NULL,
    DonGiaThiDiem   DECIMAL(12,2)   NOT NULL,
    ThanhTien       AS (SoLuong * DonGiaThiDiem)    PERSISTED,

    CONSTRAINT FK_ChiTiet_DonHang   FOREIGN KEY (MaDonHang)     REFERENCES DonHang(MaDonHang)   ON DELETE CASCADE,
    CONSTRAINT FK_ChiTiet_DichVu    FOREIGN KEY (MaDichVu)      REFERENCES DichVu(MaDichVu),
    CONSTRAINT CHK_ChiTiet_SoLuong  CHECK (SoLuong        > 0),
    CONSTRAINT CHK_ChiTiet_DonGia   CHECK (DonGiaThiDiem  > 0)
);
GO

-- ============================================================
-- 10. PHUONG THUC THANH TOAN
-- ============================================================
CREATE TABLE PhuongThucThanhToan (
    MaPhuongThuc    INT             IDENTITY(1,1)   PRIMARY KEY,
    TenPhuongThuc   NVARCHAR(50)    NOT NULL        UNIQUE
);
GO

INSERT INTO PhuongThucThanhToan (TenPhuongThuc) VALUES
    (N'Tien mat'),
    (N'Chuyen khoan ngan hang'),
    (N'The tin dung'),
    (N'Vi dien tu'),
    (N'QRIS / QR Code');
GO

-- ============================================================
-- 11. HOA DON
--    Thu ngan lap va xuat hoa don cho khach
-- ============================================================
CREATE TABLE HoaDon (
    MaHoaDon        INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDonHang       INT             NOT NULL        UNIQUE,
    SoHoaDon        VARCHAR(30)     NOT NULL        UNIQUE,
    NgayLap         DATETIME        NOT NULL        DEFAULT GETDATE(),
    HanThanhToan    DATETIME        NOT NULL,
    TrangThai       NVARCHAR(25)    NOT NULL        DEFAULT N'Chua thanh toan',

    CONSTRAINT FK_HoaDon_DonHang    FOREIGN KEY (MaDonHang)     REFERENCES DonHang(MaDonHang),
    CONSTRAINT CHK_HoaDon_TrangThai CHECK (TrangThai IN (
                                        N'Chua thanh toan',
                                        N'Da thanh toan',
                                        N'Thanh toan mot phan',
                                        N'Da huy'
                                    )),
    CONSTRAINT CHK_HoaDon_HanTT    CHECK (HanThanhToan >= NgayLap)
);
GO

-- ============================================================
-- 12. THANH TOAN
--    Ho tro thanh toan nhieu lan
-- ============================================================
CREATE TABLE ThanhToan (
    MaThanhToan     INT             IDENTITY(1,1)   PRIMARY KEY,
    MaHoaDon        INT             NOT NULL,
    MaPhuongThuc    INT             NOT NULL,
    MaThuNgan       INT             NOT NULL,
    SoTienTra       DECIMAL(12,2)   NOT NULL,
    NgayThanhToan   DATETIME        NOT NULL        DEFAULT GETDATE(),
    MaGiaoDich      VARCHAR(100),
    GhiChu          NVARCHAR(255),

    CONSTRAINT FK_ThanhToan_HoaDon      FOREIGN KEY (MaHoaDon)      REFERENCES HoaDon(MaHoaDon),
    CONSTRAINT FK_ThanhToan_PhuongThuc  FOREIGN KEY (MaPhuongThuc)  REFERENCES PhuongThucThanhToan(MaPhuongThuc),
    CONSTRAINT FK_ThanhToan_ThuNgan     FOREIGN KEY (MaThuNgan)     REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT CHK_ThanhToan_SoTien     CHECK (SoTienTra > 0)
);
GO

-- ============================================================
-- 13. DANH MUC KHO HANG
-- ============================================================
CREATE TABLE DanhMucKho (
    MaDanhMucKho    INT             IDENTITY(1,1)   PRIMARY KEY,
    TenDanhMuc      NVARCHAR(100)   NOT NULL        UNIQUE,
    MoTa            NVARCHAR(255)
);
GO

INSERT INTO DanhMucKho (TenDanhMuc, MoTa) VALUES
    (N'Bot giat',       N'Cac loai bot giat va xa phong'),
    (N'Nuoc xa vai',    N'Nuoc xa lam mem vai'),
    (N'Bao bi',         N'Tui nilon, moc quan ao, hop dung'),
    (N'Thiet bi',       N'Phu tung va linh kien may giat'),
    (N'Hoa chat',       N'Hoa chat dung cho giat kho');
GO

-- ============================================================
-- 14. VAT TU KHO HANG
-- ============================================================
CREATE TABLE VatTuKho (
    MaVatTu         INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDanhMucKho    INT             NOT NULL,
    TenVatTu        NVARCHAR(150)   NOT NULL,
    DonViTinh       NVARCHAR(30)    NOT NULL,
    SoLuongTon      DECIMAL(12,2)   NOT NULL        DEFAULT 0,
    MucCanhBao      DECIMAL(12,2)   NOT NULL,
    DonGiaNhap      DECIMAL(12,2)   NOT NULL,
    TenNhaCungCap   NVARCHAR(150),
    SDTNhaCungCap   VARCHAR(15),
    LanNhapCuoi     DATETIME,
    DangSuDung      BIT             NOT NULL        DEFAULT 1,

    CONSTRAINT FK_VatTu_DanhMucKho  FOREIGN KEY (MaDanhMucKho)  REFERENCES DanhMucKho(MaDanhMucKho),
    CONSTRAINT CHK_VatTu_SoLuong    CHECK (SoLuongTon   >= 0),
    CONSTRAINT CHK_VatTu_MucCB      CHECK (MucCanhBao   >= 0),
    CONSTRAINT CHK_VatTu_DonGia     CHECK (DonGiaNhap   >  0),
    CONSTRAINT CHK_VatTu_SDTNCC     CHECK (SDTNhaCungCap IS NULL OR LEN(SDTNhaCungCap) BETWEEN 9 AND 15)
);
GO

-- ============================================================
-- 15. GIAO DICH KHO HANG
-- ============================================================
CREATE TABLE GiaoDichKho (
    MaGiaoDich      INT             IDENTITY(1,1)   PRIMARY KEY,
    MaVatTu         INT             NOT NULL,
    MaNhanVien      INT             NOT NULL,
    LoaiGiaoDich    NVARCHAR(15)    NOT NULL,
    SoLuong         DECIMAL(12,2)   NOT NULL,
    NgayGiaoDich    DATETIME        NOT NULL        DEFAULT GETDATE(),
    GhiChu          NVARCHAR(255),

    CONSTRAINT FK_GiaoDichKho_VatTu     FOREIGN KEY (MaVatTu)       REFERENCES VatTuKho(MaVatTu),
    CONSTRAINT FK_GiaoDichKho_NhanVien  FOREIGN KEY (MaNhanVien)    REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT CHK_GiaoDichKho_Loai     CHECK (LoaiGiaoDich IN ('NHAP', 'XUAT', 'DIEU_CHINH')),
    CONSTRAINT CHK_GiaoDichKho_SoLuong  CHECK (SoLuong > 0)
);
GO

-- ============================================================
-- CHI MUC (INDEX)
-- ============================================================
CREATE INDEX IDX_DonHang_KhachHang      ON DonHang(MaKhachHang);
CREATE INDEX IDX_DonHang_TrangThai      ON DonHang(TrangThai);
CREATE INDEX IDX_DonHang_NgayTao        ON DonHang(NgayTaoDon);
CREATE INDEX IDX_ChiTiet_DonHang        ON ChiTietDonHang(MaDonHang);
CREATE INDEX IDX_ThanhToan_HoaDon       ON ThanhToan(MaHoaDon);
CREATE INDEX IDX_PhanCongCa_Ngay        ON PhanCongCa(NgayLamViec);
CREATE INDEX IDX_VatTuKho_DanhMuc       ON VatTuKho(MaDanhMucKho);
CREATE INDEX IDX_GiaoDichKho_VatTu      ON GiaoDichKho(MaVatTu);
GO

-- ============================================================
-- VIEW (KHUNG NHIN)
-- ============================================================

-- View 1: Tong quan don hang
CREATE VIEW vw_TongQuanDonHang AS
SELECT
    dh.MaDonHang,
    kh.HoTen            AS TenKhachHang,
    kh.SoDienThoai      AS SDTKhachHang,
    nv.HoTen            AS NhanVienTiepNhan,
    dh.NgayTaoDon,
    dh.NgayTraDuKien,
    dh.TrangThai,
    dh.TongTien,
    dh.TienGiam,
    dh.ThanhTien
FROM DonHang dh
JOIN KhachHang  kh ON dh.MaKhachHang = kh.MaKhachHang
JOIN NhanVien   nv ON dh.MaNhanVien   = nv.MaNhanVien;
GO

-- View 2: Vat tu sap het hang
CREATE VIEW vw_VatTuSapHet AS
SELECT
    vt.MaVatTu,
    dm.TenDanhMuc       AS DanhMuc,
    vt.TenVatTu,
    vt.SoLuongTon,
    vt.MucCanhBao,
    vt.DonViTinh,
    vt.TenNhaCungCap,
    vt.SDTNhaCungCap
FROM VatTuKho vt
JOIN DanhMucKho dm ON vt.MaDanhMucKho = dm.MaDanhMucKho
WHERE vt.SoLuongTon <= vt.MucCanhBao
  AND vt.DangSuDung  = 1;
GO

-- View 3: Tinh trang thanh toan hoa don
CREATE VIEW vw_TinhTrangHoaDon AS
SELECT
    hd.MaHoaDon,
    hd.SoHoaDon,
    dh.MaDonHang,
    kh.HoTen                                        AS TenKhachHang,
    dh.ThanhTien                                    AS TongTienDon,
    ISNULL(SUM(tt.SoTienTra), 0)                    AS DaThanhToan,
    dh.ThanhTien - ISNULL(SUM(tt.SoTienTra), 0)    AS ConLai,
    hd.TrangThai                                    AS TrangThaiHoaDon
FROM HoaDon hd
JOIN DonHang    dh ON hd.MaDonHang    = dh.MaDonHang
JOIN KhachHang  kh ON dh.MaKhachHang = kh.MaKhachHang
LEFT JOIN ThanhToan tt ON hd.MaHoaDon = tt.MaHoaDon
GROUP BY hd.MaHoaDon, hd.SoHoaDon, dh.MaDonHang,
         kh.HoTen, dh.ThanhTien, hd.TrangThai;
GO

-- ============================================================
-- STORED PROCEDURES (THU TUC LUU TRU)
-- ============================================================

-- SP1: Tao don hang moi
CREATE PROCEDURE sp_TaoDonHang
    @MaKhachHang    INT,
    @MaNhanVien     INT,
    @NgayTraDuKien  DATETIME,
    @GhiChu         NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO DonHang (MaKhachHang, MaNhanVien, NgayTraDuKien, GhiChu)
    VALUES (@MaKhachHang, @MaNhanVien, @NgayTraDuKien, @GhiChu);
    SELECT SCOPE_IDENTITY() AS MaDonHangMoi;
END;
GO

-- SP2: Them dich vu vao don va tu dong cap nhat tong tien
CREATE PROCEDURE sp_ThemDichVuVaoDon
    @MaDonHang  INT,
    @MaDichVu   INT,
    @SoLuong    DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DonGia DECIMAL(12,2);
    SELECT @DonGia = DonGia FROM DichVu WHERE MaDichVu = @MaDichVu;

    IF @DonGia IS NULL
    BEGIN
        RAISERROR(N'Khong tim thay dich vu.', 16, 1); RETURN;
    END

    INSERT INTO ChiTietDonHang (MaDonHang, MaDichVu, SoLuong, DonGiaThiDiem)
    VALUES (@MaDonHang, @MaDichVu, @SoLuong, @DonGia);

    UPDATE DonHang
    SET TongTien = (
        SELECT ISNULL(SUM(ThanhTien), 0)
        FROM ChiTietDonHang
        WHERE MaDonHang = @MaDonHang
    )
    WHERE MaDonHang = @MaDonHang;
END;
GO

-- SP3: Ghi nhan thanh toan va tu dong cap nhat trang thai hoa don
CREATE PROCEDURE sp_GhiNhanThanhToan
    @MaHoaDon       INT,
    @MaPhuongThuc   INT,
    @MaThuNgan      INT,
    @SoTienTra      DECIMAL(12,2),
    @MaGiaoDich     VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ThanhToan (MaHoaDon, MaPhuongThuc, MaThuNgan, SoTienTra, MaGiaoDich)
    VALUES (@MaHoaDon, @MaPhuongThuc, @MaThuNgan, @SoTienTra, @MaGiaoDich);

    DECLARE @TongTienDon DECIMAL(12,2), @DaThanhToan DECIMAL(12,2);

    SELECT @TongTienDon = dh.ThanhTien
    FROM HoaDon hd
    JOIN DonHang dh ON hd.MaDonHang = dh.MaDonHang
    WHERE hd.MaHoaDon = @MaHoaDon;

    SELECT @DaThanhToan = ISNULL(SUM(SoTienTra), 0)
    FROM ThanhToan
    WHERE MaHoaDon = @MaHoaDon;

    UPDATE HoaDon
    SET TrangThai = CASE
        WHEN @DaThanhToan >= @TongTienDon   THEN N'Da thanh toan'
        WHEN @DaThanhToan  > 0              THEN N'Thanh toan mot phan'
        ELSE N'Chua thanh toan'
    END
    WHERE MaHoaDon = @MaHoaDon;
END;
GO

-- SP4: Cap nhat kho hang (nhap / xuat / dieu chinh)
CREATE PROCEDURE sp_CapNhatKho
    @MaVatTu        INT,
    @MaNhanVien     INT,
    @LoaiGiaoDich   NVARCHAR(15),
    @SoLuong        DECIMAL(12,2),
    @GhiChu         NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @LoaiGiaoDich NOT IN ('NHAP', 'XUAT', 'DIEU_CHINH')
    BEGIN
        RAISERROR(N'Loai giao dich khong hop le.', 16, 1); RETURN;
    END

    IF @LoaiGiaoDich = 'XUAT'
    BEGIN
        DECLARE @TonHienTai DECIMAL(12,2);
        SELECT @TonHienTai = SoLuongTon FROM VatTuKho WHERE MaVatTu = @MaVatTu;
        IF @TonHienTai < @SoLuong
        BEGIN
            RAISERROR(N'Ton kho khong du de xuat hang.', 16, 1); RETURN;
        END
    END

    INSERT INTO GiaoDichKho (MaVatTu, MaNhanVien, LoaiGiaoDich, SoLuong, GhiChu)
    VALUES (@MaVatTu, @MaNhanVien, @LoaiGiaoDich, @SoLuong, @GhiChu);

    UPDATE VatTuKho
    SET SoLuongTon = CASE
            WHEN @LoaiGiaoDich = 'NHAP'         THEN SoLuongTon + @SoLuong
            WHEN @LoaiGiaoDich = 'XUAT'         THEN SoLuongTon - @SoLuong
            WHEN @LoaiGiaoDich = 'DIEU_CHINH'   THEN @SoLuong
        END,
        LanNhapCuoi = CASE
            WHEN @LoaiGiaoDich = 'NHAP' THEN GETDATE()
            ELSE LanNhapCuoi
        END
    WHERE MaVatTu = @MaVatTu;
END;
GO

PRINT N'Co so du lieu QuanLyTiemGiat da duoc tao thanh cong!';
GO