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
import java.io.File
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
        if (event == null || !canPlaySound(this)) {
            event?.let { showAlert(this, it, withSound = true) }
            AdhanLog.record(this, "service: cannot play (alarm volume is zero or event invalid)")
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
        // An alarm must sound even when another app holds audio focus or Android
        // refuses the request (it does on some phones), so a denial is only logged.
        val focused = takeFocus()
        AdhanLog.record(
            this,
            if (focused) "service: audio focus granted" else "service: audio focus denied, playing anyway",
        )
        try {
            val playback = MediaPlayer().also {
                player = it
                active = it
            }
            playback.setAudioAttributes(attributes)
            playback.setWakeMode(this, PowerManager.PARTIAL_WAKE_LOCK)
            val downloaded = event.soundPath?.let(::File)?.takeIf { it.isFile && it.length() > 0 }
            if (downloaded != null) {
                playback.setDataSource(downloaded.absolutePath)
            } else {
                assets.openFd("flutter_assets/assets/audio/adhan/adhan_local.mp3").use { asset ->
                    playback.setDataSource(asset.fileDescriptor, asset.startOffset, asset.length)
                }
            }
            playback.setVolume(event.volume, event.volume)
            playback.setOnPreparedListener {
                it.start()
                AdhanLog.record(this, "service: adhan is playing")
            }
            playback.setOnCompletionListener {
                AdhanLog.record(this, "service: adhan finished")
                showAlert(this, event, withSound = false)
                stopSelf()
            }
            playback.setOnErrorListener { _, what, extra ->
                AdhanLog.record(this, "service: player error $what/$extra")
                showAlert(this, event, withSound = true)
                stopSelf()
                true
            }
            playback.prepareAsync()
        } catch (error: Exception) {
            AdhanLog.record(this, "service: could not play (${error.javaClass.simpleName})")
            showAlert(this, event, withSound = true)
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
            audio.requestAudioFocus(onFocusChange, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
        }
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun releaseAudio() {
        if (active === player) active = null
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
        private const val FALLBACK_CHANNEL = "tamanina_adhan_fallback_alarm"
        internal const val EXTRA_ALARM_LAUNCH = "adhanAlarmLaunch"
        @Volatile private var active: MediaPlayer? = null
        // The alarm stream keeps the adhan audible when the phone is on silent or
        // vibrate, like an alarm clock.
        private val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()

        internal fun start(context: Context, event: AdhanAlarm): Boolean = runCatching {
            val intent = Intent(context, AdhanPlaybackService::class.java)
                .putExtra(EVENT, event.encode().toString())
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(intent)
            else context.startService(intent)
        }.onFailure {
            Log.w("TamaninaAdhan", "Background playback could not start", it)
            AdhanLog.record(context, "start failed: ${it.javaClass.simpleName}")
        }.isSuccess

        /** Playback state for the full-screen adhan UI. */
        internal fun status(): Map<String, Any> {
            val player = active
            return runCatching {
                mapOf(
                    "playing" to (player?.isPlaying == true),
                    "positionMs" to (player?.currentPosition ?: 0),
                    "durationMs" to (player?.duration ?: 0),
                )
            }.getOrDefault(mapOf("playing" to false, "positionMs" to 0, "durationMs" to 0))
        }

        internal fun stop(context: Context) {
            runCatching {
                context.startService(
                    Intent(context, AdhanPlaybackService::class.java).setAction(STOP),
                )
            }
        }

        private fun routeIntent(context: Context, event: AdhanAlarm, follow: Boolean): Intent {
            val uri = Uri.parse("tamanina://open${event.route}").buildUpon().apply {
                if (follow) appendQueryParameter("follow", "1")
            }.build()
            return Intent(Intent.ACTION_VIEW, uri, context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

        /** The adhan plays on the alarm stream, so only an alarm volume of zero silences it. */
        internal fun canPlaySound(context: Context): Boolean =
            context.getSystemService(AudioManager::class.java)
                .getStreamVolume(AudioManager.STREAM_ALARM) > 0

        /**
         * Posts the prayer-time notification. With [withSound] it plays the short
         * adhan clip on the alarm stream, for when the service could not play.
         */
        internal fun showAlert(context: Context, event: AdhanAlarm, withSound: Boolean) {
            val manager = context.getSystemService(NotificationManager::class.java)
            if (manager.areNotificationsEnabled()) {
                manager.notify(event.id, notification(context, event, playing = false, withSound = withSound))
            }
        }

        private fun channelId(vibrate: Boolean) =
            if (vibrate) "${PLAYBACK_CHANNEL}_vibration" else PLAYBACK_CHANNEL

        private fun notification(
            context: Context,
            event: AdhanAlarm,
            playing: Boolean,
            withSound: Boolean = false,
        ): Notification {
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val manager = context.getSystemService(NotificationManager::class.java)
                val channelId = when {
                    withSound -> FALLBACK_CHANNEL
                    else -> channelId(event.vibrate)
                }
                val channel = NotificationChannel(
                    channelId,
                    context.getString(R.string.adhan_alert_channel),
                    NotificationManager.IMPORTANCE_HIGH,
                )
                if (withSound) {
                    channel.setSound(
                        Uri.parse("android.resource://${context.packageName}/${R.raw.adhan_alert}"),
                        attributes,
                    )
                    channel.enableVibration(true)
                } else {
                    channel.setSound(null, null)
                    channel.enableVibration(event.vibrate)
                }
                manager.createNotificationChannel(channel)
                Notification.Builder(context, channelId)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
            }
            val open = PendingIntent.getActivity(
                context, PLAYBACK_ID,
                if (playing) routeIntent(context, event, follow = true)
                else Intent(Intent.ACTION_VIEW, Uri.parse("tamanina://open/prayer-times"), context, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            builder.setSmallIcon(R.drawable.ic_notification).setContentTitle(event.title)
                .setContentIntent(open).setOnlyAlertOnce(true).setAutoCancel(!playing)
                .setOngoing(playing)
                .setCategory(if (playing) Notification.CATEGORY_ALARM else Notification.CATEGORY_REMINDER)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
            if (playing) {
                // Shows the adhan screen over the lock screen. Android falls back to a
                // heads-up notification when the device is in use or the app is not allowed.
                val full = PendingIntent.getActivity(
                    context, PLAYBACK_ID + 1,
                    routeIntent(context, event, follow = true).putExtra(EXTRA_ALARM_LAUNCH, true),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
                builder.setFullScreenIntent(full, true)
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
