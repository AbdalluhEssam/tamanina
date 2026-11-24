package com.abdalluh.tamanina

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import org.json.JSONObject

class AdhanPlaybackService : Service() {
    private var player: MediaPlayer? = null
    private var focusRequest: AudioFocusRequest? = null
    private val audio by lazy { getSystemService(AudioManager::class.java) }
    private val onFocusChange = AudioManager.OnAudioFocusChangeListener { change ->
        if (change < 0) stopSelf()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == STOP || intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        val event = runCatching {
            AdhanAlarm.decode(JSONObject(intent.getStringExtra(EVENT) ?: ""))
        }.getOrNull()
        if (event == null || !canPlaySound(this, event.vibrate)) {
            event?.let { showAlert(this, it) }
            stopSelf()
            return START_NOT_STICKY
        }

        val notification = notification(this, event, playing = true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(PLAYBACK_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(PLAYBACK_ID, notification)
        }
        releaseAudio()
        if (!takeFocus()) {
            showAlert(this, event)
            stopSelf()
            return START_NOT_STICKY
        }
        try {
            val playback = MediaPlayer().also { player = it }
            playback.setAudioAttributes(attributes)
            playback.setWakeMode(this, PowerManager.PARTIAL_WAKE_LOCK)
            assets.openFd("flutter_assets/assets/audio/adhan/adhan_local.mp3").use { asset ->
                playback.setDataSource(asset.fileDescriptor, asset.startOffset, asset.length)
            }
            playback.setVolume(event.volume, event.volume)
            playback.setOnPreparedListener { it.start() }
            playback.setOnCompletionListener {
                showAlert(this, event)
                stopSelf()
            }
            playback.setOnErrorListener { _, _, _ ->
                showAlert(this, event)
                stopSelf()
                true
            }
            playback.prepareAsync()
        } catch (_: Exception) {
            showAlert(this, event)
            stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun takeFocus(): Boolean {
        val result = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(attributes).setOnAudioFocusChangeListener(onFocusChange).build()
            focusRequest = request
            audio.requestAudioFocus(request)
        } else {
            @Suppress("DEPRECATION")
            audio.requestAudioFocus(onFocusChange, AudioManager.STREAM_NOTIFICATION, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
        }
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun releaseAudio() {
        player?.release()
        player = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let(audio::abandonAudioFocusRequest)
            focusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audio.abandonAudioFocus(onFocusChange)
        }
    }

    override fun onDestroy() {
        releaseAudio()
        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }

    companion object {
        private const val EVENT = "adhanEvent"
        private const val STOP = "com.abdalluh.tamanina.STOP_ADHAN"
        private const val PLAYBACK_ID = 22000
        private const val PLAYBACK_CHANNEL = "tamanina_adhan_playback"
        private val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()

        internal fun start(context: Context, event: AdhanAlarm): Boolean = runCatching {
            val intent = Intent(context, AdhanPlaybackService::class.java)
                .putExtra(EVENT, event.encode().toString())
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(intent)
            else context.startService(intent)
        }.onFailure { Log.w("TamaninaAdhan", "Background playback could not start", it) }.isSuccess

        internal fun canPlaySound(context: Context, vibrate: Boolean): Boolean {
            val audio = context.getSystemService(AudioManager::class.java)
            val notifications = context.getSystemService(NotificationManager::class.java)
            return notifications.areNotificationsEnabled() &&
                audio.ringerMode == AudioManager.RINGER_MODE_NORMAL &&
                audio.getStreamVolume(AudioManager.STREAM_NOTIFICATION) > 0 &&
                notifications.currentInterruptionFilter == NotificationManager.INTERRUPTION_FILTER_ALL &&
                (Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
                    notifications.getNotificationChannel(channelId(vibrate))?.importance != NotificationManager.IMPORTANCE_NONE)
        }

        internal fun showAlert(context: Context, event: AdhanAlarm) {
            val manager = context.getSystemService(NotificationManager::class.java)
            if (manager.areNotificationsEnabled()) {
                manager.notify(event.id, notification(context, event, playing = false))
            }
        }

        private fun channelId(vibrate: Boolean) =
            if (vibrate) "${PLAYBACK_CHANNEL}_vibration" else PLAYBACK_CHANNEL

        private fun notification(context: Context, event: AdhanAlarm, playing: Boolean): Notification {
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val manager = context.getSystemService(NotificationManager::class.java)
                val channelId = channelId(event.vibrate)
                manager.createNotificationChannel(
                    NotificationChannel(channelId, context.getString(R.string.adhan_alert_channel), NotificationManager.IMPORTANCE_HIGH).apply {
                        setSound(null, null)
                        enableVibration(event.vibrate)
                    },
                )
                Notification.Builder(context, channelId)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
            }
            val open = PendingIntent.getActivity(
                context, PLAYBACK_ID,
                Intent(Intent.ACTION_VIEW, Uri.parse("tamanina://open/prayer-times"), context, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            builder.setSmallIcon(R.drawable.ic_notification).setContentTitle(event.title)
                .setContentIntent(open).setOnlyAlertOnce(true).setAutoCancel(!playing)
                .setOngoing(playing).setCategory(Notification.CATEGORY_REMINDER)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
            if (playing) {
                val stop = PendingIntent.getService(
                    context, PLAYBACK_ID,
                    Intent(context, AdhanPlaybackService::class.java).setAction(STOP),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
                builder.addAction(Notification.Action.Builder(null, event.stopLabel, stop).build())
            }
            return builder.build()
        }
    }
}
