```java
package com.bicon.base.controller;

import com.alibaba.fastjson.JSONObject;
import com.bicon.base.interceptors.MySecurityInterceptors;
import com.bicon.base.service.RedisService;
import com.bicon.base.service.UserService;
import com.bicon.base.utils.MD5Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Map;
import java.util.UUID;

@RestController
public class UserController extends SuperController {
    private static final Logger LOG = LoggerFactory.getLogger(UserController.class);

    @Resource(name = "userServiceImpl")
    protected UserService userService;

    @Resource(name = "redisServiceImpl")
    protected RedisService redisService;

    @RequestMapping(value="/sys/api/user/login")
    public Object login(HttpServletRequest request, HttpServletResponse response){
        try{
            Map<String, Object> paramsMap = getParameterMap(request);
            System.out.println("UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 0001:" + paramsMap);
            if(!"".equals(paramsMap.get("username")) && !"".equals(paramsMap.get("password"))){
                System.out.println(MD5Util.getMD5Str((String)paramsMap.get("username") + "@{" + (String)paramsMap.get("password") + "}"));
                paramsMap.put("password", MD5Util.getMD5Str((String)paramsMap.get("username") + "@{" + (String)paramsMap.get("password") + "}"));
            }else{
                throw new RuntimeException("用户名或密码不能为空");
            }

            // 为当前用户获取一个 UUID
            String key = UUID.randomUUID().toString().replaceAll("-", "");
            // 然后从数据库获取用户信息
            Map<String, Object> retObj = (Map<String, Object>)userService.login(request, paramsMap);

            // 查看当前 id 的用户是否已经登陆了，如果登陆了，删除已经登陆的信息
            String id = retObj.get("id") + "";
            String oldKey = redisService.getStr("key_" + id);
            if(!StringUtils.isEmpty(oldKey) && redisService.keyExists(oldKey)){
                //redisService.delStr(oldKey);
            }

            //redis中 存入 key_{id}:key  和 {key：sessionInfo} 有效时间 1小时
            redisService.setStr("key_" + id, key, 3600);
            redisService.setStr(key, JSONObject.toJSONString(retObj), 3600);
            System.out.println("登录成功: " + paramsMap + "\n\n" + retObj);
            retObj.put("key", key);
            retObj.remove("ALL_URLS");
            return retObj;

        }catch(Exception e){
            System.out.println("UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 0004: 登录异常");
            LOG.error("登录过程中异常", e);
        }
        return null;
    }

    @RequestMapping(value="/sys/api/user/logOut")
    public Object logOut(HttpServletRequest request, HttpServletResponse response){
        try{
            Map<String, Object> paramsMap = getParameterMap(request);
            System.out.println("UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 0001:" + paramsMap);
            String key = (String)paramsMap.get("key");
            String id = (String)paramsMap.get("id");
            if(!StringUtils.isEmpty(key) && !StringUtils.isEmpty(id)){
                String token = redisService.getStr("key_" + id);
                System.out.println( key + "\t" + token);
                if (key.equals(token)){
                    System.out.println(id + "\t" + redisService.getStr(token));
                    redisService.delStr("key_" + id);
                    redisService.delStr(key);
                }else{
                    LOG.info("用户信息不一致无法注销");
                    throw new RuntimeException("用户信息不一致无法注销");
                }
            }else{
                LOG.info("用户信息不完整无法注销");
                throw new RuntimeException("用户信息不完整无法注销");
            }
            return SUCCESS;
        }catch(Exception e){
            System.out.println("UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 0004: 登录异常");
            LOG.error("登录过程中异常", e);
        }
        return null;
    }

    @RequestMapping(value = {"/resetUnLoginUrls"}, method = RequestMethod.GET)
    public Object resetUnLoginUrls(HttpServletRequest request, HttpServletResponse response){
        try {
            MySecurityInterceptors.resetUnLoginUrls();
            LOG.info("unLoginUrls is reset!!!");
            return SUCCESS;
        } catch (Exception e) {
            LOG.error("ACTION---resetUnLoginUrls---EXCEPTION", e);
            throw new RuntimeException("resetUnLoginUrls 处理异常", e);
        }
    }


    @RequestMapping(value = {"/setupUserRole"}, method = RequestMethod.POST)
    public Object setupUserRole(HttpServletRequest request, HttpServletResponse response){
        Map<String, Object> paramsMap = getParameterMap(request);
        try {
            userService.setupUserRole(paramsMap);
            LOG.info("setupUserRole 处理成功: " + paramsMap);
            return SUCCESS;
        } catch (Exception e) {
            LOG.error("setupUserRole 处理异常: " + paramsMap, e);
            throw new RuntimeException("setupUserRole 处理异常", e);
        }
    }

    @RequestMapping(value = {"/setupRoleFunc"}, method = RequestMethod.POST)
    public Object setupRoleFunc(HttpServletRequest request, HttpServletResponse response){
        Map<String, Object> paramsMap = getParameterMap(request);
        try {
            userService.setupRoleFunc(paramsMap);
            LOG.info("setupRoleFunc 处理成功: " + paramsMap);
            return SUCCESS;
        } catch (Exception e) {
            LOG.error("setupRoleFunc处理异常: " + paramsMap, e);
            throw new RuntimeException("setupRoleFunc 处理异常", e);
        }
    }
}
```