package com.example.women_safety;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.widget.Toast;
import android.util.Log;
import android.widget.Toast;
import androidx.core.app.ActivityCompat;
import java.util.Arrays;
import java.util.Timer;
import java.util.TimerTask;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import java.util.ArrayList;
import java.util.Locale;
import android.media.AudioManager;
import android.os.Bundle;
import com.example.women_safety.alert_notification_reciver;
import android.content.SharedPreferences;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.women_safety.MainActivity;

public class main_service extends Service{
    final Handler timer_handler = new Handler();
    AudioManager audioManager;
    int timer_duration = 5;
    public Intent speechRecognizerIntent;
    SensorManager mSensorManager;
    public SpeechRecognizer speechRecognizer;
    public Timer timer;
    public TimerTask timerTask;
    RequestQueue queue = Volley.newRequestQueue(MainActivity.mainContext);
    private static final String TAG = "my main service";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        audioManager=(AudioManager)getSystemService(Context.AUDIO_SERVICE);
        audioManager.setStreamMute(AudioManager.STREAM_MUSIC, true);
        initiateSpeechRecognizer();
        startTimer();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.v(TAG, "service controller started");
        String NOTIFICATION_CHANNEL_ID = "com.example.women_safety";
        String channelName = "My Main Service";
        NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE);
        chan.setLightColor(Color.BLUE);
        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        assert manager != null;
        manager.createNotificationChannel(chan);
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
        Intent alertBroadcastIntent = new Intent(this, alert_notification_reciver.class);
        PendingIntent alertIntent = PendingIntent.getBroadcast(this,
                0, alertBroadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        Intent endRideBroadcastIntent = new Intent(this, end_ride_notification_reciver.class);
        PendingIntent endIntent = PendingIntent.getBroadcast(this,
                0, endRideBroadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        Notification notification = new Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(R.mipmap.logo)
                .setContentTitle("Your Ride Manager")
                .setContentText("Wish you a happy ride")
                .setContentIntent(pendingIntent)
                .addAction(R.mipmap.ic_launcher, "Alert", alertIntent)
                .addAction(R.mipmap.ic_launcher, "End Ride", endIntent)
                .build();
        startForeground(1337, notification);
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        speechRecognizer.stopListening();
        speechRecognizer.destroy();
        audioManager.setStreamMute(AudioManager.STREAM_MUSIC, false);
        speechRecognizer=null;
        stoptimertask();
        Log.v(TAG, "Service on Destroy");
        stopForeground(true);
        super.onDestroy();
    }

    public void initiateSpeechRecognizer(){
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this);
        speechRecognizerIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        speechRecognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        speechRecognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
        speechRecognizer.setRecognitionListener(new RecognitionListener() {
            @Override
            public void onReadyForSpeech(Bundle bundle) {}
            @Override
            public void onBeginningOfSpeech() {
                Log.v("my speech","BeginningOfSpeech...");
            }
            @Override
            public void onRmsChanged(float v) {}
            @Override
            public void onBufferReceived(byte[] bytes) {Log.v("my speech","buff...");}
            @Override
            public void onEndOfSpeech(){
                Log.v("my speech","eos...");
                speechRecognizer.stopListening();
            }

            @Override
            public void onError(int i){
                Log.v("my speech","err..."+i);
                speechRecognizer.stopListening();
                resetSpeechRecognizer();
            }
            @Override
            public void onResults(Bundle bundle) {
                ArrayList<String> matches = bundle.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                String text = "";
                for (String result : matches) {
                    text += result + " ";
                }
                Log.v("my speech",text);
                if(text.contains("help")){
                    alert_notification_reciver.alert();
                }
                speechRecognizer.stopListening();
                speechRecognizer.startListening(speechRecognizerIntent);
            }
            @Override
            public void onPartialResults(Bundle bundle) {
                Log.v("my speech","partial...");
            }
            @Override
            public void onEvent(int i, Bundle bundle) {
                Log.v("my speech","event...");
            }
        });
        speechRecognizer.startListening(speechRecognizerIntent);
    }

    public void startRecogizer(){
        try{
            speechRecognizer.stopListening();
        }catch (Exception e){
            Log.v("my err",e.getMessage());
        }
        Log.v("my recognizer","starting");
        speechRecognizer.startListening(speechRecognizerIntent);
    }

    private void resetSpeechRecognizer() {
        if(speechRecognizer != null)
            speechRecognizer.destroy();
        initiateSpeechRecognizer();
    }

    public void startTimer() {
        timer = new Timer();
        initializeTimerTask();
        timer.schedule(timerTask, timer_duration*1000,timer_duration*1000);
    }

    public void stoptimertask() {
        Log.v(TAG,"timer stopped");
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }

    public void initializeTimerTask() {
        timerTask = new TimerTask(){
            public void run() {
                timer_handler.post(new Runnable(){
                    public void run() {
                        Log.v("my timer","timer here");
                        SharedPreferences myPrefs = getSharedPreferences("myService", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = myPrefs.edit();
                        String email=myPrefs.getString("email","test@gmail.com");
                        String longitude=myPrefs.getString("longitude","0");
                        String latitude=myPrefs.getString("latitude","0");
                        if(latitude.equals("0")&&longitude.equals("0")){
                            return;
                        }
                        String url ="http://192.168.43.57:3000/rider/"+email;
                        StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                                new Response.Listener<String>() {
                                    @Override
                                    public void onResponse(String response) {
                                        Log.v("my response","from rider"+response);
                                    }
                                }, new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError error) {
                                Log.v("my request","error came by :"+error);
                            }
                        });
                        queue.add(stringRequest);
                        Log.v("my request","from rider");
                    }
                });
            }
        };
    }
}

