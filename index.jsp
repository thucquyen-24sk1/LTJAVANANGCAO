<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="SCHEMA.DichVu" %>
<%@page import="SCHEMA.KhachHang" %>
<%@page import="ProcessData.KhachHangs" %>
<%@page import="ProcessData.DichVus" %>
<%@page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sapo - Quản lý Giặt Sấy</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* CSS CƠ BẢN */
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; }
        body { background-color: #f4f6f8; display: flex; height: 100vh; overflow: hidden; }
        .sidebar { width: 240px; background-color: #1a2238; color: #a1b0cb; display: flex; flex-direction: column; flex-shrink: 0; }
        .logo { padding: 15px 20px; font-size: 24px; font-weight: bold; color: white; border-bottom: 1px solid #2b3652; display: flex; align-items: center; gap: 10px; }
        .menu-list { flex-grow: 1; overflow-y: auto; padding-top: 10px; }
        .menu-item { padding: 12px 20px; display: flex; align-items: center; gap: 15px; cursor: pointer; text-decoration: none; color: #a1b0cb; font-size: 14px; transition: 0.2s; }
        .menu-item:hover { color: white; }
        .menu-item.active { background-color: #0b5fb4; color: white; border-left: 4px solid #fff; }
        .menu-item i { width: 20px; text-align: center; font-size: 16px; }
        .main-wrapper { flex-grow: 1; display: flex; flex-direction: column; overflow: hidden; }
        .header { height: 60px; background-color: #fff; border-bottom: 1px solid #dfe3e8; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; flex-shrink: 0; }
        .search-bar { display: flex; align-items: center; background: #f4f6f8; padding: 8px 15px; border-radius: 4px; width: 400px; color: #637381; }
        .search-bar input { border: none; background: transparent; outline: none; margin-left: 10px; width: 100%; font-size: 14px; }
        .header-right { display: flex; align-items: center; gap: 20px; font-size: 14px; color: #212b36; font-weight: 500; }
        .user-avatar { width: 32px; height: 32px; background-color: #0b5fb4; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .content { padding: 20px; flex-grow: 1; overflow-y: auto; }
        /* Hiệu ứng khi hover vào các ô thống kê có thể click */
        .clickable-box { cursor: pointer; transition: all 0.2s ease; }
        .clickable-box:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.1); transform: translateY(-2px); border-color: #0088ff; }
        /* CÁC THÀNH PHẦN DÙNG CHUNG */
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .page-title { font-size: 20px; font-weight: 600; color: #212b36; }
        .btn-primary { background-color: #0088ff; color: white; border: none; padding: 8px 15px; border-radius: 4px; font-size: 14px; cursor: pointer; display: flex; align-items: center; gap: 8px; font-weight: 500;}
        .card { background-color: #fff; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .tabs { display: flex; border-bottom: 1px solid #dfe3e8; padding: 0 20px; }
        .tab { padding: 15px 20px; color: #637381; font-weight: 500; font-size: 14px; cursor: pointer; border-bottom: 3px solid transparent; }
        .tab.active { color: #0088ff; border-bottom-color: #0088ff; }
        .filter-bar { display: flex; padding: 15px 20px; gap: 15px; border-bottom: 1px solid #dfe3e8; align-items: center; }
        .filter-search { display: flex; align-items: center; border: 1px solid #dfe3e8; border-radius: 4px; padding: 8px 12px; width: 300px; }
        .filter-search input { border: none; outline: none; margin-left: 8px; width: 100%; font-size: 14px; }
        .filter-btn { background: #fff; border: 1px solid #dfe3e8; padding: 8px 15px; border-radius: 4px; color: #212b36; font-size: 14px; cursor: pointer; display: flex; align-items: center; gap: 5px; }
        
        /* BẢNG DỮ LIỆU */
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { padding: 12px 20px; font-size: 14px; font-weight: 600; color: #212b36; border-bottom: 1px solid #dfe3e8; background-color: #f9fafc; }
        td { padding: 15px 20px; font-size: 14px; color: #212b36; border-bottom: 1px solid #dfe3e8; vertical-align: middle; }
        tr:hover td { background-color: #f4f6f8; }
        .product-name { color: #0088ff; font-weight: 500; text-decoration: none; display: block; margin-bottom: 4px;}
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: 500; border: 1px solid transparent; }
        .badge-warning { background-color: #fff4e5; color: #b76e00; border-color: #ffd666; }
        .badge-success { background-color: #e6ffed; color: #22a06b; border-color: #87e8af; }
        .avatar-sm { width: 28px; height: 28px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 12px; font-weight: bold; color: #fff; margin-right: 10px; vertical-align: middle;}

        /* CSS DÀNH RIÊNG CHO TRANG TỔNG QUAN (DASHBOARD) */
        .dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
        .stat-header { padding: 15px 20px; border-bottom: 1px solid #dfe3e8; font-weight: 600; }
        .stat-row { display: flex; gap: 15px; padding: 20px; border-bottom: 1px solid #dfe3e8;}
        .stat-box { flex: 1; padding: 15px; border: 1px solid #dfe3e8; border-radius: 4px; background: #fafbfc;}
        .stat-title { font-size: 13px; color: #637381; margin-bottom: 10px; }
        .stat-value { font-size: 24px; font-weight: bold; color: #0088ff; }
        .stat-sub { font-size: 12px; color: #212b36; font-weight: bold; }
        .activity-item { padding: 15px 20px; border-bottom: 1px solid #dfe3e8; font-size: 13px; }
    </style>
</head>
<body>

    <% 
        String currentTab = request.getParameter("tab");
        if(currentTab == null) currentTab = "tongquan"; 
    %>

    <div class="sidebar">
        <div class="logo">
            <i class="fa-solid fa-cube"></i> CleanHub
        </div>
        <div class="menu-list">
            <a href="index.jsp?tab=tongquan" class="menu-item <%= "tongquan".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-house"></i> Tổng quan</a>
            <a href="index.jsp?tab=donhang" class="menu-item <%= "donhang".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-clipboard-list"></i> Đơn hàng</a>
            <a href="index.jsp?tab=vanchuyen" class="menu-item <%= "vanchuyen".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-truck"></i> Vận chuyển</a>
            <a href="index.jsp?tab=sanpham" class="menu-item <%= "sanpham".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-box"></i> Sản phẩm/Dịch vụ</a>
            <a href="index.jsp?tab=khachhang" class="menu-item <%= "khachhang".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-users"></i> Khách hàng</a>
            <a href="index.jsp?tab=khuyenmai" class="menu-item <%= "khuyenmai".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-tags"></i> Khuyến mại</a>
            <a href="index.jsp?tab=soquy" class="menu-item <%= "soquy".equals(currentTab) ? "active" : "" %>"><i class="fa-solid fa-wallet"></i> Sổ quỹ</a>
        </div>
    </div>

    <div class="main-wrapper">
        <div class="header">
            <div class="search-bar">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" placeholder="Tìm kiếm (Ctrl + K)">
            </div>
            <div class="header-right">
                <span><i class="fa-regular fa-circle-question"></i> Trợ giúp</span>
                <i class="fa-regular fa-bell" style="font-size: 18px;"></i>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <div class="user-avatar">TH</div>
                    Tuấn Huỳnh
                </div>
            </div>
        </div>

        <div class="content">

            <%-- ================= TAB TỔNG QUAN (DASHBOARD) ================= --%>
            <% if ("tongquan".equals(currentTab)) { %>
                <div class="page-header">
                    <div class="page-title">Xin chào, Tuấn Huỳnh!</div>
                </div>
                
                <div class="dashboard-grid">
                    <div>
                        <div class="card">
    <div class="stat-header">Kết quả kinh doanh</div>
    
    <div class="stat-row">
        <div class="stat-box">
            <div class="stat-title">Doanh thu thuần</div>
            <div class="stat-value">6.43tr <span style="font-size:12px; color:red; font-weight:normal;">↘ 23%</span></div>
        </div>
        
        <div class="stat-box clickable-box" onclick="window.location.href='index.jsp?tab=donhang'">
            <div class="stat-title">Tổng đơn</div>
            <div class="stat-sub" style="font-size: 18px;">128</div>
        </div>
        
        <div class="stat-box clickable-box" onclick="window.location.href='index.jsp?tab=donhang'">
            <div class="stat-title">Chưa thanh toán</div>
            <div class="stat-sub" style="font-size: 18px;">45</div>
        </div>
    </div>
    
    <div style="padding: 20px; display:flex; justify-content: space-between; text-align: center; border-bottom: 1px solid #dfe3e8;">
        <div><div class="stat-title">Giá trị trung bình đơn</div><div class="stat-sub">50,217đ</div></div>
        <div><div class="stat-title">SL hàng thực bán</div><div class="stat-sub">442.7</div></div>
        
        <div class="clickable-box" style="padding: 10px; border-radius: 4px;" onclick="window.location.href='index.jsp?tab=donhang'">
            <div class="stat-title">Chưa giao</div><div class="stat-sub">48</div>
        </div>
        
        <div><div class="stat-title">Hủy</div><div class="stat-sub">0</div></div>
    </div>
</div>

                        <div class="card">
                            <div class="stat-header">Sản phẩm bán chạy</div>
                            <div style="padding: 15px 20px; font-size: 14px;">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 15px;">
                                    <span><span style="display:inline-block; width:24px; height:24px; background:#f4f6f8; text-align:center; line-height:24px; border-radius:50%; margin-right:10px;">1</span> ÁO QUẦN TỪ 3KG TRỞ LÊN</span>
                                    <span style="font-weight: bold;">301.3</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 15px;">
                                    <span><span style="display:inline-block; width:24px; height:24px; background:#f4f6f8; text-align:center; line-height:24px; border-radius:50%; margin-right:10px;">2</span> CHĂN, MỀN, GA...</span>
                                    <span style="font-weight: bold;">26.5</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="card">
                            <div class="stat-header">Nhật ký hoạt động</div>
                            <div class="activity-item">
                                <span style="color: #0088ff;">• unknown</span> Thêm mới phiếu thu: RVN05738<br>
                                <span style="color: #919eab; font-size: 12px;">23/04/2026 11:28:02</span>
                            </div>
                            <div class="activity-item">
                                <span style="color: #0088ff;">• Sapo</span> Khoản thanh toán 57,000đ được xác nhận<br>
                                <span style="color: #919eab; font-size: 12px;">23/04/2026 11:28:02</span>
                            </div>
                            <div class="activity-item">
                                <span style="color: #0088ff;">• Trà My</span> Đã tạo mới đơn hàng<br>
                                <span style="color: #919eab; font-size: 12px;">23/04/2026 10:59:49</span>
                            </div>
                        </div>
                    </div>
                </div>

            <%-- ================= TAB KHÁCH HÀNG ================= --%>
            <% } else if ("khachhang".equals(currentTab)) { %>
                <div class="page-header">
                    <div class="page-title">Khách hàng</div>
                    <button class="btn-primary"><i class="fa-solid fa-plus"></i> Thêm khách hàng</button>
                </div>
                <div class="card">
                    <div class="tabs">
                        <div class="tab active">Tất cả</div>
                    </div>
                    <div class="filter-bar">
                        <div class="filter-search"><i class="fa-solid fa-magnifying-glass"></i> <input type="text" placeholder="Tìm kiếm khách hàng"></div>
                        <button class="filter-btn">Nhóm khách hàng <i class="fa-solid fa-chevron-down"></i></button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 40px;"><input type="checkbox"></th>
                                <th>Tên khách hàng</th>
                                <th>Email</th>
                                <th>Điện thoại</th>
                                <th style="text-align: center;">Đơn hàng</th>
                                <th>Đơn hàng gần nhất</th>
                                <th style="text-align: right;">Tổng chi tiêu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // Gọi class xử lý để lấy danh sách từ SQL Server
                                KhachHangs dataKH = new KhachHangs();
                                ArrayList<KhachHang> listKH = dataKH.getAllKhachHang();
                                
                                if(listKH.isEmpty()){
                                    out.print("<tr><td colspan='7' style='text-align:center; padding: 20px;'>Chưa có khách hàng nào trong hệ thống!</td></tr>");
                                } else {
                                    // Vòng lặp in từng khách hàng ra bảng
                                    for(KhachHang kh : listKH) {
                                        // Mẹo UI nhỏ: Lấy 2 chữ cái đầu của tên khách hàng làm Avatar y hệt Sapo
                                        String avatar = kh.getTenKH().length() >= 2 ? kh.getTenKH().substring(0, 2).toUpperCase() : "KH";
                            %>
                            <tr>
                                <td><input type="checkbox"></td>
                                <td>
                                    <span class="avatar-sm" style="background:#0088ff;"><%= avatar %></span> 
                                    <a href="#" class="product-name" style="display:inline;"><%= kh.getTenKH() %></a>
                                </td>
                                <td><%= kh.getEmail() != null ? kh.getEmail() : "" %></td>
                                <td><%= kh.getDienThoai() != null ? kh.getDienThoai() : "" %></td>
                                <td style="text-align: center;">0</td>
                                <td>---</td>
                                <td style="text-align: right;"><%= String.format("%,.0f", kh.getTongChiTieu()) %> đ</td>
                            </tr>
                            <% 
                                    } 
                                } 
                            %>
                        </tbody>
                    </table>
                </div>

            <%-- ================= TAB KHUYẾN MẠI ================= --%>
            <% } else if ("khuyenmai".equals(currentTab)) { %>
                <div class="page-header">
                    <div class="page-title">Danh sách khuyến mại</div>
                    <button class="btn-primary"><i class="fa-solid fa-plus"></i> Tạo khuyến mại</button>
                </div>
                <div class="card">
                    <div class="tabs">
                        <div class="tab active">Tất cả</div>
                        <div class="tab">Đang áp dụng</div>
                        <div class="tab">Ngừng áp dụng</div>
                    </div>
                    <div class="filter-bar">
                        <div class="filter-search"><i class="fa-solid fa-magnifying-glass"></i> <input type="text" placeholder="Tìm kiếm khuyến mại"></div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 40px;"><input type="checkbox"></th>
                                <th>Khuyến mại</th>
                                <th>Loại khuyến mại</th>
                                <th>Trạng thái</th>
                                <th>Ngày bắt đầu</th>
                                <th>Ngày kết thúc</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><input type="checkbox"></td>
                                <td>
                                    <div style="display:flex; align-items:center; gap: 10px;">
                                        <i class="fa-solid fa-bullhorn" style="color: #0088ff; font-size: 18px;"></i>
                                        <div>
                                            <a href="#" class="product-name">TRI ÂN</a>
                                            <span style="font-size: 12px; color: #637381;">Giảm 5% cho toàn bộ đơn hàng</span>
                                        </div>
                                    </div>
                                </td>
                                <td>Giảm giá đơn hàng</td>
                                <td><span class="badge badge-success">Đang áp dụng</span></td>
                                <td>30/12/2025 16:50</td>
                                <td>---</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            <%-- ================= TAB VẬN CHUYỂN ================= --%>
            <% } else if ("vanchuyen".equals(currentTab)) { %>
                <div class="page-header">
                    <div class="page-title">Quản lý vận đơn</div>
                    <button class="btn-primary"><i class="fa-solid fa-plus"></i> Tạo đơn giao hàng</button>
                </div>
                <div class="card">
                    <div class="tabs">
                        <div class="tab active">Tất cả</div>
                        <div class="tab">Đang giao</div>
                        <div class="tab">Giao thành công</div>
                    </div>
                    <div class="filter-bar">
                        <div class="filter-search"><i class="fa-solid fa-magnifying-glass"></i> <input type="text" placeholder="Tìm mã vận đơn, đơn hàng..."></div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Mã vận đơn</th>
                                <th>Mã đơn hàng</th>
                                <th>Khách hàng</th>
                                <th>Đối tác giao hàng</th>
                                <th>Trạng thái</th>
                                <th>Phí vận chuyển</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><a href="#" class="product-name">VD100234</a></td>
                                <td><a href="#">HĐ6979</a></td>
                                <td>khoa 676</td>
                                <td>Giao Hàng Tiết Kiệm</td>
                                <td><span class="badge badge-warning">Đang giao hàng</span></td>
                                <td>15,000 đ</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            <%-- ================= TAB ĐƠN HÀNG ================= --%>
            <% } else if ("donhang".equals(currentTab)) { %>
                <div class="page-header">
                    <div class="page-title">Danh sách Đơn hàng</div>
                    <button class="btn-primary"><i class="fa-solid fa-plus"></i> Tạo đơn hàng</button>
                </div>
                <div class="card">
                    <div class="tabs">
                        <div class="tab active">Tất cả</div>
                        <div class="tab">Đang giao dịch</div>
                        <div class="tab">Đã hoàn thành</div>
                    </div>
                    <div class="filter-bar">
                        <div class="filter-search"><i class="fa-solid fa-magnifying-glass"></i> <input type="text" placeholder="Tìm kiếm theo mã đơn hàng, SĐT..."></div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Mã đơn hàng</th>
                                <th>Ngày đặt</th>
                                <th>Khách hàng</th>
                                <th>Thành tiền</th>
                                <th>Trạng thái thanh toán</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><a href="#" class="product-name">HĐ6979</a></td>
                                <td>23/04/2026 10:45</td>
                                <td>khoa 676 07:53</td>
                                <td style="font-weight: 500;">39,900 đ</td>
                                <td><span class="badge badge-warning">Chưa thanh toán</span></td>
                            </tr>
                            <tr>
                                <td><a href="#" class="product-name">HĐ6978</a></td>
                                <td>23/04/2026 10:44</td>
                                <td>trinh 025 8:20</td>
                                <td style="font-weight: 500;">34,200 đ</td>
                                <td><span class="badge badge-warning">Chưa thanh toán</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            <%-- ================= TAB SẢN PHẨM (JAVA & SQL) ================= --%>
            <% } else if ("sanpham".equals(currentTab)) { %>
                <div class="page-header">
                    <div class="page-title">Danh sách Dịch vụ Giặt Sấy</div>
                    <button class="btn-primary"><i class="fa-solid fa-plus"></i> Thêm dịch vụ</button>
                </div>
                <div class="card">
                    <div class="tabs">
                        <div class="tab active">Tất cả</div>
                    </div>
                    <div class="filter-bar">
                        <div class="filter-search"><i class="fa-solid fa-magnifying-glass"></i> <input type="text" placeholder="Tìm kiếm theo mã dịch vụ, tên..."></div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 40px;"><input type="checkbox"></th>
                                <th style="width: 60px;"></th>
                                <th>Dịch vụ</th>
                                <th>Đơn vị tính</th>
                                <th>Giá bán</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                DichVus data = new DichVus();
                                ArrayList<DichVu> list = data.getAllDichVu();
                                if(list.isEmpty()){
                                    out.print("<tr><td colspan='5' style='text-align:center; padding: 30px;'>Kiểm tra lại CSDL nhé! Không có dữ liệu.</td></tr>");
                                } else {
                                    for(DichVu dv : list) {
                            %>
                            <tr>
                                <td><input type="checkbox"></td>
                                <td><div style="width: 40px; height: 40px; background-color: #dfe3e8; border-radius: 4px; display: flex; align-items: center; justify-content: center; color: #919eab;"><i class="fa-solid fa-shirt"></i></div></td>
                                <td>
                                    <a href="#" class="product-name"><%= dv.getTenDV() %></a>
                                    <span style="font-size: 12px; color: #637381;">Mã: <%= dv.getMaDV() %></span>
                                </td>
                                <td><%= dv.getDonViTinh() %></td>
                                <td style="font-weight: 500;"><%= String.format("%,.0f", dv.getGiaTien()) %> đ</td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>

            <%-- TAB SỔ QUỸ & CÁC TAB KHÁC --%>
            <% } else { %>
                <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 60vh; color: #637381;">
                    <i class="fa-solid fa-person-digging" style="font-size: 60px; margin-bottom: 20px; color: #dfe3e8;"></i>
                    <h2>Tính năng đang được phát triển!</h2>
                </div>
            <% } %>

        </div>
    </div>
</body>
</html>