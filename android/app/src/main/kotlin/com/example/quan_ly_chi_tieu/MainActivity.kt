package com.example.quan_ly_chi_tieu

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val route = intent?.getStringExtra("route")
        if (route != null) {
            flutterEngine.navigationChannel.pushRoute(route)
        }
    }
}
