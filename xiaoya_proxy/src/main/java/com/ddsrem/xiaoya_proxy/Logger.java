package com.ddsrem.xiaoya_proxy;

public class Logger {
    static boolean dbg = true;
    
    public static void log(String message, boolean force) {
        if(!dbg && !force){
            return;
        }
        System.out.println(message);
    }
    
    public static void log(String message) {
        Logger.log(message, false);
    }
}  
