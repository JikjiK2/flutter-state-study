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
    private val REQUEST_VIDEO_CAPTURE = 2
    private lateinit var currentVideoPath: String
    private lateinit var currentPhotoPath: String
    private lateinit var channel: MethodChannel

    fun setFlutterEngine(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    fun openCamera(activity: MainActivity) {
        val photoFile: File? = try {
            createMediaFile(context, "jpg")
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
                deleteTempFile(currentPhotoPath)
            }
        }
    }

    fun openVideoCamera(activity: MainActivity) {
        val videoFile: File? = try {
            createMediaFile(context, "mp4")
        } catch (ex: IOException) {
            println("Temp video file creation error: ${ex.message}")
            channel.invokeMethod("cameraError", "Failed to create temp video file")
            null
        }

        videoFile?.also {
            val videoURI: Uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                it
            )

            val intent = Intent(MediaStore.ACTION_VIDEO_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, videoURI)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }

            intent.resolveActivity(context.packageManager)?.also {
                activity.startActivityForResult(intent, REQUEST_VIDEO_CAPTURE)
            } ?: run {
                println("Video camera app not found.")
                channel.invokeMethod("cameraError", "Video camera app not found")
                deleteTempFile(currentVideoPath)
            }
        }

    }


    @Throws(IOException::class)
    private fun createMediaFile(context: Context, extension: String): File {

        val timeStamp: String =
            java.text.SimpleDateFormat("yyyyMMdd_HHmmss", java.util.Locale.getDefault())
                .format(java.util.Date())
        val fileName = "${if (extension == "jpg") "JPEG" else "MP4"}_${timeStamp}_"

        val storageDir: File? =
            context.getExternalFilesDir(android.os.Environment.DIRECTORY_PICTURES)

        storageDir?.mkdirs()

        val mediaFile = File.createTempFile(
            fileName,
            ".$extension",
            storageDir
        )

        if (extension == "jpg") currentPhotoPath = mediaFile.absolutePath
        if (extension == "mp4") currentVideoPath = mediaFile.absolutePath

        return mediaFile
    }

    private fun deleteTempFile(path: String) {
        val file = File(path)
        if (file.exists()) {
            try {
                val deleted = file.delete()
                if (deleted) {
                    println("Temp file deleted successfully: $path")
                } else {
                    println("Temp file deletion failed: $path")
                }
            } catch (e: Exception) {
                println("Error deleting temp file $path: ${e.message}")
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        when (requestCode) {
            REQUEST_IMAGE_CAPTURE -> {
                if (resultCode == Activity.RESULT_OK) {
                    val imageFile = File(currentPhotoPath)
                    if (imageFile.exists() && imageFile.length() > 0) {
                        println("Camera capture success, image path: $currentPhotoPath")
                        channel.invokeMethod("imageCaptured", currentPhotoPath)
                    } else {
                        println("Camera capture success, but image file not found or is empty: $currentPhotoPath")
                        channel.invokeMethod("imageCaptured", null)
                        deleteTempFile(currentPhotoPath)
                    }
                } else if (resultCode == Activity.RESULT_CANCELED) {
                    println("Camera capture canceled. Attempting to delete temp file.")
                    deleteTempFile(currentPhotoPath)
                    channel.invokeMethod("cameraCanceled", null)
                } else {
                    println("Camera capture failed (result code: $resultCode). Attempting to delete temp file.")
                    deleteTempFile(currentPhotoPath)
                    channel.invokeMethod(
                        "cameraError",
                        "Image capture failed with result code $resultCode"
                    )
                }
            }

            REQUEST_VIDEO_CAPTURE -> {
                if (resultCode == Activity.RESULT_OK) {
                    val videoFile = File(currentVideoPath)
                    if (videoFile.exists() && videoFile.length() > 0) {
                        println("Video capture success, video Uri: $currentVideoPath")
                        channel.invokeMethod("videoCaptured", currentVideoPath)

                    } else {
                        println("Camera capture success, but image file not found or is empty: $currentVideoPath")
                        channel.invokeMethod("videoCaptured", null)
                        deleteTempFile(currentVideoPath)
                    }
                } else {
                    println("Video capture canceled or failed (result code: $resultCode). Attempting to delete temp video file (if created).")
                    deleteTempFile(currentVideoPath)
                    if (resultCode == Activity.RESULT_CANCELED) {
                        channel.invokeMethod("videoCanceled", null)
                    } else {
                        channel.invokeMethod(
                            "cameraError",
                            "Video capture failed with result code $resultCode"
                        )
                    }
                }
            }
        }
    }
}
