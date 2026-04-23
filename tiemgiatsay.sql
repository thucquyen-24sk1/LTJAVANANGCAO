-- ============================================================
--   HE THONG QUAN LY TIEM GIAT SAY - SQL Server
--   Phac biet theo thuc te quan ly tren Sapo:
--     - Danh sach don hang    : don da giat xong (co ma HD...)
--     - Don hang nhap (nhap)  : don chua lam xong, co the sua
--     - Khach hang            : tu dong tao khi co don hang nhap
--     - Khuyen mai            : discount % dang ap dung
--     - So quy                : thu/chi, tong doanh thu theo ky
--     - Bao cao               : tong quan theo thang/quy
--     - San pham / Bang gia   : dich vu + bang gia POS
--   Nguon don: Admin (nhan vien tao don tren he thong)
--   Chi nhanh : CN GOC (53 Phan Nhu), CN THEM (132 Dung Si Thanh Khe)
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TiemGiatSay')
    DROP DATABASE TiemGiatSay;
GO

CREATE DATABASE TiemGiatSay;
GO

USE TiemGiatSay;
GO

-- ============================================================
-- 1. CHI NHANH
--    CN GOC (53 Phan Nhu) | CN THEM (132 Dung Si Thanh Khe)
-- ============================================================
CREATE TABLE ChiNhanh (
    MaChiNhanh      INT             IDENTITY(1,1)   PRIMARY KEY,
    TenChiNhanh     NVARCHAR(150)   NOT NULL,
    DiaChi          NVARCHAR(255)   NOT NULL,
    SoDienThoai     VARCHAR(20),
    TrangThai       BIT             NOT NULL        DEFAULT 1,  -- 1: Dang hoat dong
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE()
);
GO

INSERT INTO ChiNhanh (TenChiNhanh, DiaChi) VALUES
    (N'Chi nhanh goc',  N'53 Phan Nhu'),
    (N'Chi nhanh them', N'132 Dung Si Thanh Khe');
GO

-- ============================================================
-- 2. NHAN VIEN (Nguon don: Admin = nhan vien tao don)
-- ============================================================
CREATE TABLE NhanVien (
    MaNhanVien      INT             IDENTITY(1,1)   PRIMARY KEY,
    MaChiNhanh      INT             NOT NULL,
    HoTen           NVARCHAR(100)   NOT NULL,
    TenDangNhap     VARCHAR(50)     NOT NULL        UNIQUE,
    VaiTro          NVARCHAR(50)    NOT NULL        DEFAULT N'Admin',
    SoDienThoai     VARCHAR(20),
    Email           VARCHAR(100),
    DangLamViec     BIT             NOT NULL        DEFAULT 1,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT FK_NhanVien_ChiNhanh FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT CHK_NhanVien_VaiTro  CHECK (VaiTro IN (N'Admin', N'ChuTiem', N'NhanVien', N'ThuNgan'))
);
GO

-- Nhan vien mac dinh (tuong ung nguon don "Admin" trong Sapo)
INSERT INTO NhanVien (MaChiNhanh, HoTen, TenDangNhap, VaiTro) VALUES
    (1, N'Thi Hanh', 'hanh', N'Admin');
GO

-- ============================================================
-- 3. KHACH HANG
--    Tu dong tao khi nhan vien nhap don hang nhap
--    Ten khach hang = ten + so dien thoai + gio (vi du: "khoa 676 07:53")
-- ============================================================
CREATE TABLE KhachHang (
    MaKhachHang     INT             IDENTITY(1,1)   PRIMARY KEY,
    TenKhachHang    NVARCHAR(150)   NOT NULL,           -- vi du: "khoa 676 07:53"
    SoDienThoai     VARCHAR(20),
    Email           VARCHAR(100),
    DiaChi          NVARCHAR(255),
    DiemTichLuy     INT             NOT NULL        DEFAULT 0,
    TongChiTieu     DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),
    TrangThai       BIT             NOT NULL        DEFAULT 1,

    CONSTRAINT CHK_KhachHang_Diem   CHECK (DiemTichLuy  >= 0),
    CONSTRAINT CHK_KhachHang_Chi    CHECK (TongChiTieu  >= 0)
);
GO

-- ============================================================
-- 4. NHOM KHACH HANG
-- ============================================================
CREATE TABLE NhomKhachHang (
    MaNhom          INT             IDENTITY(1,1)   PRIMARY KEY,
    TenNhom         NVARCHAR(100)   NOT NULL        UNIQUE,
    MoTa            NVARCHAR(255),
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE()
);
GO

CREATE TABLE KhachHang_Nhom (
    MaKhachHang     INT NOT NULL,
    MaNhom          INT NOT NULL,
    PRIMARY KEY (MaKhachHang, MaNhom),
    CONSTRAINT FK_KHNhom_KH     FOREIGN KEY (MaKhachHang)   REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_KHNhom_Nhom   FOREIGN KEY (MaNhom)        REFERENCES NhomKhachHang(MaNhom)
);
GO

-- ============================================================
-- 5. DANH MUC SAN PHAM (Loai dich vu)
--    Vi du: Giat kho, Giat hap, Ao da giat kho...
-- ============================================================
CREATE TABLE DanhMucSanPham (
    MaDanhMuc       INT             IDENTITY(1,1)   PRIMARY KEY,
    TenDanhMuc      NVARCHAR(100)   NOT NULL,
    MaDanhMucCha    INT,                                        -- Danh muc cha (neu co)
    MoTa            NVARCHAR(255),
    TrangThai       BIT             NOT NULL        DEFAULT 1,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT FK_DanhMuc_Cha   FOREIGN KEY (MaDanhMucCha) REFERENCES DanhMucSanPham(MaDanhMuc)
);
GO

