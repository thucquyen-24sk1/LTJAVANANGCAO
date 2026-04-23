package ConnectionData;

import java.sql.Connection;
import java.sql.DriverManager;

public class CONNECTIONSQLSERVER {
    private Connection cnn = null;

    public CONNECTIONSQLSERVER() {
        try {
            // Thay đổi password "123456" thành mật khẩu SQL Server của bạn
            String url = "jdbc:sqlserver://localhost:1433;databaseName=QuanLyShopHoa;encrypt=true;trustServerCertificate=true;";
            String user = "sa";
            String pass = "12345"; 
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            cnn = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            System.out.println("Lỗi kết nối CSDL: " + e.getMessage());
        }
    }

    public Connection getConnection() {
        return cnn;
    }
}