package com.ddsrem.xiaoya_proxy;

public class XiaoyaProxyRun {
    public static void main(String[] args) {
        try {
            XiaoyaProxyServer proxyServer = XiaoyaProxyServer.get();
            proxyServer.start();
            System.out.println("XiaoyaProxyServer 启动成功！");
        } catch (Exception e) {
            System.err.println("XiaoyaProxyServer 启动失败，错误原因如下：");
            e.printStackTrace();
            System.exit(1);
        }

        Object lock = new Object();
        synchronized(lock) {
            while(true) {
                try {
                    lock.wait();
                } catch (InterruptedException ex) {
                    Thread.currentThread().interrupt();
                    System.err.println("主线程已中断，立即退出！");
                    System.exit(1);
                }
            }
        }
    }
}
