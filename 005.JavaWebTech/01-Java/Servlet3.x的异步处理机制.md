Servlet3发布好几年了，又有多少人知道它的新特性呢？下面简单介绍下。

主要增加了以下特性：

1、异步处理支持

2、可插性支持

3、注解支持，零配置，可不用配置web.xml

...



**异步处理是什么鬼？**



**直接操起键盘干。**

```java

**@WebServlet(name = "index", urlPatterns = { "/" }, asyncSupported = true)**

public class IndexServlet extends HttpServlet {



    @Override

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        resp.setContentType("text/html");

        try {

            PrintWriter out = resp.getWriter();

            out.println("servlet started.<br/>");

            out.flush();



            AsyncContext asyncContext = req.startAsync();

            asyncContext.addListener(getListener());

            asyncContext.start(new IndexThread(asyncContext));



            out.println("servlet end.<br/>");

            out.flush();



        } catch (Exception e) {

            e.printStackTrace();

        }

    }



    /**

     \* 异步线程结果监听

     \* @author javastack

     \* @return

     */

    private AsyncListener getListener() {

        return new AsyncListener() {

            public void onComplete(AsyncEvent asyncEvent) throws IOException {

                asyncEvent.getSuppliedResponse().getWriter().close();

                System.out.println("thread completed.");

            }



            public void onError(AsyncEvent asyncEvent) throws IOException {

                System.out.println("thread error.");

            }



            public void onStartAsync(AsyncEvent asyncEvent) throws IOException {

                System.out.println("thread started.");

            }



            public void onTimeout(AsyncEvent asyncEvent) throws IOException {

                System.out.println("thread timeout.");

            }

        };

    }

}



public class IndexThread implements Runnable {



    private AsyncContext asyncContext;



    public IndexThread(AsyncContext asyncContext) {

        this.asyncContext = asyncContext;

    }



    public void run() {

        try {

            Thread.sleep(5000);



            PrintWriter out = asyncContext.getResponse().getWriter();

            out.println("hello servlet3.<br/>");

            out.flush();



            asyncContext.complete();



        } catch (Exception e) {

            e.printStackTrace();

        }

    }

}

```

```

访问localhost:8080/test

页面首先输出

servlet started.
servlet end.

过了5秒后再输出



hello servlet3.



可以看出servlet立马返回了，但没有关闭响应流，只是把response响应传给了线程，线程再继续输出，我们可以将比较费资源消耗时间的程序放到异步去做，这样很大程序上节省了servlet资源。



Springmvc3.2开始也加入了servlet3异步处理这个特性，有兴趣的同学可以去研究下。



从上面的servlet注解也可以看出来，servlet3完全解放了web.xml配置，通过注解可以完全代替web.xml配置。
```