package com.abdalluh.tamanina

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

internal data class AdhanAlarm(
    val id: Int,
    val at: Long,
    val title: String,
    val stopLabel: String,
    val volume: Float,
    val vibrate: Boolean,
) {
    fun encode() = JSONObject().put("id", id).put("at", at).put("title", title)
        .put("stopLabel", stopLabel).put("volume", volume.toDouble()).put("vibrate", vibrate)

    companion object {
        fun decode(json: JSONObject) = AdhanAlarm(
            json.getInt("id"), json.getLong("at"), json.getString("title"),
            json.getString("stopLabel"), json.getDouble("volume").toFloat().coerceIn(0f, 1f),
            json.getBoolean("vibrate"),
        )
    }
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
        val active = if (canSchedule(context)) {
            next.filter { event -> previous[event.id] == event || schedule(context, event) }
        } else {
            emptyList()
        }
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

    private fun canSchedule(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            context.getSystemService(AlarmManager::class.java).canScheduleExactAlarms()

    private fun intent(context: Context) =
        Intent(context, AdhanAlarmReceiver::class.java).setAction(FIRE)

    private fun schedule(context: Context, event: AdhanAlarm): Boolean {
        if (!canSchedule(context)) return false
        val operation = PendingIntent.getBroadcast(
            context, event.id, intent(context).putExtra(EVENT_ID, event.id)
                .putExtra(EVENT_TIME, event.at),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return runCatching {
            context.getSystemService(AlarmManager::class.java)
                .setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, event.at, operation)
        }.isSuccess
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
                val event = AdhanAlarms.consume(context, intent) ?: return
                val notifications = context.getSystemService(NotificationManager::class.java)
                if (!notifications.areNotificationsEnabled()) return
                if (System.currentTimeMillis() - event.at > 120_000) return
                if (!AdhanPlaybackService.canPlaySound(context, event.vibrate) ||
                    !AdhanPlaybackService.start(context, event)) {
                    AdhanPlaybackService.showAlert(context, event)
                }
            }
        }
    }
}
