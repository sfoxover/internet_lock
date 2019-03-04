package com.example.internetlock;

import android.content.Intent;
import android.os.Bundle;
import android.app.ActivityManager;
import android.content.Context;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.ActivityLifecycleListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

     new MethodChannel(getFlutterView(), "com.sfoxover.internetlock/lockapp").setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                      // Call lock to pin app
                      if (call.method.contentEquals("lockApp")) {
                        startLockTask();
                        result.success("OK");
                      }
                      else if (call.method.contentEquals("getLockedStatus")) {
                        // Check if app is currently pinned
                        boolean isLocked = false;
                        ActivityManager activityManager=(ActivityManager)getSystemService(Context.ACTIVITY_SERVICE);
                        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) { // When SDK version is 23
                           int lockTaskMode=activityManager.getLockTaskModeState();
                           isLocked = lockTaskMode != ActivityManager.LOCK_TASK_MODE_NONE ? true : false; 
                        }
                        else if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP && android.os.Build.VERSION.SDK_INT< android.os.Build.VERSION_CODES.M) {
                           // When SDK version <=21 and <23. This API is deprecated in 23.
                           isLocked = activityManager.isInLockTaskMode();
                        }
                        if(isLocked) {
                          result.success("locked");
                        }
                        else {
                          result.success("unlocked");
                        }
                      }
                      else if (call.method.contentEquals("unlockApp")) {
                        // Stop lock task
                        stopLockTask();
                        result.success("OK");
                      }
                    }
                });
  }
}
