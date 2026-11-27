package com.abdalluh.tamanina

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.PowerManager
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

internal data class AdhanAlarm(
    val id: Int,
    val at: Long,
    val title: String,
    val stopLabel: String,
    val volume: Float,
    val vibrate: Boolean,
    val route: String = "/prayer-times",
    val soundPath: String? = null,
) {
    fun encode() = JSONObject().apply { soundPath?.let { put("soundPath", it) } }.put("id", id).put("at", at).put("title", title)
        .put("stopLabel", stopLabel).put("volume", volume.toDouble()).put("vibrate", vibrate)
        .put("route", route)

    companion object {
        fun decode(json: JSONObject) = AdhanAlarm(
            json.getInt("id"), json.getLong("at"), json.getString("title"),
            json.getString("stopLabel"), json.getDouble("volume").toFloat().coerceIn(0f, 1f),
            json.getBoolean("vibrate"), json.optString("route", "/prayer-times"),
            json.optString("soundPath", "").ifEmpty { null },
        )
    }
}

/** Keeps the last few adhan outcomes so the app can show why nothing played. */
internal object AdhanLog {
    private const val KEY = "log"

    private fun prefs(context: Context) =
        context.getSharedPreferences("tamanina_adhan_log", Context.MODE_PRIVATE)

    fun record(context: Context, message: String) {
        runCatching {
            val old = JSONArray(prefs(context).getString(KEY, "[]") ?: "[]")
            val next = JSONArray()
            next.put(JSONObject().put("at", System.currentTimeMillis()).put("message", message))
            for (i in 0 until minOf(old.length(), 7)) next.put(old.getJSONObject(i))
            prefs(context).edit().putString(KEY, next.toString()).apply()
        }
        Log.i("TamaninaAdhan", message)
    }

    fun read(context: Context): List<Map<String, Any>> = runCatching {
        val array = JSONArray(prefs(context).getString(KEY, "[]") ?: "[]")
        List(array.length()) {
            val item = array.getJSONObject(it)
            mapOf<String, Any>("at" to item.getLong("at"), "message" to item.getString("message"))
        }
    }.getOrDefault(emptyList())
}

internal object AdhanAlarms {
    const val FIRE = "com.abdalluh.tamanina.ADHAN_FIRE"
    const val EVENT_ID = "eventId"
    const val EVENT_TIME = "eventTime"
    private const val QUEUE = "queue"

    private fun prefs(context: Context) =
        context.getSharedPreferences("tamanina_adhan_alarms", Context.MODE_PRIVATE)

    private fun parse(payload: String): List<AdhanAlarm> {
        val json = JSONArray(payload)
        return List(json.length()) { AdhanAlarm.decode(json.getJSONObject(it)) }
    }

    private fun saved(context: Context): List<AdhanAlarm> =
        runCatching { parse(prefs(context).getString(QUEUE, "[]") ?: "[]") }
            .getOrDefault(emptyList())

    private fun save(context: Context, events: List<AdhanAlarm>): Boolean =
        prefs(context).edit().putString(QUEUE, JSONArray(events.map { it.encode() }).toString()).commit()

    fun replace(context: Context, payload: String): List<Int> {
        val previous = saved(context).associateBy { it.id }
        val next = parse(payload).filter { it.at > System.currentTimeMillis() }
        val active = next.filter { event -> previous[event.id] == event || schedule(context, event) }
        val ids = active.map { it.id }.toSet()
        previous.keys.filterNot(ids::contains).forEach { cancel(context, it) }
        check(save(context, active)) { "Could not persist adhan alarms" }
        if (active.isEmpty()) context.stopService(Intent(context, AdhanPlaybackService::class.java))
        return active.map { it.id }
    }

    fun restore(context: Context) {
        val future = saved(context).filter { it.at > System.currentTimeMillis() }
        future.forEach { schedule(context, it) }
        save(context, future)
    }

    fun consume(context: Context, intent: Intent): AdhanAlarm? {
        val queue = saved(context)
        val id = intent.getIntExtra(EVENT_ID, -1)
        val at = intent.getLongExtra(EVENT_TIME, -1)
        val event = queue.firstOrNull { it.id == id && it.at == at } ?: return null
        save(context, queue.filterNot { it.id == id })
        return event
    }

