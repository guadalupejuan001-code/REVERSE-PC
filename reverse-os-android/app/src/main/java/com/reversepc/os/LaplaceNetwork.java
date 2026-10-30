package com.reversepc.os;

import org.json.JSONObject;
import java.io.*;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import javax.net.ssl.HttpsURLConnection;

/** Read-only transport for the exact public U001 sources; no account or order API. */
final class LaplaceNetwork {
    static final String[] SOURCES={
        "https://api.exchange.coinbase.com/products/BTC-USD/ticker",
        "https://api.exchange.coinbase.com/products/BTC-USD/stats",
        "https://api.exchange.coinbase.com/products/BTC-USD/candles?granularity=300",
        "https://api.exchange.coinbase.com/products/BTC-USD/book?level=2",
        "https://api.exchange.coinbase.com/products/BTC-USD/trades",
        "https://api.exchange.coinbase.com/products/ETH-USD/ticker",
        "https://api.exchange.coinbase.com/products/BTC-EUR/ticker",
        "https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json"
    };
    static JSONObject read(String payload)throws Exception{
        JSONObject request=new JSONObject(payload);int source=request.getInt("source");
        if(source<0||source>=SOURCES.length)throw new IllegalArgumentException("Fuente Laplace desconocida");
        HttpsURLConnection connection=(HttpsURLConnection)new URL(SOURCES[source]).openConnection();
        connection.setRequestMethod("GET");connection.setInstanceFollowRedirects(false);
        connection.setConnectTimeout(5000);connection.setReadTimeout(6000);
        connection.setRequestProperty("Accept","application/json");
        connection.setRequestProperty("User-Agent","REVERSE-Laplace-U001/2.8");
        try{
            long deadline=System.nanoTime()+12000000000L;
            int status=connection.getResponseCode();
            if(status!=200)throw new IOException("Fuente no disponible (HTTP "+status+")");
            if(connection.getContentLengthLong()>1500000)throw new IOException("Lectura demasiado grande");
            ByteArrayOutputStream output=new ByteArrayOutputStream();
            try(InputStream input=connection.getInputStream()){
                byte[] bytes=new byte[16384];int count;
                while((count=input.read(bytes))!=-1){
                    if(System.nanoTime()>deadline)throw new IOException("La fuente excedió el tiempo de lectura");
                    if(Thread.currentThread().isInterrupted())throw new IOException("Lectura cancelada");
                    if(output.size()+count>1500000)throw new IOException("Lectura demasiado grande");
                    output.write(bytes,0,count);
                }
            }
            return new JSONObject().put("ok",true).put("status",status)
                .put("source",source).put("url",SOURCES[source])
                .put("body",output.toString("UTF-8"))
                .put("received_at_ms",System.currentTimeMillis());
        }finally{connection.disconnect();}
    }
}
