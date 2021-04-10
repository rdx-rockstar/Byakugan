package com.example.women_safety;
import android.Manifest;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.content.Intent;
import android.content.Context;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import static android.Manifest.permission.RECORD_AUDIO;
import android.util.Log;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;

public class MainActivity extends FlutterActivity {
    public static Context mainContext;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        GeneratedPluginRegistrant.registerWith(this);
    }
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "service_channel")
                .setMethodCallHandler(
                        (call, result) -> {
                            SharedPreferences myPrefs = getSharedPreferences("myService", Context.MODE_PRIVATE);
                            SharedPreferences.Editor editor = myPrefs.edit();
                            switch (call.method) {
                                case "test":
                                    result.success("working");
                                    break;
                                case "setEmail":
                                    String email=call.argument("email");
                                    editor.putString("email",email);
                                    if(myPrefs.getBoolean("backgroundService",false)==false){
//                                        Intent intent = new Intent(MainActivity.this, background_location_service.class);
//                                        Log.v("my bck","starting bacground service");
//                                        startService(intent);
                                    }
                                    break;
                                case "getVictim":
                                    result.success(myPrefs.getString("victim","-"));
                                    break;
                                case "on_off":
                                    boolean flag=true;
                                    flag=flag && isAudioPermissionGranted();
                                    flag=flag && isLocationPermissionGranted();
                                    flag=flag && isInternetPermissionGranted();
                                    flag=flag && isInternetStatePermissionGranted();
                                    if(flag==false){break;}
                                    mainContext=MainActivity.this;
                                    Intent intent = new Intent(MainActivity.this, background_location_service.class);
                                    Log.v("my bck","starting bacground service");
                                    startService(intent);
                                    if(myPrefs.getBoolean("isOn",false)==false){
                                        Intent start = new Intent(MainActivity.this, main_service.class);
                                        startService(start);
                                        editor.putBoolean("isOn",true);
                                        editor.apply();
                                        result.success("1");
                                    }
                                    else{
                                        Intent stop = new Intent(MainActivity.this, main_service.class);
                                        stopService(stop);
                                        editor.putBoolean("isOn",false);
                                        editor.apply();
                                        result.success("1");
                                    }
                                    break;
                                default:
                                    result.notImplemented();
                            }
                        }
                );
    }
    public  boolean isLocationPermissionGranted() {
        if (checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            Log.v("my permissions", "Storage write Permission is granted");
        } else {
            Log.v("my permissions", "Storage write Permission is revoked and request is sent");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}, 1);
            return false;
        }
        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            Log.v("my permissions", "Storage read Permission is granted");
        } else {
            Log.v("my permissions", "Storage read Permission is revoked and request is sent");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
            return  false;
        }
        if (checkSelfPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            Log.v("my permissions", "Storage read Permission is granted");
        } else {
            Log.v("my permissions", "Storage read Permission is revoked and request is sent");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_BACKGROUND_LOCATION}, 1);
            return false;
        }
        return true;
    }
    public boolean isAudioPermissionGranted() {
        if (checkSelfPermission(RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED) {
            Log.v("permissions", "Audio Permission is granted");
        } else {
            Log.v("permissions", "Audio Permission is revoked");
            ActivityCompat.requestPermissions(this, new String[]{RECORD_AUDIO}, 1);
            return false;
        }
        return true;
    }

    public boolean isInternetPermissionGranted() {
        if (checkSelfPermission(Manifest.permission.INTERNET)
                == PackageManager.PERMISSION_GRANTED) {
            Log.v("permissions", "Internet Permission is granted");
        }
        else{
            Log.v("permissions", "Internet Permission is revoked");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.INTERNET}, 1);
            return false;
        }
        return true;
    }

    public boolean isInternetStatePermissionGranted() {
        if (checkSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE)
                == PackageManager.PERMISSION_GRANTED) {
            Log.v("permissions", "Internet access Permission is granted");
        }
        else{
            Log.v("permissions", "Internet Access Permission is revoked");
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_NETWORK_STATE}, 1);
            return false;
        }
        return true;
    }
    @Override
    public void onRequestPermissionsResult(int requestCode,@NonNull String[] permissions,@NonNull int[] grantResults){
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        isLocationPermissionGranted();
        isAudioPermissionGranted();
        isInternetPermissionGranted();
        isInternetStatePermissionGranted();
    }
}