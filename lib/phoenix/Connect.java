package phoenix;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.DatabaseMetaData;

public class Connect {

  private String host;
  private String port;

  private Connection connection;

  public Connect(String host, String port) {
    this.host = host;
    this.port = port;
  }

  public void setHost(String host) {
    this.host = host;
  }

  public void setPort(String port){
    this.port = port;
  }

  public String getHost(){
    return host;
  }

  public String getPort(){
    return port;
  }

  public Connection connect() {
    try {
      Class.forName("org.apache.phoenix.jdbc.PhoenixDriver");
      // String DBConnectionString = "jdbc:phoenix:10.125.51.86:2181:/hbase";
      // String DBConnectionString = "jdbc:phoenix:kanbox-datacraft-cloud-compute-10.et2:2181:/hbase"; // hadoop10.cloud.cm10 | hadoop9.cloud.cm10 | hadoop8.cloud.cm10
      String DBConnectionString = "jdbc:phoenix:" + this.host + ":" + this.port +  ":/hbase";
      connection = DriverManager.getConnection(DBConnectionString);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return connection;
  }

  public ResultSet executeQuery(String sql) {
    connect();
    ResultSet rs = null;
    try {
      Statement statement = connection.createStatement();
      rs = statement.executeQuery(sql);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return rs;
  }

  public ResultSet getMetaData(String tableName) throws Exception {
    connect();
    DatabaseMetaData md = connection.getMetaData();
    ResultSet rs = md.getColumns(null, null, tableName, null);
    return rs;
  }

  public Integer executeUpdate(String sql) {
    connect();
    Integer i = 0;
    try {
      Statement statement = connection.createStatement();
      i = statement.executeUpdate(sql);
      connection.commit();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return i;
  }

  public void close() {
    try {
      connection.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

}
