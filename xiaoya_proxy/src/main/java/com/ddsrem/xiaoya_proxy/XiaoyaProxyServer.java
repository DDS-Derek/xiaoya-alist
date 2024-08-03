package com.ddsrem.xiaoya_proxy;

import java.io.InputStream;
import java.util.Map;
import java.io.IOException;

public class XiaoyaProxyServer extends NanoHTTPD {

    private static class Loader {
        static volatile XiaoyaProxyServer INSTANCE = new XiaoyaProxyServer(9988);
    }
    
    public XiaoyaProxyServer(int port) {
        super(port);
    }

    public static XiaoyaProxyServer get() {
        return Loader.INSTANCE;
    }

    @Override
    public Response serve(IHTTPSession session) {
        try {
            Map<String, String> params = session.getParms();
            Map<String, String> headers = session.getHeaders();
            for (Map.Entry<String, String> entry : headers.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                if (!params.containsKey(key)) {
                    params.put(key, value);
                }
            }
            Object[] rs = XiaoyaProxyHandler.proxy(params);
            return rs[0] instanceof Response ? (Response) rs[0] : newChunkedResponse(Response.Status.lookup((Integer) rs[0]), (String) rs[1], (InputStream) rs[2]);
        } catch (Exception e) {
            return newFixedLengthResponse(Response.Status.lookup(500), MIME_PLAINTEXT, e.getMessage());
        }
    }

    @Override
    public void start() throws IOException {
        if(!super.isAlive()) {
            super.start();
        }
    }
    
    @Override
    public void stop() {
        super.stop();
    }
}
