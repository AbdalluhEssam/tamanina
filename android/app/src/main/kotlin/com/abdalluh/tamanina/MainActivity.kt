package com.abdalluh.tamanina

import android.app.KeyguardManager
import android.app.NotificationManager
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applyLockScreenMode(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        applyLockScreenMode(intent)
    }

    override fun onStop() {
        super.onStop()
        showOverLockScreen(false)
    }

    // Only the adhan full-screen launch may appear over the lock screen.
    private fun applyLockScreenMode(intent: Intent?) {
        showOverLockScreen(intent?.getBooleanExtra(AdhanPlaybackService.EXTRA_ALARM_LAUNCH, false) == true)
    }

    private fun showOverLockScreen(show: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.abdalluh.tamanina/adhan_alarms"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "replace" -> runCatching {
                    AdhanAlarms.replace(applicationContext, call.arguments as String)
                }.onSuccess { result.success(it) }.onFailure {
                    result.error("adhan_schedule", "Could not save adhan alarms", null)
                }
                "status" -> result.success(AdhanPlaybackService.status())
                "diagnostics" -> result.success(AdhanAlarms.diagnostics(applicationContext))
                "scheduleTest" -> {
                    val args = call.arguments as? Map<*, *>
                    result.success(
                        AdhanAlarms.scheduleTest(
                            applicationContext,
                            args?.get("title") as? String ?: "Adhan test",
                            args?.get("stopLabel") as? String ?: "Stop",
                            (args?.get("volume") as? Number)?.toDouble() ?: 1.0,
                        ),
                    )
                }
                "openBatterySettings" -> {
                    runCatching {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                    }.onFailure {
                        runCatching {
                            startActivity(
                                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")),
                            )
                        }
                    }
                    result.success(null)
                }
                "stop" -> {
                    AdhanPlaybackService.stop(applicationContext)
                    result.success(null)
                }
                "closeOverLockScreen" -> {
                    val locked = getSystemService(KeyguardManager::class.java)?.isKeyguardLocked == true
                    if (locked) finishAndRemoveTask()
                    result.success(locked)
                }
                "canUseFullScreenIntent" -> result.success(
                    Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
                        getSystemService(NotificationManager::class.java).canUseFullScreenIntent(),
                )
                "openFullScreenIntentSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        runCatching {
                            startActivity(
                                Intent(
                                    Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                                    Uri.parse("package:$packageName"),
                                ),
                            )
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
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
