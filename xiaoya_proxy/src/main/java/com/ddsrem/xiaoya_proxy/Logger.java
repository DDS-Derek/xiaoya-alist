package com.ddsrem.xiaoya_proxy;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class Logger {
    static boolean dbg = false;
    public static void log(String message, boolean force) {
        if(!dbg && !force){
            return;
        }
        String filePath = "/storage/emulated/0/TV/log.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(message);
            writer.newLine();
            writer.newLine();
        } catch (IOException e) {
            System.err.println("Error writing to log file: " + e.getMessage());
        }
    }
    
    public static void log(String message) {
        Logger.log(message, false);
    }
}  
