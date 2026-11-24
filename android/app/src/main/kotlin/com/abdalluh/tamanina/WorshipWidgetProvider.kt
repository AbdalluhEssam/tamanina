// Hallmark · Tamanina home-screen widget · native component redesign · v2.0.0
package com.abdalluh.tamanina

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.text.format.DateFormat
import android.util.SizeF
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

enum class WorshipWidgetKind(val route: String, val label: Int) {
    PRAYER("prayer-times", R.string.worship_widget_name),
    DHIKR("azkar", R.string.worship_widget_moment),
    TASBEEH("sebha", R.string.worship_widget_tasbeeh),
    MORNING("azkar/morning", R.string.worship_widget_morning),
    EVENING("azkar/evening", R.string.worship_widget_evening),
    QURAN("quran", R.string.worship_widget_quran)
}

class DhikrWidgetProvider : WorshipWidgetProvider() {
    override val kind = WorshipWidgetKind.DHIKR
}

class TasbeehWidgetProvider : WorshipWidgetProvider() {
    override val kind = WorshipWidgetKind.TASBEEH
}

class MorningWidgetProvider : WorshipWidgetProvider() {
    override val kind = WorshipWidgetKind.MORNING
}

class EveningWidgetProvider : WorshipWidgetProvider() {
    override val kind = WorshipWidgetKind.EVENING
}

class QuranWidgetProvider : WorshipWidgetProvider() {
    override val kind = WorshipWidgetKind.QURAN
}

