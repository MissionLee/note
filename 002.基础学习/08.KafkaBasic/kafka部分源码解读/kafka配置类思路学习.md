# 

在创建你kafka的Producer的时候，producer的构造函数，需要传入一个存储着相关参数的Map，我们在这里分析一下kafka是如何处理配置类的

- 使用套路
  - 1.一个配置类 ProducerConfig
    - -1 首先这个类里面定义了大量的静态参数，举两个例子
    ```java
    public static final String BOOTSTRAP_SERVERS_CONFIG = CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG;  // 底层是 "bootstrap.servers"
    public static final String METADATA_FETCH_TIMEOUT_CONFIG = "metadata.fetch.timeout.ms";
    ```
    - -2 一个静态代码块，
    ```java
    //kafka中又多种不同的config，其底层是一个名为： AbstractConfig的类
    private static final ConfigDef CONFIG;
    static{
        CONFIG = new ConfigDef().define(BOOTSTRAP_SERVERS_CONFIG, Type.LIST, Importance.HIGH, CommonClientConfigs.BOOSTRAP_SERVERS_DOC)
        // 后面又以大串 的   .define()
    }
    ```
    - -3 构造函数
    ```java
    // 构造函数 是传入一个Map，并且调用 super() 上层构造
        ProducerConfig(Map<?, ?> props) {
        super(CONFIG, props);
    }
    ```
  - 2.需要一个装有配置参数的Map
    - -1.首先我们可以明白为什么ProducerConfig里面又那么多static final String 了，因为这些静态值都是约定好的参数名称，这种形式可以防止开发者在创建 配置参数的健值对的时候写错 健
  - 3.创建Kafkaproducer的时候发生了什么
    - -1 新建一个producer
    ```scala
    val producer = new KafkaProducer[String, String](props)
    ```
    - -2 看看在 KafkaProducer创建的时候发生了什么
    ```scala
    // 这里可以看到，在构造函数里面，新建了 ProducerConfig类
        public KafkaProducer(Map<String, Object> configs) {
        this(new ProducerConfig(configs), null, null);
        // alt+左健这个this可以看到，这个 new ProducerConfig被复制给了 一个类成员
    }
    ```
  - 4.至此，一个配置文件类的套路就明确了
    - -1.我们创建一个配置类（ProducerConfig），并且讲需要的参数名称规定好（用 static final），因为是静态的，方便使用
    - -2.为了让开发者，更明确
      - 我们把 创建这个Config类的步骤也隐藏起来，用户只需要提供一个 放着配置的Map
    - -3.在用户 新建一个 需要这份配置文件的类（Producer）
      - 这个Producer实际上也是使用 ProducerConfig存储参数
      - 我们通过构造，在构造中实现 new ProducerConfig，并通过用户提供的Map来定制参数
    - -4.以上，对于一个用户（开发者）来说，我们隐藏可 ProducerConfig的细节，他们只需要关注 配置参数具体是什么就可以了，只要把配置参数放到Map里面，其他的都很容易解决