# Java.util.ResourceBundle使用详解

## 必须放在 src 或者 classpath 里面
## 后面有 ResourceBundle 与 Properties 的区别

## 一、认识国际化资源文件
 
这个类提供软件国际化的捷径。通过此类，可以使您所编写的程序可以：
         轻松地本地化或翻译成不同的语言
         一次处理多个语言环境
         以后可以轻松地进行修改，支持更多的语言环境
 
说的简单点，这个类的作用就是读取资源属性文件（properties），然后根据.properties文件的名称信息（本地化信息），匹配当前系统的国别语言信息（也可以程序指定），然后获取相应的properties文件的内容。
 
使用这个类，要注意的一点是，这个properties文件的名字是有规范的：一般的命名规范是： 自定义名_语言代码_国别代码.properties，
如果是默认的，直接写为：自定义名.properties
比如：
myres_en_US.properties
myres_zh_CN.properties
myres.properties
 
当在中文操作系统下，如果myres_zh_CN.properties、myres.properties两个文件都存在，则优先会使用myres_zh_CN.properties，当myres_zh_CN.properties不存在时候，会使用默认的myres.properties。
 
没有提供语言和地区的资源文件是系统默认的资源文件。
资源文件都必须是ISO-8859-1编码，因此，对于所有非西方语系的处理，都必须先将之转换为Java Unicode Escape格式。转换方法是通过JDK自带的工具native2ascii.
 
## 二、实例
 
定义三个资源文件，放到src的根目录下面（必须这样，或者你放到自己配置的calsspath下面。
 
myres.properties
aaa=good 
bbb=thanks

myres_en_US.properties
aaa=good 
bbb=thanks

myres_zh_CN.properties
aaa=\u597d 
bbb=\u591a\u8c22

```java 
import java.util.Locale; 
import java.util.ResourceBundle; 

/** 
* 国际化资源绑定测试 
* 
* @author leizhimin 2009-7-29 21:17:42 
*/ 
public class TestResourceBundle { 
        public static void main(String[] args) { 
                Locale locale1 = new Locale("zh", "CN"); 
                ResourceBundle resb1 = ResourceBundle.getBundle("myres", locale1); 
                System.out.println(resb1.getString("aaa")); 

                ResourceBundle resb2 = ResourceBundle.getBundle("myres", Locale.getDefault()); 
                System.out.println(resb1.getString("aaa")); 

                Locale locale3 = new Locale("en", "US"); 
                ResourceBundle resb3 = ResourceBundle.getBundle("myres", locale3); 
                System.out.println(resb3.getString("aaa")); 
        } 
}
```
运行结果：
好 
好 
good 

Process finished with exit code 0
 
如果使用默认的Locale，那么在英文操作系统上，会选择myres_en_US.properties或myres.properties资源文件。
 
## 三、认识Locale

Locale 对象表示了特定的地理、政治和文化地区。需要 Locale 来执行其任务的操作称为语言环境敏感的 操作，它使用 Locale 为用户量身定制信息。例如，显示一个数值就是语言环境敏感的操作，应该根据用户的国家、地区或文化的风俗/传统来格式化该数值。
 
使用此类中的构造方法来创建 Locale：
 Locale(String language)
 Locale(String language, String country)
 Locale(String language, String country, String variant)
 
创建完 Locale 后，就可以查询有关其自身的信息。使用 getCountry 可获取 ISO 国家代码，使用 getLanguage 则获取 ISO 语言代码。可用使用 getDisplayCountry 来获取适合向用户显示的国家名。同样，可用使用 getDisplayLanguage 来获取适合向用户显示的语言名。有趣的是，getDisplayXXX 方法本身是语言环境敏感的，它有两个版本：一个使用默认的语言环境作为参数，另一个则使用指定的语言环境作为参数。 
语言参数是一个有效的 ISO 语言代码。这些代码是由 ISO-639 定义的小写两字母代码。在许多网站上都可以找到这些代码的完整列表，如： 
http://www.loc.gov/standards/iso639-2/englangn.html。    
国家参数是一个有效的 ISO 国家代码。这些代码是由 ISO-3166 定义的大写两字母代码。在许多网站上都可以找到这些代码的完整列表，如： 
http://www.iso.ch/iso/en/prods-services/iso3166ma/02iso-3166-code-lists/list-en1.html。    
 
## 四、中文资源文件的转码 native2ascii
 
这个工具用法如下:

 
如果觉得麻烦，可以直接将中文粘贴到里面，回车就可以看到转码后的结果了。

## ResourceBundle和properties 读取配置文件区别 ---------------------------！！！！
博客分类： Java
 
java.util.ResourceBundle 和java.util.properties 读取配置文件区别

 

这两个类都是读取properties格式的文件的，而Properties同时还能用来写文件。  
   
  Properties的处理方式是将其作为一个映射表,而且这个类表示了一个持久的属性集,他是继承HashTable这个类。ResourceBundle本质上也是一个映射，但是它提供了国际化的功能。  
   
  假设电脑设置的地区是中国大陆，语言是中文  
   
  那么你向ResourceBundle（资源约束名称为base）获取abc变量的值的时候，ResourceBundle会先后搜索  
  base_zh_CN_abc.properties  
  base_zh_CN.properties  
  base_zh.properties  
  base.properties  
  文件，直到找到abc为止  
   
  相应的，在英国就会去找base_en_GB_abc.properties等。  
   
  因此，你只需要提供不同语言的资源文件，而无需改变代码，就达到了国际化的目的。  
   
  另外，在.properties里面，不能直接使用中文之类文字，而是要通过native2ascii转乘\uxxxx这种形式 

   附: 

   1.编码问题:

	无论系统的默认编码是什么，ResourceBundle在读取properties文件时统一使用iso8859-1编码。因此，如果在默认编码为 GBK的系统中编写了包含中文的properties文件，经由ResourceBundle读入时，必须转换为GBK格式的编码，否则不能正确识别。

   2.用法:

	ResourceBundle:
```java
	ResourceBundle conf= ResourceBundle.getBundle("config/fnconfig/fnlogin");

	String value= conf.getString("key");

 

	Properties:

	Properties prop = new Properties();

	try {
		InputStream is = getClass().getResourceAsStream("xmlPath.properties");

		prop.load(is);

		//或者直接prop.load(new FileInputStream("c:/xmlPath.properties"));

		if (is != null) {
			is.close();

		}
	} catch (Exception e) {
		System.out.println( "file " + "catalogPath.properties" + " not found!\n" + e);
	}
	String value= prop.getProperty("key").toString();
```