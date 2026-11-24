package com.abdalluh.tamanina

import android.appwidget.AppWidgetManager
import android.os.Build
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.abdalluh.tamanina/adhan_alarms"
        ).setMethodCallHandler { call, result ->
            if (call.method != "replace") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            runCatching {
                AdhanAlarms.replace(applicationContext, call.arguments as String)
            }.onSuccess { result.success(it) }.onFailure {
                result.error("adhan_schedule", "Could not save adhan alarms", null)
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.abdalluh.tamanina/home_widgets"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "publish" -> {
                    val payload = call.arguments as? String
                    if (payload == null) {
                        result.error("invalid_data", "Widget data must be a JSON string", null)
                    } else {
                        WorshipWidgetProvider.publish(applicationContext, payload)
                        result.success(null)
                    }
                }
                "publishTasbeeh" -> {
                    val count = call.arguments as? Int
                    if (count == null) {
                        result.error("invalid_count", "Tasbeeh count must be an integer", null)
                    } else {
                        WorshipWidgetProvider.publishTasbeeh(applicationContext, count)
                        result.success(null)
                    }
                }
                "pin" -> {
                    val manager = AppWidgetManager.getInstance(this)
                    val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        manager.isRequestPinAppWidgetSupported
                    val kind = WorshipWidgetKind.entries.firstOrNull {
                        it.name.equals(call.arguments as? String, ignoreCase = true)
                    } ?: WorshipWidgetKind.PRAYER
                    result.success(supported && manager.requestPinAppWidget(
                        WorshipWidgetProvider.component(this, kind), null, null
                    ))
                }
                else -> result.notImplemented()
            }
        }
    }
}
