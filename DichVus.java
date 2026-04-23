/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ProcessData;

import SCHEMA.DichVu;
import ConnectionData.CONNECTIONSQLSERVER;
import java.sql.*;
import java.util.ArrayList;

public class DichVus {
    
    // Hàm lấy toàn bộ danh sách dịch vụ giặt sấy
    public ArrayList<DichVu> getAllDichVu() {
        ArrayList<DichVu> list = new ArrayList<>();
        try {
            Connection cn = new CONNECTIONSQLSERVER().getConnection();
            String sql = "SELECT * FROM DichVu";
            Statement st = cn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while(rs.next()){
                list.add(new DichVu(
                    rs.getString("MaDV"), 
                    rs.getString("TenDV"), 
                    rs.getString("DonViTinh"), 
                    rs.getDouble("GiaTien")
                ));
            }
            rs.close(); st.close(); cn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}