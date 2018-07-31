# ApplictionContext

> ApplictionContext 和 BeanFactory两者都是用于加载Bean，单前者提供更多扩展功能。

## 设置配置路径

ApplicationContext的默认实现ClassPathXmlApplicationContext支持多个配置文件，以数组方式同时传入

## 扩展功能

- 入口构造是这个样子

```java
	public ClassPathXmlApplicationContext(String[] configLocations, boolean refresh, ApplicationContext parent)
			throws BeansException {

		super(parent);
		setConfigLocations(configLocations);
		if (refresh) {
			refresh();
		}
	}
// 其中 refresh 可以看到ApplictionContext的逻辑 - 以下是refresh的源码
	@Override
	public void refresh() throws BeansException, IllegalStateException {
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
			prepareRefresh();
            // 准备工作，例如对系统属性，环境变量的准备和验证

			// Tell the subclass to refresh the internal bean factory.
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();
            // 初始化BeanFactory，读取配置文件，用的就是BeanFactory的读取解析等功能

			// Prepare the bean factory for use in this context.
			prepareBeanFactory(beanFactory);
            //对BeanFactory进行功能填充，例如支持@Autowired

			try {
				// Allows post-processing of the bean factory in context subclasses.
				postProcessBeanFactory(beanFactory);
                // 子类覆盖方法做额外的处理

				// Invoke factory processors registered as beans in the context.
				invokeBeanFactoryPostProcessors(beanFactory);
                //激活 BeanFactory处理器

				// Register bean processors that intercept bean creation.
				registerBeanPostProcessors(beanFactory);
                //注册 拦击Bean创建的处理器

				// Initialize message source for this context.
				initMessageSource();
                //为上下文初始化Message源

				// Initialize event multicaster for this context.
				initApplicationEventMulticaster();
                //初始化消息广播器，

				// Initialize other special beans in specific context subclasses.
				onRefresh();
                //子类初始化其他Bean

				// Check for listener beans and register them.
				registerListeners();
                //查找Listener bean，注册到广播

				// Instantiate all remaining (non-lazy-init) singletons.
				finishBeanFactoryInitialization(beanFactory);
                // 初始化剩下的单实例（非惰性）

				// Last step: publish corresponding event.
				finishRefresh();
                //完成刷新，通知lifecycleProcessor，同时发出ContextRefreshEvent
			}

			catch (BeansException ex) {
				if (logger.isWarnEnabled()) {
					logger.warn("Exception encountered during context initialization - " +
							"cancelling refresh attempt: " + ex);
				}

				// Destroy already created singletons to avoid dangling resources.
				destroyBeans();

				// Reset 'active' flag.
				cancelRefresh(ex);

				// Propagate exception to caller.
				throw ex;
			}

			finally {
				// Reset common introspection caches in Spring's core, since we
				// might not ever need metadata for singleton beans anymore...
				resetCommonCaches();
			}
		}
	}

```

- 下面的和上面这个代码类似

## 环境准备

## 加载BeanFactory

- 同样也是 DefaultListableBeanFactory
- 指定序列化ID
- 定制BeanFactory
- 加载BeanDefinition
- 使用全局变量记录BeanFactory类示例

### 定制BeanFactory

- 提供对注解的支持

### 加载BeanDefinition

- 用的也是XmlBeanDefinitionReader来读取xml
- 后面用的就是BeanFactory那一套，结果就是DefaultListableBeanFactory的变量beanFactory已经包含了所有解析好的配置

## 功能扩展

### SPEL语言支持

- 支持 xml里面用 #{xxx}这样的语法
- 还有更多强大功能

### 增加属性注册编辑器

> 后面ConversionService里面也有能处理注入数据类型的东西

- 一般情况下属性注入（DI）的时候，只能注册String类型的（XML文件里面，就只能写String？然后注入的时候，也就能转成 int什么的），如果我们想注入Date类型的日期，就会出问题
  - Spring提供解决
  - 方法1：使用自定义属性编辑器
  - 方法2：注册Spring自带的属性编辑器（针对Date的那个：CustomDateEditor）
- 添加ApplicationContextAwareProcessor处理器
  - 书里说的，没细看
- 设置忽略依赖
- 注册以来

## BeanFactory的后处理

- 激活注册的BeanFactoryPostProcessor
- 注册BeanPostProcessor
- 初始化消息资源
- 初始化ApplictionEventMulticaster
- 注册监听器

## 初始化非延迟加载单例

- ConversionService设置

  - 自定义 

    ```java
    public class String2DateConverter implements Converter<String,Date>{
        @Override
        public Date convert(String arg0){
            try{
                return DataUtils.parseDate(arg0,new String[]{"yyyy-MM-dd HH:mm:ss"})
            }catch(ParseException e){
                return null;
            }
        }
    }
    ```

  - 注册

  ```xml
  // 写在xml 需要注入Date类型，转换的那个 bean里面
  <property name="converters">
  	<list>
          <bean class="String2DateConverter" />
      </list>
  </property>
  ```

- 冻结配置

  - 冻结所有bean定义，不许修改

- 初始化非延迟加载

  - 将所有单例的bean提前进行实例化
  - 这样有点好处就是，如果配置文件写的有问题，能够立刻看到，而不是用到才发现

## finishRefresh





