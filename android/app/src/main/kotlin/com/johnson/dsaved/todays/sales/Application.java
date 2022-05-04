package com.johnson.dsaved.todays.sales;

import androidx.multidex.MultiDexApplication;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
//import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class Application extends MultiDexApplication implements PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
//        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
//        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}