# 追溯一个BEAN的加载

```java
public class WithSpring {
    public static void main(String[] args) {
        ApplicationContext context = new ClassPathXmlApplicationContext("spring-config.xml");
        Person person = (Person)context.getBean("Person");
        person.sayHello();
        // sleep with AOP
        person.sleep();
    }
}

```

## 简单说明

根据常理推测，Spring会做以下工作

- 加载解析配置文件
- 根据给定名称，找到-配置-获取bean

## 从代码中查找这个流程

- 首先看一下 ClassPathXmlApplicationContext的继承结构

![001](.\res\001.png)


- XmlBeanFactory的继承结构，我的电脑打开内存久会溢出

  - public class XmlBeanFactory extends DefaultListableBeanFactory
  - 里面自定义了 private final XmlBeanDefinitionReader reader = new XmlBeanDefinitionReader(this);
  - 这里不说，下面继续看 ApplicationContext的内容
- ApplicationContext的实现 中的 getBean 是我们给定bean 名称的入口，在这个继承体系中 AbstractApplicationContext 中提供了 getBean 这个方法


  - getBean 和 doGetBean

  ```java
  @Override
  	public Object getBean(String name) throws BeansException {
  		assertBeanFactoryActive();
  		return getBeanFactory().getBean(name);
  	}
  ```

  - 这里引入了 getBeanFactory() ，我们在AbstractApplictionContext的子类AbstractRefreshableApplicationContext 里 找到这个方法的实现

  ```java
  	@Override
  	public final ConfigurableListableBeanFactory getBeanFactory() {
  		synchronized (this.beanFactoryMonitor) {
  			if (this.beanFactory == null) {
  				throw new IllegalStateException("BeanFactory not initialized or already closed - " +
  						"call 'refresh' before accessing beans via the ApplicationContext");
  			}
  			return this.beanFactory;
  		}
  	}
  ```

  - 实际上还是提供了一个 DefaultListableBeanFactory ： `这就是Spring中Bean加载的核心`
  - 在DefaultListableBeanFactory （统一入口）的父类AbstractBeanFactory中，可以找到getBean和doGetBean的真正实现
    -  doGetBean会先获取真正的Bean名称
    -  返回Bean的实例
      - doGetBean中由一个 getSingleton（在DefaultSingletonBeanRegistry中，这是用来 注册 Bean的）
        - 在调试代码的时候，用 我们所需的 bean已经被缓存在 一个 map里面了，所以直接就返回了一个实例
        - 之后就是一层层返回到个人代码中

## BeanFactory与资源加载

- 主要是 XmlBeanFactory来梳理 （用这个梳理直观一些，因为BeanFactory入口也过时了，都用ApplictionContext了）
  - XmlBeanFactory 里面创建了XmlBeanDefinitionReader
  - 然后定义了 Resource 类作为XmlBeanFactory的构造要传入的内容
    - Resource类由很多特例化的实现
      - FileSystemResource
      - ClassPathResource
      - UrlResource
      - 。。。
  - 加载Doc之后会进行一些验证
  - 然后解析BeanDefinition

## Spring是如何配置缓存了所有Bean的Map的？

- 在 new 一个 ApplicaitionContext的实现的时候，系统解析了Xml文件，知道 “Person” 对应的就是 我们定义好的person类

- 在上面那个体系图里面，我们可以找到 DefaultResourceLoader 这个类

  - 构造的时候，久会先获取一个 ClassLoader

  ```java
  	public DefaultResourceLoader() {
  		this.classLoader = ClassUtils.getDefaultClassLoader();
  	}
  ```

  