# DEMO

# 后端部分

## 首先要引入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

## 组成

- 一个websocket的配置类，实现WebSocketMessageBrokerConfigurer 接口（也有说继承：AbstractWebSocketMessageBrokerConfigurer）
  - 这个配置类，需要这两个注解
    - @Configuration  表示代替XML配置
    - @EnableWebSocketMessageBroker 表示开启使用STOMP协议来传输基于代理的消息，Broker就是代理的意思
  - 其中有两点需要配置的（实现两个方法）
    - configureMessageBroker(MessageBrokerRegistry config) 
      - 仿写的DEMO里面有这一个####暂未发现作用
      - 用来配置消息代理，由于我们是实现推送功能，这里的消息代理是/topic
    - registerStompEndpoints(StompEndpointRegistry registry)
      - 表示注册STOMP协议的节点，并指定映射的UR
      - 同时指定使用SockJS协议。 
  - 完整代码
  ```java
  import org.springframework.context.annotation.Configuration;
  import org.springframework.messaging.simp.config.MessageBrokerRegistry;
  import org.springframework.web.socket.config.annotation.AbstractWebSocketMessageBrokerConfigurer;
  import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
  import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
  import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
  
  @Configuration
  @EnableWebSocketMessageBroker
  public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
  
      //@Override
      public void configureMessageBroker(MessageBrokerRegistry config) {
          config.enableSimpleBroker("/topic");  // 推送消息的时候，代理是 /topic .前端会订阅 /topic :stompClient.subscribe('/topic/send', function(msg)
          config.setApplicationDestinationPrefixes("/app"); //前端向后端发送消息的前缀 为 /app  
                                                            //贴一段前端代码： stompClient.send("/app/send", {}, JSON.stringify({'message':$scope.data.message}));
                                                            // 这里的路径是 /app/send ,其中 send后面可以看到是什么
      }

      
      // 前端与 /my-websocket 建立连接()  这里贴一段前端代码： ocket = new SockJS('https://localhost:443/web/my-websocket'); 里面 /web这一层是 整个项目的统一前缀
      //@Override
      public void registerStompEndpoints(StompEndpointRegistry registry) {
          registry.addEndpoint("/my-websocket").setAllowedOrigins("*").withSockJS();
          // 这里默认支持了 SockJS 库，所以前端也要使用对应的库
      }
  
  }
  ```
- 我们还需要一个消息实体 DTO
  - 很简单的类
  ```java
  public class SocketMessage {
    public String message;
    public String date;
  }
  ```
- 然后是WebSocket的Controller
  - 需要以下注解
    - @Controller  表示这是个controller
    - @EnableScheduling  支持计划任务
    - @SpringBootApplication 注解Spring boot
  - 完整代码如下
  ```java
  import java.text.DateFormat;
  import java.text.SimpleDateFormat;
  import java.util.Date;
  
  import org.springframework.beans.factory.annotation.Autowired;
  import org.springframework.boot.SpringApplication;
  import org.springframework.boot.autoconfigure.SpringBootApplication;
  import org.springframework.messaging.handler.annotation.MessageMapping;
  import org.springframework.messaging.handler.annotation.SendTo;
  import org.springframework.messaging.simp.SimpMessagingTemplate;
  import org.springframework.scheduling.annotation.EnableScheduling;
  import org.springframework.scheduling.annotation.Scheduled;
  import org.springframework.stereotype.Controller;
  import org.springframework.web.bind.annotation.GetMapping;
  
  @Controller
  @EnableScheduling
  @SpringBootApplication
  public class App {
  
      public static void main(String[] args) {
          SpringApplication.run(App.class, args);
      }
  
      @Autowired  //它可以对类成员变量、方法及构造函数进行标注，完成自动装配的工作。
      private SimpMessagingTemplate messagingTemplate; //
  
      @GetMapping("/") //组合注解，是@RequestMapping(method = RequestMethod.GET)的缩写
      public String index() {
          return "index";
      }
  
      @MessageMapping("/send")  //前面知道，WebSocket有个请求前缀是 /app,随意这里的完整Mapping是 /app/send
      @SendTo("/topic/send")  // 这个发送给broker，前端订阅broker地址
      public SocketMessage send(SocketMessage message) throws Exception {
          DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
          message.date = df.format(new Date());
          return message;
      }
  
      @Scheduled(fixedRate = 1000) // Spring的定时任务
      @SendTo("/topic/callback")
      public Object callback() throws Exception {
          // 发现消息
          DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
          messagingTemplate.convertAndSend("/topic/callback", df.format(new Date()));
          return "callback";
      }
  }
  ```