-- ============================================================
-- 6. SAN PHAM (Dich vu giat)
--    Vi du: GIAT KHO, GIAT HAP, AO DA GIAT KHO PHU BONG...
--    Don vi tinh: KG
--    Loai san pham: Dich vu
-- ============================================================
CREATE TABLE SanPham (
    MaSanPham       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDanhMuc       INT,
    TenSanPham      NVARCHAR(200)   NOT NULL,
    MaSKU           VARCHAR(50),                                -- Vi du: AQ03
    MaVach          VARCHAR(100),
    DonViTinh       NVARCHAR(30)    NOT NULL        DEFAULT N'KG',
    MoTa            NVARCHAR(MAX),
    LoaiSanPham     NVARCHAR(50)    NOT NULL        DEFAULT N'Dich vu',
    DangHoatDong    BIT             NOT NULL        DEFAULT 1,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT FK_SanPham_DanhMuc   FOREIGN KEY (MaDanhMuc) REFERENCES DanhMucSanPham(MaDanhMuc),
    CONSTRAINT CHK_SanPham_Loai     CHECK (LoaiSanPham IN (N'Dich vu', N'San pham'))
);
GO

-- Du lieu mau san pham thuc te
INSERT INTO SanPham (TenSanPham, MaSKU, DonViTinh, LoaiSanPham) VALUES
    (N'GIAT KHO',                           'GK01',     N'KG',  N'Dich vu'),
    (N'GIAT KHO',                           'GK02',     N'KG',  N'Dich vu'),
    (N'GIAT HAP',                           'GH01',     N'KG',  N'Dich vu'),
    (N'GIAT HAP',                           'GH02',     N'KG',  N'Dich vu'),
    (N'AO DA GIAT KHO PHU BONG- SIZE LON',  'AQ01',     N'Cai', N'Dich vu'),
    (N'GIAT KHO BANG DUNG MOI',             'GK03',     N'KG',  N'Dich vu'),
    (N'AO DA GIAT KHO (PHU DUONG BONG)',    'AQ02',     N'Cai', N'Dich vu'),
    (N'GIAT KHO AO DA- KHONG PHU BONG',    'AQ03',     N'KG',  N'Dich vu');
GO

-- ============================================================
-- 7. BANG GIA (POS)
--    Hien tai co 1 bang gia "POS" dang ap dung
-- ============================================================
CREATE TABLE BangGia (
    MaBangGia       INT             IDENTITY(1,1)   PRIMARY KEY,
    TenBangGia      NVARCHAR(100)   NOT NULL,
    MaCode          VARCHAR(50),                                -- Vi du: CTL632505
    DieuChinhGia    NVARCHAR(100),
    DangApDung      BIT             NOT NULL        DEFAULT 1,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE()
);
GO

INSERT INTO BangGia (TenBangGia, MaCode, DangApDung) VALUES
    (N'POS', 'CTL632505', 1);
GO

CREATE TABLE ChiTietBangGia (
    MaChiTietBG     INT             IDENTITY(1,1)   PRIMARY KEY,
    MaBangGia       INT             NOT NULL,
    MaSanPham       INT             NOT NULL,
    GiaGoc          DECIMAL(12,2)   NOT NULL,
    GiaSanPham      DECIMAL(12,2)   NOT NULL,       -- Gia ap dung thuc te
    NgayApDung      DATE,
    NgayKetThuc     DATE,

    CONSTRAINT FK_CTBG_BangGia      FOREIGN KEY (MaBangGia)     REFERENCES BangGia(MaBangGia),
    CONSTRAINT FK_CTBG_SanPham      FOREIGN KEY (MaSanPham)     REFERENCES SanPham(MaSanPham),
    CONSTRAINT CHK_CTBG_GiaGoc      CHECK (GiaGoc       > 0),
    CONSTRAINT CHK_CTBG_GiaSP       CHECK (GiaSanPham   > 0)
);
GO

-- Du lieu mau bang gia POS (tuong ung anh 5)
INSERT INTO ChiTietBangGia (MaBangGia, MaSanPham, GiaGoc, GiaSanPham) VALUES
    (1, 1, 100000, 100000),  -- GIAT KHO
    (1, 2, 100000, 100000),  -- GIAT KHO
    (1, 3,  50000,  50000),  -- GIAT HAP
    (1, 4, 120000, 120000);  -- GIAT HAP
GO

-- ============================================================
-- 8. KHUYEN MAI
--    Hien tai: "TRI AN" - Giam 5% cho toan bo don hang
--    Bat dau: 30/12/2025, khong co ngay ket thuc
-- ============================================================
CREATE TABLE KhuyenMai (
    MaKhuyenMai     INT             IDENTITY(1,1)   PRIMARY KEY,
    TenKhuyenMai    NVARCHAR(100)   NOT NULL,
    MoTa            NVARCHAR(255),
    LoaiKhuyenMai   NVARCHAR(50)    NOT NULL,       -- 'PhanTram' | 'SoTien'
    GiaTriGiam      DECIMAL(10,2)   NOT NULL,        -- % hoac so tien giam
    DieuKienApDung  NVARCHAR(255),
    NgayBatDau      DATETIME        NOT NULL,
    NgayKetThuc     DATETIME,                        -- NULL = khong gioi han
    TrangThai       NVARCHAR(20)    NOT NULL        DEFAULT N'DangApDung',
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT CHK_KM_Loai     CHECK (LoaiKhuyenMai IN (N'PhanTram', N'SoTien')),
    CONSTRAINT CHK_KM_GiaTri   CHECK (GiaTriGiam > 0),
    CONSTRAINT CHK_KM_TrangThai CHECK (TrangThai IN (N'DangApDung', N'ChuaApDung', N'NgungApDung')),
    CONSTRAINT CHK_KM_Ngay     CHECK (NgayKetThuc IS NULL OR NgayKetThuc >= NgayBatDau)
);
GO

