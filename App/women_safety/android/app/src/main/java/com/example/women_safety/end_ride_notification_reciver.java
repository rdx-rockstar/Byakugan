package com.example.women_safety;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;
import android.content.SharedPreferences;
import com.example.women_safety.MainActivity;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import android.util.Log;

public class end_ride_notification_reciver extends BroadcastReceiver{
    RequestQueue queue = Volley.newRequestQueue(MainActivity.mainContext);
    SharedPreferences myPrefs;
    @Override
    public void onReceive(Context context, Intent intent) {
        myPrefs= MainActivity.mainContext.getSharedPreferences("myService", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = myPrefs.edit();
        String email=myPrefs.getString("email","test@gmail.com");
        String longitude=myPrefs.getString("longitude","0");
        String latitude=myPrefs.getString("latitude","0");
        String url ="http://192.168.43.57:3000/endRide/"+email;
        StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Log.v("my response","from endride "+response);
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.v("my request","error came by "+error);
            }
        });
        queue.add(stringRequest);
        Log.v("my request","from endRide");
        Toast.makeText(context, "end ride", Toast.LENGTH_SHORT).show();
        Intent stop = new Intent(MainActivity.mainContext, main_service.class);
        MainActivity.mainContext.stopService(stop);
        editor.putBoolean("isOn",false);
        editor.apply();
    }
}