    private fun intent(context: Context) =
        Intent(context, AdhanAlarmReceiver::class.java).setAction(FIRE)

    /**
     * Uses an alarm-clock alarm, which needs no exact-alarm permission, fires in
     * Doze, and lets the service start and play in the background.
     */
    private fun schedule(context: Context, event: AdhanAlarm): Boolean {
        val operation = PendingIntent.getBroadcast(
            context, event.id, intent(context).putExtra(EVENT_ID, event.id)
                .putExtra(EVENT_TIME, event.at),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val show = PendingIntent.getActivity(
            context, 0,
            Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return runCatching {
            context.getSystemService(AlarmManager::class.java)
                .setAlarmClock(AlarmManager.AlarmClockInfo(event.at, show), operation)
        }.onFailure { AdhanLog.record(context, "schedule failed: ${it.javaClass.simpleName}") }.isSuccess
    }

    const val TEST_ID = 999001

    /** Schedules an adhan about ten seconds from now to check the whole chain. */
    fun scheduleTest(context: Context, title: String, stopLabel: String, volume: Double): Boolean {
        val event = AdhanAlarm(
            TEST_ID, System.currentTimeMillis() + 10_000, title, stopLabel,
            volume.toFloat().coerceIn(0f, 1f), true,
            "/adhan?prayer=Test&arabic=%D8%A7%D8%AE%D8%AA%D8%A8%D8%A7%D8%B1&fajr=false",
        )
        save(context, saved(context).filterNot { it.id == TEST_ID } + event)
        val ok = schedule(context, event)
        AdhanLog.record(context, if (ok) "test scheduled for 10s" else "test could not be scheduled")
        return ok
    }

    fun diagnostics(context: Context): Map<String, Any?> {
        val alarms = context.getSystemService(AlarmManager::class.java)
        val notifications = context.getSystemService(NotificationManager::class.java)
        val audio = context.getSystemService(AudioManager::class.java)
        val power = context.getSystemService(PowerManager::class.java)
        val queue = saved(context)
        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "sdk" to Build.VERSION.SDK_INT,
            "notificationsEnabled" to notifications.areNotificationsEnabled(),
            "exactAlarmsAllowed" to (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()),
            "fullScreenAllowed" to (Build.VERSION.SDK_INT < 34 || notifications.canUseFullScreenIntent()),
            "interruptionFilter" to notifications.currentInterruptionFilter,
            "ringerMode" to audio.ringerMode,
            "alarmVolume" to audio.getStreamVolume(AudioManager.STREAM_ALARM),
            "alarmVolumeMax" to audio.getStreamMaxVolume(AudioManager.STREAM_ALARM),
            "batteryUnrestricted" to power.isIgnoringBatteryOptimizations(context.packageName),
            "scheduled" to queue.size,
            "nextAt" to queue.minOfOrNull { it.at },
            "log" to AdhanLog.read(context),
        )
    }

    private fun cancel(context: Context, id: Int) {
        val operation = PendingIntent.getBroadcast(
            context, id, intent(context),
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
        ) ?: return
        context.getSystemService(AlarmManager::class.java).cancel(operation)
        operation.cancel()
    }
}

class AdhanAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED,
            AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED -> AdhanAlarms.restore(context)
            AdhanAlarms.FIRE -> {
                val event = AdhanAlarms.consume(context, intent)
                if (event == null) {
                    AdhanLog.record(context, "alarm fired but its event was missing")
                    return
                }
                val lateSeconds = (System.currentTimeMillis() - event.at) / 1000
                if (lateSeconds > 180) {
                    AdhanLog.record(context, "alarm for ${event.title} skipped: ${lateSeconds}s late")
                    return
                }
                val canPlay = AdhanPlaybackService.canPlaySound(context)
                val started = canPlay && AdhanPlaybackService.start(context, event)
                AdhanLog.record(
                    context,
                    if (started) "${event.title}: playback service started"
                    else "${event.title}: fallback notification (alarm volume ok=$canPlay)",
                )
                if (!started) AdhanPlaybackService.showAlert(context, event, withSound = true)
            }
        }
    }
}