-- Du lieu khuyen mai thuc te
INSERT INTO KhuyenMai (TenKhuyenMai, MoTa, LoaiKhuyenMai, GiaTriGiam, NgayBatDau, TrangThai) VALUES
    (N'TRI AN', N'Giam 5% cho toan bo don hang', N'PhanTram', 5, '2025-12-30 16:50', N'DangApDung');
GO

-- ============================================================
-- 9. DON HANG NHAP (Draft Orders)
--    = Don hang chua lam xong, co the sua va thay doi
--    Ma: #D6022, #D6029, #D6030...
--    Trang thai: "Chua hoan thanh"
-- ============================================================
CREATE TABLE DonHangNhap (
    MaDonNhap       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDonNhapHienThi VARCHAR(20)    NOT NULL        UNIQUE,     -- Vi du: #D6038
    MaChiNhanh      INT             NOT NULL,
    MaKhachHang     INT,
    MaNhanVien      INT             NOT NULL,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        NOT NULL        DEFAULT GETDATE(),
    TrangThai       NVARCHAR(30)    NOT NULL        DEFAULT N'Chua hoan thanh',
    GhiChu          NVARCHAR(500),
    TongTien        DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TienGiam        DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    ThanhTien       AS (TongTien - TienGiam)        PERSISTED,

    CONSTRAINT FK_DHNhap_ChiNhanh   FOREIGN KEY (MaChiNhanh)   REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT FK_DHNhap_KhachHang  FOREIGN KEY (MaKhachHang)  REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_DHNhap_NhanVien   FOREIGN KEY (MaNhanVien)    REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT CHK_DHNhap_TrangThai CHECK (TrangThai IN (N'Chua hoan thanh', N'Da hoan thanh', N'Da huy'))
);
GO

CREATE TABLE ChiTietDonHangNhap (
    MaChiTiet       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDonNhap       INT             NOT NULL,
    MaSanPham       INT             NOT NULL,
    SoLuong         DECIMAL(10,2)   NOT NULL,
    DonGia          DECIMAL(12,2)   NOT NULL,
    ThanhTien       AS (SoLuong * DonGia)           PERSISTED,

    CONSTRAINT FK_CTDHNhap_Don      FOREIGN KEY (MaDonNhap)    REFERENCES DonHangNhap(MaDonNhap)   ON DELETE CASCADE,
    CONSTRAINT FK_CTDHNhap_SP       FOREIGN KEY (MaSanPham)    REFERENCES SanPham(MaSanPham),
    CONSTRAINT CHK_CTDHNhap_SL      CHECK (SoLuong  > 0),
    CONSTRAINT CHK_CTDHNhap_DG      CHECK (DonGia   > 0)
);
GO

-- Du lieu mau don hang nhap (tuong ung anh 2)
INSERT INTO DonHangNhap (MaDonNhapHienThi, MaChiNhanh, MaNhanVien, NgayCapNhat, TrangThai, TongTien) VALUES
    ('#D6038', 1, 1, '2026-04-23 10:27', N'Chua hoan thanh', 11400),
    ('#D6037', 1, 1, '2026-04-23 09:57', N'Chua hoan thanh', 11400),
    ('#D6036', 1, 1, '2026-04-23 09:43', N'Chua hoan thanh', 11400),
    ('#D6035', 1, 1, '2026-04-23 09:28', N'Chua hoan thanh', 11400),
    ('#D6034', 1, 1, '2026-04-23 09:22', N'Chua hoan thanh', 80000),
    ('#D6032', 1, 1, '2026-04-23 09:03', N'Chua hoan thanh', 11400),
    ('#D6030', 1, 1, '2026-04-23 08:46', N'Chua hoan thanh', 34200),
    ('#D6029', 1, 1, '2026-04-23 08:22', N'Chua hoan thanh', 26600),
    ('#D6022', 1, 1, '2026-04-23 07:51', N'Chua hoan thanh', 11400);
GO