open class WorshipWidgetProvider : AppWidgetProvider() {
    protected open val kind = WorshipWidgetKind.PRAYER

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        update(context, manager, kind, ids)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context, manager: AppWidgetManager, id: Int, options: Bundle
    ) {
        render(context, manager, id, kind, state(context), System.currentTimeMillis(), options)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == refresh) {
            val manager = AppWidgetManager.getInstance(context)
            for (kind in listOf(WorshipWidgetKind.PRAYER, WorshipWidgetKind.DHIKR)) {
                update(context, manager, kind, widgetIds(context, manager, kind))
            }
        }
    }

    override fun onDeleted(context: Context, ids: IntArray) {
        if (kind != WorshipWidgetKind.PRAYER) return
        val editor = prefs(context).edit()
        for (id in ids) editor.remove("adhkar_$id")
        editor.apply()
    }

    override fun onDisabled(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        scheduleRefresh(context, manager, state(context), System.currentTimeMillis())
    }

    private data class Prayer(val name: String, val at: Long)

    private data class Snapshot(
        val arabic: Boolean,
        val zone: TimeZone,
        val prayers: List<Prayer>
    )

    private data class WidgetSize(val width: Float, val height: Float) {
        fun isWide(fontScale: Float) = width >= 248 * fontScale && height >= 118 * fontScale
        fun isRoomy(fontScale: Float) = height >= 145 * fontScale
    }

    companion object {
        private const val refresh = "com.abdalluh.tamanina.widget.REFRESH"
        private const val payloadKey = "snapshot"
        private const val tasbeehKey = "tasbeeh_count"
        private val providers = mapOf(
            WorshipWidgetKind.PRAYER to WorshipWidgetProvider::class.java,
            WorshipWidgetKind.DHIKR to DhikrWidgetProvider::class.java,
            WorshipWidgetKind.TASBEEH to TasbeehWidgetProvider::class.java,
            WorshipWidgetKind.MORNING to MorningWidgetProvider::class.java,
            WorshipWidgetKind.EVENING to EveningWidgetProvider::class.java,
            WorshipWidgetKind.QURAN to QuranWidgetProvider::class.java
        )
        private val remembrance = listOf(
            "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ" to "In the remembrance of Allah do hearts find rest",
            "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ" to "Glory and praise be to Allah, Glory be to Allah the Magnificent",
            "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ" to "No power nor strength except with Allah, the Most High",
            "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ" to "I seek forgiveness from Allah the Almighty and repent unto Him",
            "لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ" to "There is no god but You; exalted are You, I was of the wrongdoers",
            "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ" to "O Allah, send blessings and peace upon our Prophet Muhammad",
            "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ" to "Allah is sufficient for me. There is no god but Him. I rely on Him, Lord of the Mighty Throne.",
            "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ" to "O Ever-Living, O Sustainer, by Your mercy I seek aid",
            "سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَاللَّهُ أَكْبَرُ" to "Glory be to Allah, all praise is to Allah, and Allah is the Greatest",
            "رَضِيتُ بِاللَّهِ رَبّاً، وَبِالإِسْلاَمِ دِيناً، وَبِمُحَمَّدٍ رَسُولاً" to "I am pleased with Allah as my Lord, Islam as my religion",
            "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ" to "O Allah, help me remember You, thank You, and worship You well",
            "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ" to "In the name of Allah, with whose name nothing on earth or in heaven can harm. He is the All-Hearing, the All-Knowing.",
            "اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي" to "O Allah, You are Pardoning and Generous, so pardon me",
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ" to "Our Lord, grant us good in this world and the Hereafter, and protect us from the punishment of the Fire.",
            "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ" to "There is no god but Allah alone, having no partner",
            "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي" to "My Lord, expand for me my chest and ease my task",
            "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ" to "Glory and praise be to Allah, as many times as His creation, to His satisfaction, the weight of His Throne, and the ink of His words."
        )

        private val diacritics = Regex("\\p{M}")
        private val compactRemembrance = remembrance.filter { (arabic, _) ->
            arabic.replace(diacritics, "").length <= 52
        }

        private fun prefs(context: Context) =
            context.getSharedPreferences("worship_widget", Context.MODE_PRIVATE)

        fun publish(context: Context, payload: String) {
            prefs(context).edit().putString(payloadKey, payload).apply()
            val manager = AppWidgetManager.getInstance(context)
            val snapshot = state(context)
            val now = System.currentTimeMillis()
            for (kind in WorshipWidgetKind.entries) {
                for (id in widgetIds(context, manager, kind)) {
                    render(context, manager, id, kind, snapshot, now)
                }
            }
            scheduleRefresh(context, manager, snapshot, now)
        }

        fun publishTasbeeh(context: Context, count: Int) {
            val value = count.coerceIn(0, 33)
            val storage = prefs(context)
            if (storage.getInt(tasbeehKey, 0) == value) return
            storage.edit().putInt(tasbeehKey, value).apply()
            val manager = AppWidgetManager.getInstance(context)
            update(context, manager, WorshipWidgetKind.TASBEEH, widgetIds(context, manager, WorshipWidgetKind.TASBEEH))
        }

        fun component(context: Context, kind: WorshipWidgetKind) =
            ComponentName(context, providers.getValue(kind))

        private fun widgetIds(context: Context, manager: AppWidgetManager, kind: WorshipWidgetKind) =
            manager.getAppWidgetIds(component(context, kind))

        private fun state(context: Context): Snapshot {
            val json = prefs(context).getString(payloadKey, null)?.let {
                runCatching { JSONObject(it) }.getOrNull()
            }
            val language = json?.optString("language")?.takeIf { it.isNotEmpty() }
                ?: Locale.getDefault().language
            val zone = json?.optString("zone")?.takeIf { it.isNotEmpty() }
                ?.let(TimeZone::getTimeZone) ?: TimeZone.getDefault()
            val list = json?.optJSONArray("prayers")
            val prayers = buildList {
                for (index in 0 until (list?.length() ?: 0)) {
                    val item = list?.optJSONObject(index) ?: continue
                    val at = item.optLong("at")
                    val name = item.optString("name")
                    if (at > 0 && name.isNotBlank()) add(Prayer(name, at))
                }
            }.sortedBy { it.at }
            return Snapshot(language == "ar", zone, prayers)
        }

        private fun update(
            context: Context, manager: AppWidgetManager, kind: WorshipWidgetKind, ids: IntArray
        ) {
            if (ids.isEmpty()) return
            val snapshot = state(context)
            val now = System.currentTimeMillis()
            for (id in ids) render(context, manager, id, kind, snapshot, now)
            if (kind == WorshipWidgetKind.PRAYER || kind == WorshipWidgetKind.DHIKR) {
                scheduleRefresh(context, manager, snapshot, now)
            }
        }

        private fun scheduleRefresh(context: Context, manager: AppWidgetManager, snapshot: Snapshot, now: Long) {
            val alarms = context.getSystemService(AlarmManager::class.java) ?: return
            val intent = PendingIntent.getBroadcast(
                context, 0, Intent(context, WorshipWidgetProvider::class.java).setAction(refresh),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val prayerIds = widgetIds(context, manager, WorshipWidgetKind.PRAYER)
            val dhikrIds = widgetIds(context, manager, WorshipWidgetKind.DHIKR)
            if (prayerIds.isEmpty() && dhikrIds.isEmpty()) {
                alarms.cancel(intent)
                return
            }
            val boundary = Calendar.getInstance(snapshot.zone).apply {
                timeInMillis = now
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                add(Calendar.HOUR_OF_DAY, 4 - get(Calendar.HOUR_OF_DAY) % 4)
            }.timeInMillis
            val next = minOf(snapshot.prayers.firstOrNull { it.at > now }?.at ?: boundary, boundary)
            try {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()) {
                    alarms.setExact(AlarmManager.RTC, next, intent)
                } else {
                    alarms.set(AlarmManager.RTC, next, intent)
                }
            } catch (_: SecurityException) {
                alarms.set(AlarmManager.RTC, next, intent)
            }
        }

        private fun render(
            context: Context, manager: AppWidgetManager, id: Int, provider: WorshipWidgetKind,
            snapshot: Snapshot, now: Long, options: Bundle = manager.getAppWidgetOptions(id)
        ) {
            val kind = if (provider == WorshipWidgetKind.PRAYER && prefs(context).getBoolean("adhkar_$id", false)) {
                WorshipWidgetKind.DHIKR
            } else {
                provider
            }
            val next = snapshot.prayers.firstOrNull { it.at > now }
            val locale = if (snapshot.arabic) Locale.forLanguageTag("ar") else Locale.ENGLISH
            val skeleton = if (DateFormat.is24HourFormat(context)) "Hm" else "hm"
            val formatter = SimpleDateFormat(DateFormat.getBestDateTimePattern(locale, skeleton), locale)
                .apply { timeZone = snapshot.zone }
            val open = PendingIntent.getActivity(
                context, id,
                Intent(Intent.ACTION_VIEW, Uri.parse("tamanina://open/${kind.route}"), context, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val fontScale = context.resources.configuration.fontScale.coerceAtLeast(1f)

            fun layout(size: WidgetSize): RemoteViews {
                val wide = size.isWide(fontScale)
                val roomy = size.isRoomy(fontScale)
                val arabic = snapshot.arabic
                val shortcut = kind != WorshipWidgetKind.DHIKR && kind != WorshipWidgetKind.PRAYER
                val layoutId = if (shortcut) R.layout.worship_widget_shortcut else R.layout.worship_widget
                return RemoteViews(context.packageName, layoutId).apply {
                    val direction = if (arabic) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR
                    setInt(android.R.id.background, "setLayoutDirection", direction)
                    setOnClickPendingIntent(android.R.id.background, open)
                    if (shortcut) {
                        bindShortcut(context, this, kind, locale, arabic)
                    } else {
                        setOnClickPendingIntent(R.id.widget_content, open)
                        setOnClickPendingIntent(R.id.widget_schedule, open)
                        setTextViewTextSize(R.id.widget_title, TypedValue.COMPLEX_UNIT_SP, if (roomy) 13f else 11f)
                        setFloat(R.id.widget_art_compact, "setScaleX", if (arabic) 1f else -1f)
                        setFloat(R.id.widget_art_wide, "setScaleX", if (arabic) 1f else -1f)
                        if (kind == WorshipWidgetKind.DHIKR) {
                            val compact = !wide && (size.width < 166 * fontScale || !roomy)
                            bindDhikr(this, snapshot, now, compact)
                        } else {
                            if (wide && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                val artworkWidth = minOf(size.width * 0.35f, (size.height - 50f) * 1.12f)
                                setViewLayoutWidth(R.id.widget_art_wide, artworkWidth, TypedValue.COMPLEX_UNIT_DIP)
                                setViewLayoutHeight(R.id.widget_art_wide, artworkWidth * 0.89f, TypedValue.COMPLEX_UNIT_DIP)
                            }
                            val characterWidth = if (arabic) 3.5f else 4.8f
                            val maximumTimeSize = ((size.width - 24f) / (characterWidth * fontScale)).coerceAtLeast(18f)
                            bindPrayer(context, this, snapshot, next, now, wide, roomy, maximumTimeSize, formatter)
                        }
                    }
                }
            }

            val sizes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) exactSizes(options) else emptyList()
            val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && sizes.isNotEmpty()) {
                RemoteViews(sizes.associateWith { layout(WidgetSize(it.width, it.height)) })
            } else {
                val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 130).toFloat()
                val maxWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, minWidth.toInt()).toFloat()
                val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 118).toFloat()
                val maxHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, minHeight.toInt()).toFloat()
                RemoteViews(layout(WidgetSize(maxWidth, minHeight)), layout(WidgetSize(minWidth, maxHeight)))
            }
            manager.updateAppWidget(id, views)
        }

        @Suppress("DEPRECATION")
        private fun exactSizes(options: Bundle): List<SizeF> {
            val sizes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                options.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES, SizeF::class.java)
            } else {
                options.getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
            }
            return sizes.orEmpty().filter { it.width > 0 && it.height > 0 }.distinct().take(16)
        }

        private fun bindShortcut(
            context: Context, views: RemoteViews, kind: WorshipWidgetKind, locale: Locale, arabic: Boolean
        ) {
            if (kind == WorshipWidgetKind.TASBEEH) {
                views.setViewVisibility(R.id.widget_beads_art, View.VISIBLE)
                views.setViewVisibility(R.id.widget_tasbeeh_panel, View.VISIBLE)
                views.setViewVisibility(R.id.widget_shortcut_panel, View.GONE)
                views.setTextViewText(R.id.widget_tasbeeh_count, prefs(context).getInt(tasbeehKey, 0).toString())
                views.setTextViewText(R.id.widget_tasbeeh_label, if (arabic) "تسبيحة" else "Dhikr count")
                return
            }
            val icon = when (kind) {
                WorshipWidgetKind.MORNING -> R.drawable.worship_icon_sunrise
                WorshipWidgetKind.EVENING -> R.drawable.worship_icon_crescent
                else -> R.drawable.worship_icon_book
            }
            val configuration = android.content.res.Configuration(context.resources.configuration).apply {
                setLocale(locale)
            }
            views.setImageViewResource(R.id.widget_shortcut_icon, icon)
            views.setTextViewText(R.id.widget_shortcut_label, context.createConfigurationContext(configuration).getString(kind.label))
        }

        private fun bindDhikr(views: RemoteViews, snapshot: Snapshot, now: Long, compact: Boolean) {
            val calendar = Calendar.getInstance(snapshot.zone).apply { timeInMillis = now }
            val slot = calendar.get(Calendar.DAY_OF_YEAR) * 6 + calendar.get(Calendar.HOUR_OF_DAY) / 4
            val items = if (compact) compactRemembrance else remembrance
            val message = items[slot % items.size]
            val footer = if (snapshot.arabic) {
                if (message == remembrance.first()) "سكينة القلب" else "اذكر الله"
            } else {
                if (message == remembrance.first()) "Tranquility of the heart" else "Remember Allah"
            }
            views.setViewVisibility(R.id.widget_prayer_compact, View.GONE)
            views.setViewVisibility(R.id.widget_prayer_wide, View.GONE)
            views.setViewVisibility(R.id.widget_schedule, View.GONE)
            views.setViewVisibility(R.id.widget_timer_row, View.GONE)
            views.setViewVisibility(R.id.widget_art_wide, View.GONE)
            views.setViewVisibility(R.id.widget_art_compact, View.VISIBLE)
            views.setViewVisibility(R.id.widget_quote, View.VISIBLE)
            views.setViewVisibility(R.id.widget_footer, View.VISIBLE)
            views.setImageViewResource(R.id.widget_icon, R.drawable.ic_widget_dhikr)
            views.setImageViewResource(R.id.widget_art_compact, R.drawable.worship_art_foliage)
            views.setTextViewText(R.id.widget_title, if (snapshot.arabic) "لحظة للذِّكر" else "Moment of dhikr")
            views.setTextViewText(R.id.widget_quote, message.first)
            views.setTextViewText(R.id.widget_footer, footer)
        }

        private fun bindPrayer(
            context: Context, views: RemoteViews, snapshot: Snapshot, next: Prayer?, now: Long,
            wide: Boolean, roomy: Boolean, maximumTimeSize: Float, formatter: SimpleDateFormat
        ) {
            val ar = snapshot.arabic
            val showSchedule = wide && next != null
            val dateKey = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT).apply { timeZone = snapshot.zone }
            val day = next?.let { dateKey.format(Date(it.at)) }
            val tomorrow = Calendar.getInstance(snapshot.zone).apply {
                timeInMillis = now
                add(Calendar.DAY_OF_MONTH, 1)
            }
            val laterDay = day != null && day == dateKey.format(tomorrow.time)
            val title = if (laterDay) {
                if (ar) "الصلاة القادمة غدًا" else "Next prayer tomorrow"
            } else {
                if (ar) "الصلاة القادمة" else "Next prayer"
            }
            views.setImageViewResource(R.id.widget_icon, R.drawable.ic_widget_prayer)
            views.setImageViewResource(R.id.widget_art_wide, R.drawable.worship_art_arch)
            views.setImageViewResource(R.id.widget_art_compact, R.drawable.worship_art_dome)
            views.setViewVisibility(R.id.widget_art_wide, if (wide) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.widget_art_compact, if (wide) View.GONE else View.VISIBLE)
            views.setTextViewText(R.id.widget_title, title)
            views.setViewVisibility(R.id.widget_quote, View.GONE)
            views.setViewVisibility(R.id.widget_prayer_wide, if (showSchedule) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.widget_schedule, if (showSchedule) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.widget_prayer_compact, if (showSchedule) View.GONE else View.VISIBLE)
            views.setViewVisibility(R.id.widget_timer_row, if (next != null) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.widget_footer, if (next == null) View.VISIBLE else View.GONE)

            if (next == null) {
                val prompt = if (snapshot.prayers.isEmpty()) {
                    if (ar) "اختر مدينتك" else "Choose your city"
                } else {
                    if (ar) "حدّث المواقيت" else "Refresh prayer times"
                }
                views.setViewVisibility(R.id.widget_compact_name, View.GONE)
                views.setInt(R.id.widget_compact_time, "setMaxLines", 2)
                views.setTextViewTextSize(R.id.widget_compact_time, TypedValue.COMPLEX_UNIT_SP, 17f)
                views.setTextViewText(R.id.widget_compact_time, prompt)
                views.setTextViewText(R.id.widget_footer, if (ar) "افتح طمأنينة" else "Open Tamanina")
                return
            }

            val base = SystemClock.elapsedRealtime() + (next.at - now)
            views.setChronometerCountDown(R.id.widget_countdown, true)
            views.setChronometer(R.id.widget_countdown, base, null, true)
            views.setContentDescription(R.id.widget_timer_row, if (ar) "الوقت المتبقي للصلاة" else "Time until prayer")
            val time = formatter.format(Date(next.at))
            if (!showSchedule) {
                views.setViewVisibility(R.id.widget_compact_name, View.VISIBLE)
                views.setInt(R.id.widget_compact_time, "setMaxLines", 1)
                views.setTextViewTextSize(R.id.widget_compact_name, TypedValue.COMPLEX_UNIT_SP, if (roomy) 20f else 17f)
                val compactTimeSize = minOf(maximumTimeSize, if (roomy) 31f else 26f)
                views.setTextViewTextSize(R.id.widget_compact_time, TypedValue.COMPLEX_UNIT_SP, compactTimeSize)
                views.setTextViewText(R.id.widget_compact_time, time)
                views.setTextViewText(R.id.widget_compact_name, next.name)
                return
            }

            views.setTextViewTextSize(R.id.widget_wide_name, TypedValue.COMPLEX_UNIT_SP, if (roomy) 20f else 17f)
            views.setTextViewTextSize(R.id.widget_wide_time, TypedValue.COMPLEX_UNIT_SP, if (roomy) 34f else 28f)
            views.setTextViewText(R.id.widget_wide_name, next.name)
            views.setTextViewText(R.id.widget_wide_time, time)
            views.removeAllViews(R.id.widget_schedule_row)
            val dayPrayers = snapshot.prayers.filter { dateKey.format(Date(it.at)) == day }.take(5)
            for (prayer in dayPrayers) {
                val cell = RemoteViews(context.packageName, R.layout.worship_widget_prayer_cell)
                val selected = prayer.at == next.at
                val prayerTime = formatter.format(Date(prayer.at))
                cell.setTextViewText(R.id.widget_prayer_name, prayer.name)
                cell.setTextViewText(R.id.widget_prayer_time, prayerTime)
                if (roomy) {
                    cell.setTextViewTextSize(R.id.widget_prayer_name, TypedValue.COMPLEX_UNIT_SP, 12f)
                    cell.setTextViewTextSize(R.id.widget_prayer_time, TypedValue.COMPLEX_UNIT_SP, 12f)
                }
                val selection = if (!selected) "" else if (ar) "، القادمة" else ", next"
                cell.setContentDescription(R.id.widget_prayer_cell, "${prayer.name}: $prayerTime$selection")
                if (selected) {
                    cell.setInt(R.id.widget_prayer_cell, "setBackgroundResource", R.drawable.worship_widget_selection)
                    cell.setTextColor(R.id.widget_prayer_time, context.getColor(R.color.worship_widget_gold))
                }
                views.addView(R.id.widget_schedule_row, cell)
            }
        }
    }
}
