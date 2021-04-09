package com.example.women_safety;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import com.example.women_safety.MainActivity;
//import android.support.v4.app.NotificationCompat;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.content.SharedPreferences;
import android.widget.Toast;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import java.util.Timer;
import java.util.TimerTask;

public class background_location_service extends Service implements LocationListener{

    boolean isGPSEnable = false;
    boolean isNetworkEnable = false;
    double latitude,longitude;
    LocationManager locationManager;
    Location location;
    private Handler mHandler = new Handler();
    private Timer mTimer = null;
    long notify_interval = 5*1000;
    RequestQueue queue ;
    public static String str_receiver = "servicetutorial.service.receiver";
    Intent intent;

    public background_location_service() {
    }

//    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    @Override
    public void onCreate() {
        super.onCreate();
        queue= Volley.newRequestQueue(MainActivity.mainContext);
        mTimer = new Timer();
        mTimer.schedule(new TimerTaskToGetLocation(),5,notify_interval);
        SharedPreferences myPrefs = getSharedPreferences("myService", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = myPrefs.edit();
        editor.putBoolean("backgroundService",true);
        editor.apply();
    }

    @Override
    public void onDestroy() {
        SharedPreferences myPrefs = getSharedPreferences("myService", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = myPrefs.edit();
        editor.putBoolean("backgroundService",false);
        editor.apply();
    }

    @Override
    public void onLocationChanged(Location location) {

    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    private void fn_getlocation(){
        locationManager = (LocationManager)getApplicationContext().getSystemService(LOCATION_SERVICE);
        isGPSEnable = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        isNetworkEnable = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);

        if (!isGPSEnable && !isNetworkEnable){
            Log.v("my net,gps","null");
        }else {
            if (isNetworkEnable){
                location = null;
                locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,1000,0,this);
                if (locationManager!=null){
                    location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                    if (location!=null){
                        Log.v("my net latitude",location.getLatitude()+"");
                        Log.v("my net longitude",location.getLongitude()+"");
                        latitude = location.getLatitude();
                        longitude = location.getLongitude();
                        fn_update(location);
                    }
                }
            }
            if (isGPSEnable){
                location = null;
                locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,1000,0,this);
                if (locationManager!=null){
                    location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
                    if (location!=null){
                        Log.v("my gps latitude",location.getLatitude()+"");
                        Log.v("my gps longitude",location.getLongitude()+"");
                        latitude = location.getLatitude();
                        longitude = location.getLongitude();
                        fn_update(location);
                    }
                }
            }
        }
    }

    private class TimerTaskToGetLocation extends TimerTask{
        @Override
        public void run() {
            Log.v("my bck ser","heyy");
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    fn_getlocation();
                    SharedPreferences myPrefs = getSharedPreferences("myService", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = myPrefs.edit();
                    String email=myPrefs.getString("email","test@gmail.com");
                    String longitude=myPrefs.getString("longitude","0");
                    String latitude=myPrefs.getString("latitude","0");
                    String url ="http://192.168.43.57:3000/user/"+email+"/"+latitude+"/"+longitude;
                    StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                            new Response.Listener<String>() {
                                @Override
                                public void onResponse(String response) {
                                    Log.v("my response","from user"+response);
                                    if(response!=" "){
                                        addNotification(response);
                                    }
                                }
                            }, new Response.ErrorListener(){
                        @Override
                        public void onErrorResponse(VolleyError error) {
                            Log.v("my request","error came by "+error);
                        }
                    });
                    queue.add(stringRequest);
                    Log.v("my request","from user");
                }
            });
        }
    }
    private void fn_update(Location location){
        SharedPreferences myPrefs = getSharedPreferences("myService", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = myPrefs.edit();
        editor.putString("latitude",location.getLatitude()+"");
        editor.putString("longitude",location.getLongitude()+"");
        Toast.makeText(getApplicationContext(), location.getLatitude()+"", Toast.LENGTH_SHORT).show();
        editor.apply();
    }
    private void addNotification(String email) {
//        NotificationCompat.Builder builder=
//                new NotificationCompat.Builder(this)
//                        .setSmallIcon(R.mipmap.logo)
//                        .setContentTitle("Its helping time")
//                        .setContentText(email+" requiere help");
//
//        Intent notificationIntent = new Intent(this, MainActivity.class);
//        PendingIntent contentIntent = PendingIntent.getActivity(this, 0, notificationIntent,
//                PendingIntent.FLAG_UPDATE_CURRENT);
//        builder.setContentIntent(contentIntent);
//
//        // Add as notification
//        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
//        manager.notify(0, builder.build());
    }
}