-- ============================================================
-- 10. DON HANG (Da giat xong / Chinh thuc)
--     Ma: HD6979, HD6978, HD6977...
--     Trang thai thanh toan: "Chua thanh toan" | "Da thanh toan"
--     Trang thai xu ly     : "Chua xu ly" | "Dang xu ly" | "Hoan thanh"
--     Nguon don            : Admin
--     Khong yeu cau van chuyen (pickup tai cua hang)
-- ============================================================
CREATE TABLE DonHang (
    MaDonHang       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDonHangHienThi VARCHAR(20)    NOT NULL        UNIQUE,     -- Vi du: HD6979
    MaChiNhanh      INT             NOT NULL,
    MaKhachHang     INT             NOT NULL,
    MaNhanVien      INT             NOT NULL,
    MaKhuyenMai     INT,                                        -- Khuyen mai ap dung (vi du TRI AN)
    NguonDon        NVARCHAR(50)    NOT NULL        DEFAULT N'Admin',
    NgayDatHang     DATETIME        NOT NULL        DEFAULT GETDATE(),
    NgayHoanThanh   DATETIME,
    TrangThaiThanhToan NVARCHAR(30) NOT NULL        DEFAULT N'Chua thanh toan',
    TrangThaiXuLy   NVARCHAR(30)    NOT NULL        DEFAULT N'Chua xu ly',
    VanChuyen       NVARCHAR(100)   NOT NULL        DEFAULT N'Khong yeu cau van chuyen',
    GhiChu          NVARCHAR(500),
    TongTienHang    DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TienGiam        DECIMAL(15,2)   NOT NULL        DEFAULT 0,  -- Tien giam tu khuyen mai
    ThanhTien       AS (TongTienHang - TienGiam)    PERSISTED,

    CONSTRAINT FK_DH_ChiNhanh   FOREIGN KEY (MaChiNhanh)       REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT FK_DH_KhachHang  FOREIGN KEY (MaKhachHang)      REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_DH_NhanVien   FOREIGN KEY (MaNhanVien)        REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT FK_DH_KhuyenMai  FOREIGN KEY (MaKhuyenMai)      REFERENCES KhuyenMai(MaKhuyenMai),
    CONSTRAINT CHK_DH_TrangThaiTT  CHECK (TrangThaiThanhToan IN (N'Chua thanh toan', N'Da thanh toan', N'Thanh toan mot phan')),
    CONSTRAINT CHK_DH_TrangThaiXL  CHECK (TrangThaiXuLy IN (N'Chua xu ly', N'Dang xu ly', N'Hoan thanh', N'Da huy')),
    CONSTRAINT CHK_DH_TongTien     CHECK (TongTienHang >= 0),
    CONSTRAINT CHK_DH_TienGiam     CHECK (TienGiam     >= 0)
);
GO

CREATE TABLE ChiTietDonHang (
    MaChiTiet       INT             IDENTITY(1,1)   PRIMARY KEY,
    MaDonHang       INT             NOT NULL,
    MaSanPham       INT             NOT NULL,
    TenSanPham      NVARCHAR(200)   NOT NULL,       -- Luu ten tai thoi diem dat hang
    MaSKU           VARCHAR(50),
    DonViTinh       NVARCHAR(30)    NOT NULL,
    SoLuong         DECIMAL(10,2)   NOT NULL,
    DonGia          DECIMAL(12,2)   NOT NULL,
    GiamGia         DECIMAL(12,2)   NOT NULL        DEFAULT 0,
    ThanhTien       AS (SoLuong * DonGia - GiamGia) PERSISTED,

    CONSTRAINT FK_CTDH_DonHang  FOREIGN KEY (MaDonHang)     REFERENCES DonHang(MaDonHang)   ON DELETE CASCADE,
    CONSTRAINT FK_CTDH_SanPham  FOREIGN KEY (MaSanPham)     REFERENCES SanPham(MaSanPham),
    CONSTRAINT CHK_CTDH_SL      CHECK (SoLuong  > 0),
    CONSTRAINT CHK_CTDH_DG      CHECK (DonGia   > 0),
    CONSTRAINT CHK_CTDH_Giam    CHECK (GiamGia  >= 0)
);
GO

-- Du lieu mau don hang (tuong ung anh 1 va anh 10)
INSERT INTO KhachHang (TenKhachHang) VALUES
    (N'khoa 676 07:53'), (N'trinh 025 8:20'), (N'dung 705 8:57'),
    (N'chi anh cf 07:55'), (N'duc 455/pp 7:50'), (N'hao 039 7:51'),
    (N'anh hanh 7:35'), (N'nhung 7h37'), (N'quang 295 20:34'),
    (N'thao 223 20:26'), (N'anh 819 19:59'), (N'Thanh 751 19:01');
GO

INSERT INTO DonHang (MaDonHangHienThi, MaChiNhanh, MaKhachHang, MaNhanVien, MaKhuyenMai,
                     NgayDatHang, TrangThaiThanhToan, TrangThaiXuLy, TongTienHang, TienGiam)
VALUES
    ('HD6979', 1, 1,  1, 1, '2026-04-23 10:45', N'Chua thanh toan', N'Chua xu ly', 42000, 2100),
    ('HD6978', 1, 2,  1, 1, '2026-04-23 10:44', N'Chua thanh toan', N'Chua xu ly', 36000, 1800),
    ('HD6977', 1, 3,  1, 1, '2026-04-23 10:40', N'Chua thanh toan', N'Chua xu ly', 26000, 1300),
    ('HD6976', 1, 4,  1, 1, '2026-04-23 10:35', N'Chua thanh toan', N'Chua xu ly', 30000, 1500),
    ('HD6975', 1, 5,  1, 1, '2026-04-23 10:09', N'Chua thanh toan', N'Chua xu ly', 50800, 2540),
    ('HD6974', 1, 6,  1, 1, '2026-04-23 09:52', N'Chua thanh toan', N'Chua xu ly', 26000, 1300),
    ('HD6973', 1, 7,  1, 1, '2026-04-23 09:52', N'Chua thanh toan', N'Chua xu ly', 28000, 1400),
    ('HD6972', 1, 8,  1, 1, '2026-04-23 09:43', N'Chua thanh toan', N'Chua xu ly', 32000, 1600),
    ('HD6971', 1, 9,  1, 1, '2026-04-23 09:27', N'Chua thanh toan', N'Chua xu ly', 41400, 2070),
    ('HD6969', 1, 10, 1, 1, '2026-04-23 09:21', N'Chua thanh toan', N'Chua xu ly', 45000, 2250),
    ('HD6968', 1, 11, 1, 1, '2026-04-23 08:06', N'Chua thanh toan', N'Chua xu ly', 35000, 1750),
    ('HD6967', 1, 12, 1, 1, '2026-04-23 07:58', N'Chua thanh toan', N'Chua xu ly', 45600, 2280);
