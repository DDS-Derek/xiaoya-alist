package com.ddsrem.xiaoya_proxy;

public class XiaoyaProxyRun {
    public static void main(String[] args) {
        try {
            XiaoyaProxyServer.get().start();
            while (true) {
                Thread.sleep(10000);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
