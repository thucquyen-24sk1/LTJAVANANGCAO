package ProcessData;

import SCHEMA.KhachHang;
import ConnectionData.CONNECTIONSQLSERVER;
import java.sql.*;
import java.util.ArrayList;

public class KhachHangs {
    public ArrayList<KhachHang> getAllKhachHang() {
        ArrayList<KhachHang> list = new ArrayList<>();
        try {
            Connection cn = new CONNECTIONSQLSERVER().getConnection();
            String sql = "SELECT * FROM KhachHang";
            Statement st = cn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while(rs.next()){
                list.add(new KhachHang(
                    rs.getInt("MaKH"),
                    rs.getString("TenKH"),
                    rs.getString("Email"),
                    rs.getString("DienThoai"),
                    rs.getDouble("TongChiTieu")
                ));
            }
            rs.close(); st.close(); cn.close();
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }
}