GO

-- Chi tiet don hang mau: HD6979 (AO QUAN TU 3KG TRO LEN, 3.5kg x 12,000d)
INSERT INTO ChiTietDonHang (MaDonHang, MaSanPham, TenSanPham, MaSKU, DonViTinh, SoLuong, DonGia, GiamGia)
SELECT
    dh.MaDonHang,
    8, N'GIAT KHO AO DA- KHONG PHU BONG', 'AQ03', N'KG', 3.5, 12000, 2100
FROM DonHang dh WHERE dh.MaDonHangHienThi = 'HD6979';
GO

-- ============================================================
-- 11. PHUONG THUC THANH TOAN
-- ============================================================
CREATE TABLE PhuongThucThanhToan (
    MaPhuongThuc    INT             IDENTITY(1,1)   PRIMARY KEY,
    TenPhuongThuc   NVARCHAR(50)    NOT NULL        UNIQUE
);
GO

INSERT INTO PhuongThucThanhToan (TenPhuongThuc) VALUES
    (N'Tien mat'),
    (N'Chuyen khoan'),
    (N'Quet ma QR');
GO

-- ============================================================
-- 12. SO QUY (GIAO DICH THU CHI)
--     Thu tien ban hang | Chi phi hoat dong
--     Ma phieu: RVN05737, RVN05736...
--     Quy dau ky: 232,198,068d | Tong thu: 66,639,011d
--     Quy tien mat: 162,719,720d | Quy tien gui: 136,117,359d
-- ============================================================
CREATE TABLE SoQuy (
    MaGiaoDich      INT             IDENTITY(1,1)   PRIMARY KEY,
    MaPhieu         VARCHAR(20)     NOT NULL        UNIQUE,     -- Vi du: RVN05737
    MaChiNhanh      INT             NOT NULL,
    MaDonHang       INT,                                        -- Lien ket don hang neu la thu ban hang
    TenDoiTuong     NVARCHAR(150),                              -- Ten khach hang / nha cung cap
    LoaiQuy         NVARCHAR(20)    NOT NULL,                   -- 'TienMat' | 'TienGui'
    LoaiGiaoDich    NVARCHAR(10)    NOT NULL,                   -- 'Thu' | 'Chi'
    LyDoThuChi      NVARCHAR(150)   NOT NULL,                   -- Vi du: "Thu tien ban hang"
    MaChungTuGoc    VARCHAR(20),                                -- Vi du: HD6692
    SoTien          DECIMAL(15,2)   NOT NULL,
    MaPhuongThuc    INT,
    NgayGhiNhan     DATE            NOT NULL        DEFAULT CAST(GETDATE() AS DATE),
    GhiChu          NVARCHAR(255),

    CONSTRAINT FK_SoQuy_ChiNhanh    FOREIGN KEY (MaChiNhanh)   REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT FK_SoQuy_DonHang     FOREIGN KEY (MaDonHang)    REFERENCES DonHang(MaDonHang),
    CONSTRAINT FK_SoQuy_PT          FOREIGN KEY (MaPhuongThuc) REFERENCES PhuongThucThanhToan(MaPhuongThuc),
    CONSTRAINT CHK_SoQuy_Loai       CHECK (LoaiGiaoDich IN (N'Thu', N'Chi')),
    CONSTRAINT CHK_SoQuy_LoaiQuy    CHECK (LoaiQuy IN (N'TienMat', N'TienGui')),
    CONSTRAINT CHK_SoQuy_SoTien     CHECK (SoTien > 0)
);
GO

