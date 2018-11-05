```java
package com.bicon.base.service.impl;

import com.bicon.base.service.RedisService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Set;

@Service("redisServiceImpl")
public class RedisServiceImpl implements RedisService{
	@Resource
	RedisTemplate<String, String> redisTemplate;

	@Override
	public boolean setStr(String key, String value, int expire) {
		Object result = redisTemplate.execute(new RedisCallback<Object>() {
			@Override
			public Object doInRedis(RedisConnection connection) throws DataAccessException {
				connection.set(key.getBytes(), value.getBytes());
				if (expire > 0)
					connection.expire(key.getBytes(), expire);
				return true;
			}

		});
		return Boolean.valueOf(result.toString());
	}

	@Override
	public boolean delStr(String key) {
		Object result = redisTemplate.execute(new RedisCallback<Object>() {
			@Override
			public Object doInRedis(RedisConnection connection) throws DataAccessException {
				connection.del(key.getBytes());
				return true;
			}

		});
		return Boolean.valueOf(result.toString());
	}

	@Override
	public String getStr(String key) {
		String result = redisTemplate.execute(new RedisCallback<String>() {
			@Override
			public String doInRedis(RedisConnection connection) throws DataAccessException {
				byte[] bytes = connection.get(key.getBytes());
				if (bytes == null || bytes.length == 0)
					return null;
				return new String(bytes);
			}

		});
		return result;
	}

	@Override
	public boolean keyExists(String key) {
		String result = getStr(key);
		if (StringUtils.isEmpty(result)) {
			return false;
		} else {
			return true;
		}
	}

	@Override
	public boolean setNKey(String key){
		Object result=redisTemplate.execute(new RedisCallback<Boolean>() {
			@Override
			public Boolean doInRedis(RedisConnection connection) throws DataAccessException {
				byte[] bytes=key.getBytes();
				Boolean flag= connection.setNX(bytes, bytes);
				if(flag){
					connection.expire(bytes, 10);
				}
				return flag;
			}
		});
		return Boolean.valueOf(result.toString());
	}
}
```