# JSON

> 阿里巴巴FastJson

- JSONObject.parseObject(String,Clazz)
- 里面转了一层，调用了下面这个：
- 主要是把JSON字符串转换成给定的类
```java
    /**
     * 
     * This method deserializes the specified Json into an object of the specified class. It is not
     * suitable to use if the specified class is a generic type since it will not have the generic
     * type information because of the Type Erasure feature of Java. Therefore, this method should not
     * be used if the desired type is a generic type. Note that this method works fine if the any of
     * the fields of the specified object are generics, just the object itself should not be a
     * generic type. For the cases when the object is of generic type, invoke
     * {@link #parseObject(String, Type, Feature[])}. If you have the Json in a {@link InputStream} instead of
     * a String, use {@link #parseObject(InputStream, Type, Feature[])} instead.
     *
     * @param json the string from which the object is to be deserialized
     * @param clazz the class of T
     * @param features parser features
     * @return an object of type T from the string
     * classOfT
     */
    @SuppressWarnings("unchecked")
    public static <T> T parseObject(String json, Class<T> clazz, Feature... features) {
        return (T) parseObject(json, (Type) clazz, ParserConfig.global, null, DEFAULT_PARSER_FEATURE, features);
    }
```