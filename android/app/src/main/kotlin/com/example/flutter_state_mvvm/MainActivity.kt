package com.example.flutter_state_mvvm

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var cameraManager: CameraManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Activity context 대신 applicationContext 사용
        cameraManager = CameraManager(applicationContext)
        cameraManager.setFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.camera/intent").setMethodCallHandler { call, result ->
            if (call.method == "openCamera") {
                // openCamera 메서드는 Activity를 필요로 하므로 여기서는 this(Activity context)를 전달해야 합니다.
                cameraManager.openCamera(this)
                result.success(null) // Flutter에 성공 응답 (필요에 따라)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        cameraManager.onActivityResult(requestCode, resultCode, data)
    }
}