# 前端部分

## 引入JS

- sockjs.js
- stomp.js - 这个库不是单纯的Stomp 客户端。它旨在WebSockets上运行而不是TCP。基本上，WebSocket协议需要在浏览器客户端和服务端之间进行握手，确保浏览器的“same-origin”（同源）安全模型仍然有效。
- 备注MissionLee： 这两个js已经存档

## 主要使用方法

```js
var socket = new SockJS('https://localhost:443/web/my-websocket'); //连接后端的WebSocketServer

var stompClient = Stomp.over(socket); // 可以用 SockJS，也可以用原生WebSocket

// 建立连接，订阅消息
stompClient.connect({}, function(frame) {
                // 注册发送消息
                stompClient.subscribe('/topic/send', function(msg) {
                    //处理
                    //在Java代码中，我们会在需要的时候，向 /topic这个broker发送消息
                    //在js中，订阅这个消息，broker会把自己收到的消息发送给订阅者
                });
                // 注册推送时间回调
                stompClient.subscribe('/topic/callback', function(r) {
                    //处理
                });
            });
// 发送消息
stompClient.send("/app/send", {}, JSON.stringify({
                'message' : $scope.data.message
            }));
// 关闭
stompClient.disconnect();
```

- DEMO

```html
<!DOCTYPE html>
<html>
<head>
		<meta charset="UTF-8">
	
<title>玩转spring boot——websocket</title>
<script src="//cdn.bootcss.com/angular.js/1.5.6/angular.min.js"></script>
<script src="js/sockjs.js"></script>
<script src="https://cdn.bootcss.com/stomp.js/2.3.3/stomp.min.js"></script>
<script type="text/javascript">
    /*<![CDATA[*/

    var stompClient = null;

    var app = angular.module('app', []);
    app.controller('MainController', function($rootScope, $scope, $http) {

        $scope.data = {
            //连接状态
            connected : false,
            //消息
            message : '',
            rows : []
        };

        //连接
        $scope.connect = function() {
            var socket = new SockJS('https://localhost:443/web/my-websocket');
            // 与这个websocket建立连接
            stompClient = Stomp.over(socket);
            // stomp是websocket的一个格式
            stompClient.connect({}, function(frame) {
                // 注册发送消息
                stompClient.subscribe('/topic/send', function(msg) {
                    $scope.data.rows.push(JSON.parse(msg.body));
                    $scope.data.connected = true;
                    $scope.$apply();
                });
                // 注册推送时间回调
                stompClient.subscribe('/topic/callback', function(r) {
                    $scope.data.time = '当前服务器时间：' + r.body;
                    $scope.data.connected = true;
                    $scope.$apply();
                });

                $scope.data.connected = true;
                $scope.$apply();
            });
        };

        $scope.disconnect = function() {
            if (stompClient != null) {
                stompClient.disconnect();
            }
            $scope.data.connected = false;
        }

        $scope.send = function() {
            stompClient.send("/app/send", {}, JSON.stringify({
                'message' : $scope.data.message
            }));
        }
    });
    /*]]>*/
</script>
</head>
<body ng-app="app" ng-controller="MainController">

    <h2>玩转spring boot——websocket</h2>
    <h4>
        出处：刘冬博客 <a href="http://www.cnblogs.com/goodhelper">http://www.cnblogs.com/goodhelper</a>
    </h4>

    <label>WebSocket连接状态:</label>
    <button type="button" ng-disabled="data.connected" ng-click="connect()">连接</button>
    <button type="button" ng-click="disconnect()"
        ng-disabled="!data.connected">断开</button>
    <br />
    <br />
    <div ng-show="data.connected">
        <label>{{data.time}}</label> <br /> <br /> <input type="text"
            ng-model="data.message" placeholder="请输入内容..." />
        <button ng-click="send()" type="button">发送</button>
        <br /> <br /> 消息列表： <br />
        <table>
            <thead>
                <tr>
                    <th>内容</th>
                    <th>时间</th>
                </tr>
            </thead>
            <tbody>
                <tr ng-repeat="row in data.rows">
                    <td>{{row.message}}</td>
                    <td>{{row.date}}</td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
```