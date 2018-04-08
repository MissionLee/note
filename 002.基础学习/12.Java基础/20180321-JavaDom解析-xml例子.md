
  根据xml文档，在数据库创建表
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
解析以下XML文档，根据配置信息要求实现:
1.连接指定数据库
2.创建table
-->
<config>
<db id="mysql">
<property name="driverClass">com.mysql.jdbc.Driver</property>
<property name="url">jdbc:mysql://127.0.0.1:3306/test</property>
<property name="user">root</property>
<property name="password">root</property>
</db>
<table tableName="tbuser">
<property name="id" column="uid" type="integer"></property>
<property name="account" column="username" type="varchar" length="255"></property>
<property name="password" column="passowrd" type="varchar" length="255"></property>
</table>
</config>
```

```java
package homework;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
public class CreateDB {
    String driverClass="";
    String url="";
    String user="";
    String password="";
    String tableName="";
    public static void main(String[] args) {
        try {
            new CreateDB().doit();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (DocumentException e) {
            e.printStackTrace();
        }
    }
    public String getsql() throws DocumentException {
        SAXReader reader = new SAXReader();
        Document document = reader.read("src/config.xml");
        //获取根节点
        Element root = document.getRootElement();
        //获取db节点
        Element db_element = root.element("db");
        //获取db节点里面的节点集合
        List<Element> db_list = db_element.elements();
        for(int i=0;i<db_list.size();i++){
            Element element = db_list.get(i);
            if("driverClass".equals(element.attributeValue("name"))){
                driverClass = element.getText();
            }
            else if("url".equals(element.attributeValue("name"))){
                url = element.getText();
            }
            else if("user".equals(element.attributeValue("name"))){
                user = element.getText();
            }
            else if("password".equals(element.attributeValue("name"))){
                password = element.getText();
            }
        }
        ArrayList<String> sqls = new ArrayList<>();
        //获取tableNmae节点
        Element tb_element = root.element("table");
        //获取表名称
        tableName =tb_element.attributeValue("tableName");
                //获取元素集合
        List<Element> tb_list = tb_element.elements();
        for(int i=0;i<tb_list.size();i++){
            Element element = tb_list.get(i);
            String column = element.attributeValue("column");
            if("integer".equals(element.attributeValue("type"))){
                sqls.add(column+" "+"int");
            }else if("varchar".equals(element.attributeValue("type"))){
                String lenght  = element.attributeValue("length");
                sqls.add(column+" "+" varchar("+lenght+") ");
            }
        }
        String sql="create table "+tableName+" (";
        for(int i=0;i<sqls.size();i++){
            //防止，引发的错误
            if(i!=sqls.size()-1){
                sql = sql+sqls.get(i)+" , ";
            }else {
                sql = sql+sqls.get(i);
            }
        }
        sql = sql+" );";
        return sql;
    }
    public void doit() throws ClassNotFoundException, SQLException, DocumentException {
        String sql=getsql();
        System.out.println(driverClass+"  "+url+"  "+user+" "+password);
        Class.forName(driverClass);
        Connection connection = DriverManager.getConnection(url,user,password);
        Statement statement = connection.createStatement();
        System.out.println(sql);
        statement.execute(sql);
    }
}




```