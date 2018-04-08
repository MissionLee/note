import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hbase._
import org.apache.hadoop.hbase.client._
import org.apache.hadoop.hbase.mapreduce.TableInputFormat
import org.apache.hadoop.hbase.util.Bytes
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf

import java.util.Date
  object SparkOperateHBase {
    def main(args: Array[String]) {

      val conf = HBaseConfiguration.create()
      conf.set("hbase.zookeeper.quorum","10.1.2.47,10.1.2.46,10.1.2.45")
      val sc = new SparkContext(new SparkConf().setAppName("mygod").setMaster("local[2] "))
      val conn = ConnectionFactory.createConnection(conf)
      val tb=TableName.valueOf("test01")
      val table=conn.getTable(tb)
      // 单条测试
      val timestart=new Date().getTime
      val myget=new Get("999".getBytes)
      myget.addColumn("info".getBytes,"value".getBytes)
      val info = table.get(myget)
      val timeend=new Date().getTime
      println("total cost :"+(timeend-timestart)+"ms")
      //=> total cost :740ms

      //连续分次取1000条数据测试
      val timestart=new Date().getTime
      val values=new Array[String](1000)
      var i=0;
      var result="";
      for( i<- 0 to 999){
          str=(i+1).toString
          val myget=new Get(str.getBytes);
          myget.addColumn("info".getBytes,"value".getBytes);        
          val result = table.get(myget);
          values(i)=Bytes.toString(result.getValue("info".getBytes,"value".getBytes))
      }
      val timeend=new Date().getTime
      println("total cost :"+(timeend-timestart)+"ms")
      //=> total cost :1618ms
      conn.close()
      sc.stop()
    }
  }