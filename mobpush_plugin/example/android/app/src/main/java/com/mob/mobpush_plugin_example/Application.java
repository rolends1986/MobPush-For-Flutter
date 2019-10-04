package com.mob.mobpush_plugin_example;

import com.mob.MobSDK;

import io.flutter.app.FlutterApplication;

public class Application extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        //初始化MobSDK
        MobSDK.init(this);
    }
}
