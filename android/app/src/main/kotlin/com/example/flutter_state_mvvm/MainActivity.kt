package com.example.flutter_state_mvvm

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var cameraManager: CameraManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        cameraManager = CameraManager(applicationContext)
        cameraManager.setFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.camera/intent").setMethodCallHandler { call, result ->
            if (call.method == "openCamera") {

                cameraManager.openCamera(this)
                result.success(null)
            }
            if (call.method == "openVideoCamera") {
                cameraManager.openVideoCamera(this)
                result.success(null)
            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        cameraManager.onActivityResult(requestCode, resultCode, data)
    }
}