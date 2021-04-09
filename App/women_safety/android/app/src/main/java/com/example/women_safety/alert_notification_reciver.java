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

public class alert_notification_reciver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        alert();
    }
    public static void alert(){
        RequestQueue queue = Volley.newRequestQueue(MainActivity.mainContext);
        SharedPreferences myPrefs= MainActivity.mainContext.getSharedPreferences("myService", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = myPrefs.edit();
        Toast.makeText(MainActivity.mainContext, "alerting helpers", Toast.LENGTH_SHORT).show();
        String email=myPrefs.getString("email","test@gmail.com");
        String longitude=myPrefs.getString("longitude","0");
        String latitude=myPrefs.getString("latitude","0");
        String url ="http://192.168.43.57:3000/alert/"+email;
        StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Log.v("my response","from alert"+response);
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.v("my request","error came by "+error);
            }
        });
        queue.add(stringRequest);
        Log.v("my request","from alert");
        Toast.makeText(MainActivity.mainContext, "ending ride", Toast.LENGTH_SHORT).show();
        Intent stop = new Intent(MainActivity.mainContext, main_service.class);
        MainActivity.mainContext.stopService(stop);
        editor.putBoolean("isOn",false);
        editor.apply();
    }
}