-- Du lieu mau so quy (tuong ung anh 8)
INSERT INTO SoQuy (MaPhieu, MaChiNhanh, TenDoiTuong, LoaiQuy, LoaiGiaoDich, LyDoThuChi, MaChungTuGoc, SoTien, NgayGhiNhan)
VALUES
    ('RVN05737', 1, N'Huong 704 07:55',  N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6692', 35340, '2026-04-23'),
    ('RVN05736', 1, N'Hieu 265 19:12',   N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6936', 76380, '2026-04-23'),
    ('RVN05735', 1, N'co van 16:35',     N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6957', 33250, '2026-04-23'),
    ('RVN05734', 1, N'tuan 119 19:54',   N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6964', 28500, '2026-04-23'),
    ('RVN05733', 1, N'Thuong 079 20h15', N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6902', 39900, '2026-04-22'),
    ('RVN05732', 1, NULL,                N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6961', 33750, '2026-04-22'),
    ('RVN05731', 1, N'a khoa 11:15',     N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6918', 33250, '2026-04-22'),
    ('RVN05730', 1, N'nga 923 07:45',    N'TienMat', N'Thu', N'Thu tien ban hang', 'HD6941', 56430, '2026-04-22');
GO

-- ============================================================
-- 13. KY QUY (Tong hop so du theo ky)
--     Luu tong hop dau ky / cuoi ky de bao cao so quy nhanh
-- ============================================================
CREATE TABLE KyQuy (
    MaKyQuy         INT             IDENTITY(1,1)   PRIMARY KEY,
    MaChiNhanh      INT             NOT NULL,
    TuNgay          DATE            NOT NULL,
    DenNgay         DATE            NOT NULL,
    SoDauKy         DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TongThu         DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TongChi         DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TonQuy          AS (SoDauKy + TongThu - TongChi) PERSISTED,
    QuyTienMat      DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    QuyTienGui      DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    NgayCapNhat     DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT FK_KyQuy_ChiNhanh    FOREIGN KEY (MaChiNhanh)   REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT CHK_KyQuy_Ngay       CHECK (DenNgay >= TuNgay)
);
GO

-- Du lieu ky quy thuc te (25/03 - 23/04/2026)
INSERT INTO KyQuy (MaChiNhanh, TuNgay, DenNgay, SoDauKy, TongThu, TongChi, QuyTienMat, QuyTienGui)
VALUES (1, '2026-03-25', '2026-04-23', 232198068, 66639011, 0, 162719720, 136117359);
GO

-- ============================================================
-- 14. BAO CAO DOANH THU (Tong quan bao cao theo thang/ky)
--     Vi du: 30 ngay qua doanh thu thuan 67,018,801d
--     1,293 don hang | Gia tri don TB: 51,832d
-- ============================================================
CREATE TABLE BaoCaoDoanhThu (
    MaBaoCao        INT             IDENTITY(1,1)   PRIMARY KEY,
    MaChiNhanh      INT             NOT NULL,
    LoaiBaoCao      NVARCHAR(50)    NOT NULL,       -- 'Theo ngay','Theo thang','Theo quy','Theo nam','Khoang thoi gian'
    TuNgay          DATE            NOT NULL,
    DenNgay         DATE            NOT NULL,
    TongDonHang     INT             NOT NULL        DEFAULT 0,
    DoanhThuThuan   DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TongGiamGia     DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TongTienThue    DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    TongThanhToan   DECIMAL(15,2)   NOT NULL        DEFAULT 0,
    GiaTriDonTB     AS (CASE WHEN TongDonHang > 0 THEN DoanhThuThuan / TongDonHang ELSE 0 END) PERSISTED,
    NgayTao         DATETIME        NOT NULL        DEFAULT GETDATE(),

    CONSTRAINT FK_BaoCao_ChiNhanh   FOREIGN KEY (MaChiNhanh)   REFERENCES ChiNhanh(MaChiNhanh),
    CONSTRAINT CHK_BaoCao_Loai      CHECK (LoaiBaoCao IN (N'Theo ngay', N'Theo thang', N'Theo quy', N'Theo nam', N'Khoang thoi gian')),
    CONSTRAINT CHK_BaoCao_Ngay      CHECK (DenNgay >= TuNgay)
);
GO

-- Du lieu bao cao mau (tuong ung anh 9)
INSERT INTO BaoCaoDoanhThu (MaChiNhanh, LoaiBaoCao, TuNgay, DenNgay, TongDonHang, DoanhThuThuan)
VALUES (1, N'Khoang thoi gian', '2026-03-25', '2026-04-23', 1293, 67018801);
GO

-- ============================================================
-- 15. CHI MUC (INDEX)
-- ============================================================
CREATE INDEX IDX_DonHang_KhachHang      ON DonHang(MaKhachHang);
CREATE INDEX IDX_DonHang_NguonDon       ON DonHang(NguonDon);
CREATE INDEX IDX_DonHang_NgayDat        ON DonHang(NgayDatHang);
CREATE INDEX IDX_DonHang_TrangThaiTT    ON DonHang(TrangThaiThanhToan);
CREATE INDEX IDX_DonHang_TrangThaiXL    ON DonHang(TrangThaiXuLy);
CREATE INDEX IDX_CTDH_DonHang           ON ChiTietDonHang(MaDonHang);
CREATE INDEX IDX_DHNhap_KhachHang       ON DonHangNhap(MaKhachHang);
CREATE INDEX IDX_SoQuy_NgayGhiNhan      ON SoQuy(NgayGhiNhan);
CREATE INDEX IDX_SoQuy_MaDonHang        ON SoQuy(MaDonHang);
CREATE INDEX IDX_KhachHang_Ten          ON KhachHang(TenKhachHang);
GO

-- ============================================================
-- 16. VIEWS (KHUNG NHIN)
-- ============================================================

-- View 1: Danh sach don hang (tuong tu trang "Danh sach don hang" tren Sapo)
CREATE VIEW vw_DanhSachDonHang AS
SELECT
    dh.MaDonHangHienThi     AS MaDonHang,
    dh.NgayDatHang,
    kh.TenKhachHang         AS KhachHang,
    dh.NguonDon,
    dh.ThanhTien,
    dh.TrangThaiThanhToan,
    dh.TrangThaiXuLy,
    cn.TenChiNhanh          AS ChiNhanh
FROM DonHang dh
JOIN KhachHang  kh ON dh.MaKhachHang  = kh.MaKhachHang
JOIN ChiNhanh   cn ON dh.MaChiNhanh   = cn.MaChiNhanh;
GO

-- View 2: Danh sach don hang nhap (chua lam xong)
CREATE VIEW vw_DonHangNhap AS
SELECT
    dhn.MaDonNhapHienThi    AS MaDonNhap,
    dhn.NgayCapNhat,
    kh.TenKhachHang         AS KhachHang,
    dhn.TrangThai,
    dhn.ThanhTien,
    cn.TenChiNhanh          AS ChiNhanh
FROM DonHangNhap dhn
LEFT JOIN KhachHang kh ON dhn.MaKhachHang = kh.MaKhachHang
JOIN ChiNhanh       cn ON dhn.MaChiNhanh  = cn.MaChiNhanh;
GO

-- View 3: Tong quan so quy theo ky
CREATE VIEW vw_TongQuanSoQuy AS
SELECT
    kq.MaChiNhanh,
    cn.TenChiNhanh,
    kq.TuNgay,
    kq.DenNgay,
    kq.SoDauKy,
    kq.TongThu,
    kq.TongChi,
    kq.TonQuy,
    kq.QuyTienMat,
    kq.QuyTienGui
FROM KyQuy kq
JOIN ChiNhanh cn ON kq.MaChiNhanh = cn.MaChiNhanh;
GO

-- View 4: Top san pham ban chay
CREATE VIEW vw_TopSanPhamBanChay AS
SELECT
    sp.TenSanPham,
    sp.MaSKU,
    sp.DonViTinh,
    COUNT(ctdh.MaChiTiet)           AS SoDonHang,
    SUM(ctdh.SoLuong)               AS TongSoLuong,
    SUM(ctdh.ThanhTien)             AS TongDoanhThu
FROM ChiTietDonHang ctdh
JOIN SanPham sp ON ctdh.MaSanPham = sp.MaSanPham
JOIN DonHang dh ON ctdh.MaDonHang = dh.MaDonHang
WHERE dh.TrangThaiXuLy <> N'Da huy'
GROUP BY sp.MaSanPham, sp.TenSanPham, sp.MaSKU, sp.DonViTinh;
GO

-- View 5: Bao cao doanh thu theo thoi gian (tong quan bao cao)
CREATE VIEW vw_DoanhThuTheoNgay AS
SELECT
    CAST(dh.NgayDatHang AS DATE)    AS Ngay,
    dh.MaChiNhanh,
    COUNT(dh.MaDonHang)             AS SoDonHang,
    SUM(dh.ThanhTien)               AS DoanhThuThuan,
    SUM(dh.TienGiam)                AS TongGiamGia
FROM DonHang dh
WHERE dh.TrangThaiXuLy <> N'Da huy'
GROUP BY CAST(dh.NgayDatHang AS DATE), dh.MaChiNhanh;
GO

-- ============================================================
-- 17. STORED PROCEDURES
-- ============================================================

-- SP1: Tao don hang nhap (khach hang tu dong tao neu chua co)
CREATE PROCEDURE sp_TaoDonHangNhap
    @TenKhachHang   NVARCHAR(150),
    @MaChiNhanh     INT,
    @MaNhanVien     INT,
    @GhiChu         NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiem tra / tao khach hang
    DECLARE @MaKhachHang INT;
    SELECT @MaKhachHang = MaKhachHang
    FROM KhachHang
    WHERE TenKhachHang = @TenKhachHang AND TrangThai = 1;

    IF @MaKhachHang IS NULL
    BEGIN
        INSERT INTO KhachHang (TenKhachHang) VALUES (@TenKhachHang);
        SET @MaKhachHang = SCOPE_IDENTITY();
    END

    -- Tao ma don nhap tu dong
    DECLARE @SoDonMoi INT;
    SELECT @SoDonMoi = ISNULL(MAX(CAST(SUBSTRING(MaDonNhapHienThi, 3, 10) AS INT)), 6000) + 1
    FROM DonHangNhap;

    DECLARE @MaHienThi VARCHAR(20) = '#D' + CAST(@SoDonMoi AS VARCHAR);

    INSERT INTO DonHangNhap (MaDonNhapHienThi, MaChiNhanh, MaKhachHang, MaNhanVien, GhiChu)
    VALUES (@MaHienThi, @MaChiNhanh, @MaKhachHang, @MaNhanVien, @GhiChu);

    SELECT SCOPE_IDENTITY() AS MaDonNhapMoi, @MaHienThi AS MaDonNhapHienThi;
END;
GO

-- SP2: Hoan thanh don nhap -> chuyen thanh don hang chinh thuc
CREATE PROCEDURE sp_HoanThanhDonNhap
    @MaDonNhap  INT,
    @MaKhuyenMai INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @MaKhachHang INT, @MaChiNhanh INT, @MaNhanVien INT,
                @TongTien DECIMAL(15,2), @TienGiam DECIMAL(15,2) = 0;

        SELECT @MaKhachHang = MaKhachHang, @MaChiNhanh = MaChiNhanh,
               @MaNhanVien = MaNhanVien, @TongTien = TongTien
        FROM DonHangNhap WHERE MaDonNhap = @MaDonNhap;

        -- Tinh giam gia khuyen mai
        IF @MaKhuyenMai IS NOT NULL
        BEGIN
            DECLARE @PhanTram DECIMAL(5,2);
            SELECT @PhanTram = GiaTriGiam
            FROM KhuyenMai
            WHERE MaKhuyenMai = @MaKhuyenMai AND LoaiKhuyenMai = N'PhanTram' AND TrangThai = N'DangApDung';
            IF @PhanTram IS NOT NULL
                SET @TienGiam = @TongTien * @PhanTram / 100;
        END

        -- Tao ma don hang chinh thuc
        DECLARE @SoDonMoi INT;
        SELECT @SoDonMoi = ISNULL(MAX(CAST(SUBSTRING(MaDonHangHienThi, 3, 10) AS INT)), 6000) + 1
        FROM DonHang;
        DECLARE @MaHienThi VARCHAR(20) = 'HD' + CAST(@SoDonMoi AS VARCHAR);

        INSERT INTO DonHang (MaDonHangHienThi, MaChiNhanh, MaKhachHang, MaNhanVien,
                             MaKhuyenMai, TongTienHang, TienGiam)
        VALUES (@MaHienThi, @MaChiNhanh, @MaKhachHang, @MaNhanVien,
                @MaKhuyenMai, @TongTien, @TienGiam);

        DECLARE @MaDonHangMoi INT = SCOPE_IDENTITY();

        -- Sao chep chi tiet
        INSERT INTO ChiTietDonHang (MaDonHang, MaSanPham, TenSanPham, MaSKU, DonViTinh, SoLuong, DonGia)
        SELECT @MaDonHangMoi, ct.MaSanPham, sp.TenSanPham, sp.MaSKU, sp.DonViTinh, ct.SoLuong, ct.DonGia
        FROM ChiTietDonHangNhap ct
        JOIN SanPham sp ON ct.MaSanPham = sp.MaSanPham
        WHERE ct.MaDonNhap = @MaDonNhap;

        -- Cap nhat don nhap thanh hoan thanh
        UPDATE DonHangNhap SET TrangThai = N'Da hoan thanh' WHERE MaDonNhap = @MaDonNhap;

        COMMIT;
        SELECT @MaDonHangMoi AS MaDonHangMoi, @MaHienThi AS MaDonHangHienThi;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- SP3: Ghi nhan thu tien (cap nhat so quy + trang thai thanh toan)
CREATE PROCEDURE sp_NhanTien
    @MaDonHang      INT,
    @SoTien         DECIMAL(15,2),
    @LoaiQuy        NVARCHAR(20) = N'TienMat',
    @MaChiNhanh     INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TenKhachHang NVARCHAR(150), @ThanhTien DECIMAL(15,2);
    SELECT @TenKhachHang = kh.TenKhachHang, @ThanhTien = dh.ThanhTien
    FROM DonHang dh JOIN KhachHang kh ON dh.MaKhachHang = kh.MaKhachHang
    WHERE dh.MaDonHang = @MaDonHang;

    -- Tao ma phieu thu
    DECLARE @SoPhieuMoi INT;
    SELECT @SoPhieuMoi = ISNULL(MAX(CAST(SUBSTRING(MaPhieu, 4, 10) AS INT)), 5700) + 1
    FROM SoQuy;
    DECLARE @MaPhieu VARCHAR(20) = 'RVN' + RIGHT('00000' + CAST(@SoPhieuMoi AS VARCHAR), 5);

    DECLARE @MaDonHangHienThi VARCHAR(20);
    SELECT @MaDonHangHienThi = MaDonHangHienThi FROM DonHang WHERE MaDonHang = @MaDonHang;

    INSERT INTO SoQuy (MaPhieu, MaChiNhanh, MaDonHang, TenDoiTuong, LoaiQuy,
                       LoaiGiaoDich, LyDoThuChi, MaChungTuGoc, SoTien)
    VALUES (@MaPhieu, @MaChiNhanh, @MaDonHang, @TenKhachHang, @LoaiQuy,
            N'Thu', N'Thu tien ban hang', @MaDonHangHienThi, @SoTien);

    -- Cap nhat trang thai thanh toan don hang
    UPDATE DonHang
    SET TrangThaiThanhToan = CASE
        WHEN @SoTien >= @ThanhTien THEN N'Da thanh toan'
        ELSE N'Thanh toan mot phan'
    END
    WHERE MaDonHang = @MaDonHang;

    -- Cap nhat tong chi tieu khach hang
    UPDATE KhachHang
    SET TongChiTieu = TongChiTieu + @SoTien
    FROM KhachHang kh JOIN DonHang dh ON kh.MaKhachHang = dh.MaKhachHang
    WHERE dh.MaDonHang = @MaDonHang;

    SELECT @MaPhieu AS MaPhieuThu;
END;
GO

-- SP4: Lay bao cao tong quan theo khoang thoi gian
CREATE PROCEDURE sp_BaoCaoTongQuan
    @TuNgay     DATE,
    @DenNgay    DATE,
    @MaChiNhanh INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        COUNT(dh.MaDonHang)     AS TongDonHang,
        SUM(dh.ThanhTien)       AS DoanhThuThuan,
        SUM(dh.TienGiam)        AS TongGiamGia,
        AVG(dh.ThanhTien)       AS GiaTriDonTrungBinh,
        MIN(dh.ThanhTien)       AS DonThapNhat,
        MAX(dh.ThanhTien)       AS DonCaoNhat
    FROM DonHang dh
    WHERE dh.TrangThaiXuLy <> N'Da huy'
      AND CAST(dh.NgayDatHang AS DATE) BETWEEN @TuNgay AND @DenNgay
      AND (@MaChiNhanh IS NULL OR dh.MaChiNhanh = @MaChiNhanh);
END;
GO

PRINT N'Database TiemGiatSay da duoc tao thanh cong!';
PRINT N'Bao gom: ChiNhanh, NhanVien, KhachHang, SanPham, BangGia, KhuyenMai,';
PRINT N'         DonHangNhap, DonHang, SoQuy, KyQuy, BaoCaoDoanhThu';
PRINT N'Va cac Views + Stored Procedures tuong ung voi he thong Sapo.';
GO