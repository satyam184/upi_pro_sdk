package com.upipro.upi_pro_sdk

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.ByteArrayOutputStream
import java.util.Locale

class UpiProSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var timeoutRunnable: Runnable? = null
    private var activeRequestCode = 3901

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "upi_pro_sdk/methods")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInstalledApps" -> result.success(getInstalledUpiApps())
            "pay" -> startPayment(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getInstalledUpiApps(): List<Map<String, Any?>> {
        val hostActivity = activity ?: return emptyList()
        val pm = hostActivity.packageManager
        val queryIntent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
        val activities = pm.queryIntentActivities(queryIntent, 0)
        val unique = LinkedHashMap<String, Map<String, Any?>>()

        for (info in activities) {
            val packageName = info.activityInfo?.packageName ?: continue
            if (unique.containsKey(packageName)) {
                continue
            }
            val label = info.loadLabel(pm)?.toString() ?: packageName
            val icon = drawableToBase64(info.loadIcon(pm))
            unique[packageName] = mapOf(
                "name" to label,
                "packageName" to packageName,
                "icon" to icon,
            )
        }
        return unique.values.toList()
    }

    private fun startPayment(call: MethodCall, result: Result) {
        val hostActivity = activity
        if (hostActivity == null) {
            result.error("no_activity", "No foreground activity available.", null)
            return
        }
        if (pendingResult != null) {
            result.error("payment_in_progress", "Another UPI payment is already running.", null)
            return
        }

        val upiUri = call.argument<String>("upiUri")
        val targetAppId = call.argument<String>("targetAppId")
        val timeoutSeconds = call.argument<Int>("timeoutSeconds") ?: 30
        if (upiUri.isNullOrBlank()) {
            result.error("invalid_request", "UPI URI is required.", null)
            return
        }

        val uri = Uri.parse(upiUri)
        val intent = Intent(Intent.ACTION_VIEW, uri).apply {
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        if (!targetAppId.isNullOrBlank()) {
            intent.setPackage(targetAppId)
        }

        if (!canResolveIntent(intent)) {
            result.error("no_upi_app_found", "No compatible UPI app found.", null)
            return
        }

        pendingResult = result
        try {
            hostActivity.startActivityForResult(intent, activeRequestCode)
            scheduleTimeout(timeoutSeconds.coerceAtLeast(5))
        } catch (_: ActivityNotFoundException) {
            clearPending()
            result.error("no_upi_app_found", "Unable to launch selected UPI app.", null)
        } catch (ex: Exception) {
            clearPending()
            result.error("launch_failed", ex.message, null)
        }
    }

    private fun canResolveIntent(intent: Intent): Boolean {
        val hostActivity = activity ?: return false
        val pm = hostActivity.packageManager
        val handlers: List<ResolveInfo> = pm.queryIntentActivities(intent, 0)
        return handlers.isNotEmpty()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != activeRequestCode) {
            return false
        }
        val result = pendingResult ?: return true
        cancelTimeout()

        val response = data?.getStringExtra("response")
            ?: data?.getStringExtra("Status")
            ?: data?.dataString
            ?: ""

        val payload = mutableMapOf<String, Any?>(
            "rawResponse" to response,
        )

        if (resultCode == Activity.RESULT_CANCELED) {
            payload["statusHint"] = "failure"
            payload["failureType"] = "user_cancelled"
        }
        if (response.isBlank() && resultCode == Activity.RESULT_OK) {
            payload["statusHint"] = "unknown"
            payload["failureType"] = "app_not_responding"
        }

        clearPending()
        result.success(payload)
        return true
    }

    private fun scheduleTimeout(seconds: Int) {
        cancelTimeout()
        timeoutRunnable = Runnable {
            val current = pendingResult ?: return@Runnable
            clearPending()
            current.success(
                mapOf(
                    "statusHint" to "unknown",
                    "failureType" to "timeout",
                    "rawResponse" to "",
                ),
            )
        }
        mainHandler.postDelayed(timeoutRunnable!!, seconds * 1000L)
    }

    private fun cancelTimeout() {
        timeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        timeoutRunnable = null
    }

    private fun clearPending() {
        cancelTimeout()
        pendingResult = null
    }

    private fun drawableToBase64(drawable: Drawable?): String? {
        if (drawable == null) {
            return null
        }
        val bitmap = when (drawable) {
            is BitmapDrawable -> drawable.bitmap
            else -> {
                val width = drawable.intrinsicWidth.takeIf { it > 0 } ?: 96
                val height = drawable.intrinsicHeight.takeIf { it > 0 } ?: 96
                val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        val bytes = stream.toByteArray()
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        clearPending()
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
    }
}
