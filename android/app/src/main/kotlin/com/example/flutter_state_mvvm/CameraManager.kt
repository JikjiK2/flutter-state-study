package com.example.flutter_state_mvvm

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class CameraManager(private val context: Context) {
    private val CHANNEL = "com.example.camera/intent"
    private val REQUEST_IMAGE_CAPTURE = 1
    private lateinit var currentPhotoPath: String
    private lateinit var channel: MethodChannel

    fun setFlutterEngine(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    fun openCamera(activity: Activity) {
        val photoFile: File? = try {
            createImageFile(context)
        } catch (ex: IOException) {
            println("Temp image file creation error: ${ex.message}")
            channel.invokeMethod("cameraError", "Failed to create temp image file")
            null
        }

        photoFile?.also {
            val photoURI: Uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                it
            )

            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }

            intent.resolveActivity(context.packageManager)?.also {
                activity.startActivityForResult(intent, REQUEST_IMAGE_CAPTURE)
            } ?: run {
                println("Camera app not found.")
                channel.invokeMethod("cameraError", "Camera app not found")
                deleteTempImageFile(currentPhotoPath)
            }
        }
    }

    @Throws(IOException::class)
    private fun createImageFile(context: Context): File {
        val timeStamp: String = java.text.SimpleDateFormat("yyyyMMdd_HHmmss", java.util.Locale.getDefault()).format(java.util.Date())
        val imageFileName = "JPEG_${timeStamp}_"
        val storageDir: File? = context.getExternalFilesDir(android.os.Environment.DIRECTORY_PICTURES)

        storageDir?.mkdirs()

        val imageFile = File.createTempFile(
            imageFileName,
            ".jpg",
            storageDir
        )

        currentPhotoPath = imageFile.absolutePath
        return imageFile
    }

    private fun deleteTempImageFile(path: String) {
        val file = File(path)
        if (file.exists()) {
            try {
                val deleted = file.delete()
                if (deleted) {
                    println("Temp image file deleted successfully: $path")
                } else {
                    println("Temp image file deletion failed: $path")
                }
            } catch (e: Exception) {
                println("Error deleting temp image file $path: ${e.message}")
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_IMAGE_CAPTURE) {
            if (resultCode == Activity.RESULT_OK) {
                val imageFile = File(currentPhotoPath)
                if (imageFile.exists() && imageFile.length() > 0) {
                    println("Camera capture success, image path: $currentPhotoPath")
                    channel.invokeMethod("imageCaptured", currentPhotoPath)
                } else {
                    println("Camera capture success, but image file not found or is empty: $currentPhotoPath")
                    channel.invokeMethod("imageCaptured", null)
                    deleteTempImageFile(currentPhotoPath)
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                println("Camera capture canceled. Attempting to delete temp file.")
                deleteTempImageFile(currentPhotoPath)
                channel.invokeMethod("cameraCanceled", null)
            } else {
                println("Camera capture failed (result code: $resultCode). Attempting to delete temp file.")
                deleteTempImageFile(currentPhotoPath)
                channel.invokeMethod("cameraError", "Image capture failed with result code $resultCode")
            }
        }
    }
}
