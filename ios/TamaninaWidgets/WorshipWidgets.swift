// Hallmark · Tamanina home-screen widgets · native component redesign · v2.0.0
// Prayer and remembrance artwork sits behind native text and live widget data.
import SwiftUI
import WidgetKit

private let sharedGroup = "group.com.abdalluh.tamanina"

private enum WidgetStyle {
    // Matches the app's WorshipPalette.
    static let pine = Color(red: 25.0 / 255, green: 65.0 / 255, blue: 56.0 / 255)
    static let deepPine = Color(red: 13.0 / 255, green: 47.0 / 255, blue: 39.0 / 255)
    static let shade = Color(red: 5.0 / 255, green: 30.0 / 255, blue: 25.0 / 255)
    static let gold = Color(red: 249.0 / 255, green: 200.0 / 255, blue: 117.0 / 255)
    static let ink = Color(red: 245.0 / 255, green: 243.0 / 255, blue: 234.0 / 255)
    static let secondary = Color(red: 186.0 / 255, green: 207.0 / 255, blue: 196.0 / 255)
    static let rule = secondary.opacity(0.24)

    static let caption: CGFloat = 11
    static let body: CGFloat = 13
}

private struct DhikrItem {
    let text: String
    let category: String
    let categoryEn: String
    let translation: String
}

private let remembranceItems: [DhikrItem] = [
    DhikrItem(
        text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ",
        category: "حَبِيبَتَانِ إِلَى الرَّحْمَٰنِ",
        categoryEn: "Beloved to the Most Merciful",
        translation: "Glory and praise be to Allah, Glory be to Allah the Magnificent"
    ),
    DhikrItem(
        text: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
        category: "سَكِينَةُ الْقَلْبِ",
        categoryEn: "Tranquility of the Heart",
        translation: "Verily in the remembrance of Allah do hearts find rest"
    ),
    DhikrItem(
        text: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ",
        category: "كَنْزٌ مِنْ كُنُوزِ الْجَنَّةِ",
        categoryEn: "A Treasure of Paradise",
        translation: "There is no power nor strength except with Allah, the Most High"
    ),
    DhikrItem(
        text: "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ",
        category: "مَغْفِرَةُ الذُّنُوبِ",
        categoryEn: "Seeking Forgiveness",
        translation: "I seek forgiveness from Allah the Almighty and repent unto Him"
    ),
    DhikrItem(
        text: "لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ",
        category: "دُعَاءُ يُونُسَ عَلَيْهِ السَّلَام",
        categoryEn: "Relief of All Hardships",
        translation: "There is no god but You; exalted are You, I was of the wrongdoers"
    ),
    DhikrItem(
        text: "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
        category: "الصَّلَاةُ عَلَى النَّبِيِّ ﷺ",
        categoryEn: "Blessings upon the Prophet",
        translation: "O Allah, send blessings and peace upon our Prophet Muhammad"
    ),
    DhikrItem(
        text: "سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ",
        category: "أَحَبُّ الْكَلَامِ إِلَى اللَّهِ",
        categoryEn: "Beloved Words to Allah",
        translation: "Glory be to Allah, praise be to Allah, there is no god but Allah, Allah is Greatest"
    ),
    DhikrItem(
        text: "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
        category: "الْكِفَايَةُ وَالتَّوَكُّلُ",
        categoryEn: "Sufficiency and Reliance",
        translation: "Allah is sufficient for me. There is no god but Him. I rely on Him, Lord of the Mighty Throne."
    ),
    DhikrItem(
        text: "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ",
        category: "دُعَاءُ الْفَرَجِ وَالْكَرْبِ",
        categoryEn: "Supplication of Relief",
        translation: "O Ever-Living, O Sustainer, by Your mercy I seek aid"
    ),
    DhikrItem(
        text: "رَضِيتُ بِاللَّهِ رَبّاً، وَبِالإِسْلاَمِ دِيناً، وَبِمُحَمَّدٍ رَسُولاً",
        category: "رِضَا الإِيمَانِ",
        categoryEn: "Satisfaction with Faith",
        translation: "I am pleased with Allah as my Lord, Islam as my religion, and Muhammad as my Prophet"
    ),
    DhikrItem(
        text: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
        category: "طَلَبُ التَّوْفِيقِ لِلْعِبَادَةِ",
        categoryEn: "Seeking Grace in Worship",
        translation: "O Allah, help me remember You, thank You, and worship You well"
    ),
    DhikrItem(
        text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
        category: "مُضَاعَفَةُ الأُجُورِ",
        categoryEn: "Multiplied Rewards",
        translation: "Glory and praise be to Allah, as many times as His creation, to His satisfaction, the weight of His Throne, and the ink of His words"
    ),
    DhikrItem(
        text: "اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
        category: "دُعَاءُ لَيْلَةِ الْقَدْرِ",
        categoryEn: "Seeking Pardon",
        translation: "O Allah, You are Pardoning and Generous, so pardon me"
    ),
    DhikrItem(
        text: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
        category: "جَامِعُ خَيْرَيِ الدُّنْيَا وَالآخِرَةِ",
        categoryEn: "Comprehensive Goodness",
        translation: "Our Lord, grant us good in this world and the Hereafter, and protect us from the punishment of the Fire"
    )
]

private let compactRemembranceIndices = remembranceItems.indices.filter {
    remembranceItems[$0].text.count <= 49
}

private enum ContentKind {
    case prayer, remembrance, tasbeeh, morning, evening, quran

    var id: String {
        switch self {
        case .prayer: return "TamaninaPrayer"
        case .remembrance: return "TamaninaDhikr"
        case .tasbeeh: return "TamaninaTasbeeh"
        case .morning: return "TamaninaMorningAdhkar"
        case .evening: return "TamaninaEveningAdhkar"
        case .quran: return "TamaninaQuran"
        }
    }

    var url: URL? {
        let route: String
        switch self {
        case .prayer: route = "prayer-times"
        case .remembrance: route = "azkar"
        case .tasbeeh: route = "sebha"
        case .morning: route = "azkar/morning"
        case .evening: route = "azkar/evening"
        case .quran: route = "quran"
        }
        return URL(string: "tamanina://open/\(route)")
    }

    var families: [WidgetFamily] {
        switch self {
        case .prayer, .remembrance: return [.systemSmall, .systemMedium]
        default: return [.systemSmall]
        }
    }

    func name(arabic: Bool) -> String {
        switch self {
        case .prayer: return arabic ? "مواقيت الصلاة" : "Prayer times"
        case .remembrance: return arabic ? "لحظة للذِّكر" : "Moment of dhikr"
        case .tasbeeh: return arabic ? "السبحة" : "Tasbeeh"
        case .morning: return arabic ? "أذكار الصباح" : "Morning adhkar"
        case .evening: return arabic ? "أذكار المساء" : "Evening adhkar"
        case .quran: return arabic ? "القرآن" : "Quran"
        }
    }
}

private struct Snapshot: Decodable {
    struct Prayer: Decodable {
        let name: String
        let at: Double
        var date: Date { Date(timeIntervalSince1970: at / 1000) }
    }

    let language: String
    let zone: String
    let city: String
    let prayers: [Prayer]

    var arabic: Bool { language == "ar" }
    var locale: Locale { Locale(identifier: language) }
    var timeZone: TimeZone { TimeZone(identifier: zone) ?? .autoupdatingCurrent }
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    static func load() -> Snapshot {
        let saved = UserDefaults(suiteName: sharedGroup)?.string(forKey: "worship_widget_snapshot")
            ?? UserDefaults.standard.string(forKey: "worship_widget_snapshot")
        if let data = saved?.data(using: .utf8),
           let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            return snapshot
        }
        return Snapshot(
            language: Locale.preferredLanguages.first?.hasPrefix("en") == true ? "en" : "ar",
            zone: TimeZone.autoupdatingCurrent.identifier,
            city: "",
            prayers: []
        )
    }

    static func preview(now: Date, language: String) -> Snapshot {
        let arabic = language == "ar"
        let names = arabic
            ? ["الفجر", "الظهر", "العصر", "المغرب", "العشاء"]
            : ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        let calendar = Calendar.current
        let timeOfDay = [(5, 8), (12, 0), (15, 20), (17, 34), (19, 1)]
        return Snapshot(
            language: language,
            zone: calendar.timeZone.identifier,
            city: arabic ? "القاهرة" : "Cairo",
            prayers: zip(names, timeOfDay).compactMap { name, time in
                guard let date = calendar.date(bySettingHour: time.0, minute: time.1, second: 0, of: now),
                      calendar.isDate(date, inSameDayAs: now) else { return nil }
                return Prayer(name: name, at: date.timeIntervalSince1970 * 1000)
            }
        )
    }
}

private struct DaySchedule {
    let prayers: [Snapshot.Prayer]
    let next: Snapshot.Prayer?
    let isTomorrow: Bool

    init(snapshot: Snapshot, now: Date) {
        let ordered = snapshot.prayers.filter { !$0.name.isEmpty && $0.at > 0 }
            .sorted { $0.at < $1.at }
        let upcoming = ordered.first { $0.date > now }
        let calendar = snapshot.calendar
        next = upcoming
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)
        isTomorrow = upcoming.flatMap { prayer in
            tomorrow.map { calendar.isDate(prayer.date, inSameDayAs: $0) }
        } ?? false
        prayers = upcoming.map { next in
            Array(ordered.filter { calendar.isDate($0.date, inSameDayAs: next.date) }.prefix(5))
        } ?? []
    }
}

private struct WorshipEntry: TimelineEntry {
    let date: Date
    let snapshot: Snapshot
    let dhikrIndex: Int
    var tasbeeh = 0
}

private struct WorshipProvider: TimelineProvider {
    let kind: ContentKind

    func placeholder(in context: Context) -> WorshipEntry {
        previewEntry(language: Snapshot.load().language)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorshipEntry) -> Void) {
        let now = Date()
        let snapshot = Snapshot.load()
        if context.isPreview {
            completion(previewEntry(language: snapshot.language))
        } else {
            completion(entry(date: now, snapshot: snapshot, family: context.family))
        }
    }

    private func previewEntry(language: String) -> WorshipEntry {
        let today = Date()
        let date = Calendar.current.date(bySettingHour: 16, minute: 15, second: 0, of: today) ?? today
        return WorshipEntry(date: date, snapshot: .preview(now: date, language: language), dhikrIndex: 1, tasbeeh: 33)
    }

    private func entry(date: Date, snapshot: Snapshot, family: WidgetFamily) -> WorshipEntry {
        let slot = Int(date.timeIntervalSince1970 / 1800)
        let indices = family == .systemSmall ? compactRemembranceIndices : Array(remembranceItems.indices)
        let index = kind == .remembrance ? indices[slot % indices.count] : 0
        let count = UserDefaults(suiteName: sharedGroup)?.integer(forKey: "worship_widget_tasbeeh") ?? 0
        return WorshipEntry(date: date, snapshot: snapshot, dhikrIndex: index, tasbeeh: min(33, max(0, count)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorshipEntry>) -> Void) {
        let now = Date()
        let snapshot = Snapshot.load()
        let dates: [Date]
        let nextReload: Date

        switch kind {
        case .prayer:
            let limit = now.addingTimeInterval(48 * 3600)
            let upcoming = snapshot.prayers.map(\.date).filter { $0 > now && $0 < limit }
            // On the other side of midnight the same Fajr is now "today".
            let dayStarts = (1...2).compactMap {
                snapshot.calendar.date(byAdding: .day, value: $0, to: snapshot.calendar.startOfDay(for: now))
            }.filter { $0 < limit }
            dates = [now] + Set(upcoming + dayStarts).sorted()
            nextReload = snapshot.prayers.contains { $0.date > now }
                ? limit
                : now.addingTimeInterval(1800)
        case .remembrance:
            let slot: TimeInterval = 1800
            let first = Foundation.floor(now.timeIntervalSince1970 / slot)
            dates = [now] + (1...48).map { Date(timeIntervalSince1970: (first + Double($0)) * slot) }
            nextReload = Date(timeIntervalSince1970: (first + 49) * slot)
        default:
            completion(Timeline(entries: [entry(date: now, snapshot: snapshot, family: context.family)], policy: .never))
            return
        }

        let entries = dates.map { entry(date: $0, snapshot: snapshot, family: context.family) }
        completion(Timeline(entries: entries, policy: .after(nextReload)))
    }
}

private struct WidgetSurface: View {
    var body: some View {
        LinearGradient(
            colors: [WidgetStyle.pine, WidgetStyle.deepPine, WidgetStyle.shade],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct WidgetMetrics {
    let wide: Bool
    let size: CGSize

    var short: Bool { size.height < 150 }
    var inset: CGFloat { wide ? 15 : 11 }
    var focusTimeSize: CGFloat { wide ? (short ? 27 : 30) : (short ? 28 : 31) }
}

private struct WorshipCard: View {
    @Environment(\.widgetFamily) private var family
    let entry: WorshipEntry
    let kind: ContentKind

    var body: some View {
        GeometryReader { geometry in
            WorshipCanvas(entry: entry, kind: kind,
                          metrics: WidgetMetrics(wide: family == .systemMedium, size: geometry.size))
        }
        .environment(\.locale, entry.snapshot.locale)
        .environment(\.layoutDirection, entry.snapshot.arabic ? .rightToLeft : .leftToRight)
        .widgetURL(kind.url)
        .widgetSurface()
    }
}

private struct WorshipCanvas: View {
    let entry: WorshipEntry
    let kind: ContentKind
    let metrics: WidgetMetrics

    var body: some View {
        Group {
            switch kind {
            case .prayer:
                PrayerContent(entry: entry, metrics: metrics)
            case .remembrance:
                DhikrContent(item: remembranceItems[entry.dhikrIndex], arabic: entry.snapshot.arabic, metrics: metrics)
            default:
                ShortcutContent(kind: kind, entry: entry, metrics: metrics)
            }
        }
        .foregroundStyle(WidgetStyle.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .overlay {
            ContainerRelativeShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [WidgetStyle.gold.opacity(0.70), WidgetStyle.rule, WidgetStyle.rule,
                                 WidgetStyle.gold.opacity(0.48)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .accessibilityHidden(true)
        }
    }
}

private struct Artwork: View {
    let name: String
    var mirror = false

    var body: some View {
        GeometryReader { proxy in
            if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Artwork"),
               let raster = UIImage(contentsOfFile: url.path) {
                Image(uiImage: raster)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .scaleEffect(x: mirror ? -1 : 1, y: 1)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct WidgetLabel: View {
    let text: String
    let symbol: String

    var body: some View {
        Label {
            Text(text).lineLimit(1).minimumScaleFactor(0.8)
        } icon: {
            Image(systemName: symbol)
                .accessibilityHidden(true)
                .worshipAccent()
        }
        .font(.system(size: WidgetStyle.caption, weight: .medium))
        .foregroundStyle(WidgetStyle.secondary)
    }
}

private struct PrayerContent: View {
    let entry: WorshipEntry
    let metrics: WidgetMetrics

    private var snapshot: Snapshot { entry.snapshot }
    private var arabic: Bool { snapshot.arabic }

    var body: some View {
        let schedule = DaySchedule(snapshot: snapshot, now: entry.date)
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                Artwork(name: metrics.wide ? "prayer_panorama" : "prayer_dome", mirror: !arabic)
                    .frame(width: metrics.size.width * (metrics.wide ? 0.72 : 0.83))
                VStack(alignment: .leading, spacing: 0) {
                    WidgetLabel(
                        text: schedule.isTomorrow ? (arabic ? "الصلاة القادمة غدًا" : "Next prayer tomorrow")
                            : (arabic ? "الصلاة القادمة" : "Next prayer"),
                        symbol: "clock"
                    )
                    Spacer(minLength: 3)
                    if let next = schedule.next {
                        if metrics.wide {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                prayerName(next)
                                prayerTime(next)
                            }
                            .accessibilityElement(children: .combine)
                        } else {
                            VStack(alignment: .leading, spacing: 1) {
                                prayerName(next)
                                prayerTime(next)
                            }
                            .accessibilityElement(children: .combine)
                        }
                        Spacer(minLength: 3)
                        countdown(to: next.date)
                    } else {
                        unavailable
                        Spacer(minLength: 2)
                    }
                }
                .frame(maxWidth: metrics.size.width * (metrics.wide ? 0.64 : 0.93), alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, metrics.inset)
                .padding(.top, metrics.short ? 9 : 12)
                .padding(.bottom, metrics.short ? 9 : 12)
            }
            .frame(maxHeight: .infinity)
            if metrics.wide, let next = schedule.next {
                scheduleRow(schedule.prayers, next: next)
                    .padding(.horizontal, metrics.inset)
                    .padding(.bottom, 7)
            }
        }
    }

    private var unavailable: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(snapshot.prayers.isEmpty
                ? (arabic ? "اختر مدينتك" : "Choose your city")
                : (arabic ? "حدّث المواقيت" : "Refresh prayer times"))
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            Text(arabic ? "افتح طمأنينة" : "Open Tamanina")
                .font(.system(size: WidgetStyle.body))
                .foregroundStyle(WidgetStyle.gold)
        }
    }

    private func prayerName(_ prayer: Snapshot.Prayer) -> some View {
        Text(prayer.name)
            .font(.system(size: metrics.short ? 16 : 18, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.76)
    }

    private func prayerTime(_ prayer: Snapshot.Prayer) -> some View {
        Text(format(prayer.date))
            .font(.system(size: metrics.focusTimeSize, weight: .semibold).monospacedDigit())
            .foregroundStyle(WidgetStyle.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .worshipAccent()
            .layoutPriority(1)
    }

    private func countdown(to date: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "hourglass")
                .accessibilityLabel(arabic ? "الوقت المتبقي" : "Time remaining")
            Group {
                if #available(iOS 16.0, iOSApplicationExtension 16.0, *) {
                    Text(timerInterval: entry.date...date, pauseTime: date, countsDown: true)
                } else {
                    Text(date, style: .timer)
                }
            }
            .frame(width: 57, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .font(.system(size: 12, weight: .medium).monospacedDigit())
        .foregroundStyle(WidgetStyle.secondary)
        .accessibilityElement(children: .combine)
    }

    private func scheduleRow(_ prayers: [Snapshot.Prayer], next: Snapshot.Prayer) -> some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(WidgetStyle.rule)
                .frame(height: 0.7)
                .accessibilityHidden(true)
            HStack(spacing: 2) {
                ForEach(prayers, id: \.at) { prayer in
                    prayerColumn(prayer, selected: prayer.at == next.at)
                }
            }
        }
    }

    private func prayerColumn(_ prayer: Snapshot.Prayer, selected: Bool) -> some View {
        VStack(spacing: 2) {
            Text(prayer.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(WidgetStyle.ink)
            Text(format(prayer.date))
                .font(.system(size: 11, weight: selected ? .semibold : .medium).monospacedDigit())
                .foregroundStyle(selected ? WidgetStyle.gold : WidgetStyle.secondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background {
            if selected {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [WidgetStyle.gold.opacity(0.37), WidgetStyle.gold.opacity(0.08)],
                                         startPoint: .top, endPoint: .bottom))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(WidgetStyle.gold.opacity(0.8), lineWidth: 0.7)
                    }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = snapshot.locale
        formatter.timeZone = snapshot.timeZone
        let hourFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: .autoupdatingCurrent)
        formatter.setLocalizedDateFormatFromTemplate(hourFormat?.contains("a") == true ? "ahmm" : "Hmm")
        return formatter.string(from: date)
    }
}

private struct DhikrContent: View {
    let item: DhikrItem
    let arabic: Bool
    let metrics: WidgetMetrics

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Artwork(name: "lantern", mirror: !arabic)
                .frame(width: metrics.size.width * (metrics.wide ? 0.51 : 0.69))
            VStack(alignment: .leading, spacing: 0) {
                WidgetLabel(text: arabic ? "لحظة للذِّكر" : "Moment of dhikr", symbol: "book")
                Spacer(minLength: 4)
                Text(item.text)
                    .font(.custom("GeezaPro", fixedSize: quoteSize))
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .lineLimit(metrics.wide ? 3 : 6)
                    .minimumScaleFactor(0.70)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, .rightToLeft)
                    .environment(\.locale, Locale(identifier: "ar"))
                    .layoutPriority(1)
                Spacer(minLength: 4)
                Text(arabic ? item.category : item.categoryEn)
                    .font(.system(size: WidgetStyle.caption, weight: .medium))
                    .foregroundStyle(WidgetStyle.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }
            .frame(maxWidth: metrics.size.width * (metrics.wide ? 0.67 : (item.text.count > 49 ? 0.9 : 0.79)), alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(metrics.inset)
        }
    }

    private var quoteSize: CGFloat {
        if metrics.wide { return metrics.short ? 24 : 27 }
        return item.text.count > 49 ? 16 : 23
    }
}

private struct ShortcutContent: View {
    let kind: ContentKind
    let entry: WorshipEntry
    let metrics: WidgetMetrics

    var body: some View {
        let arabic = entry.snapshot.arabic
        if kind == .tasbeeh {
            ZStack {
                Artwork(name: "beads")
                VStack(spacing: 0) {
                    Text(entry.tasbeeh.formatted())
                        .font(.system(size: metrics.size.height * 0.23, weight: .semibold).monospacedDigit())
                        .foregroundStyle(WidgetStyle.gold)
                        .worshipAccent()
                    Text(arabic ? "تسبيحة" : "Dhikr count")
                        .font(.system(size: WidgetStyle.body, weight: .medium))
                }
                .offset(y: -metrics.size.height * 0.035)
                .accessibilityElement(children: .combine)
            }
        } else {
            ZStack {
                if kind == .quran {
                    Image(systemName: "book")
                        .font(.system(size: metrics.size.height * 0.33, weight: .light))
                        .foregroundStyle(WidgetStyle.gold)
                        .offset(y: -metrics.size.height * 0.10)
                        .worshipAccent()
                        .accessibilityHidden(true)
                } else {
                    Artwork(name: kind == .morning ? "morning" : "evening")
                }
                VStack {
                    Spacer()
                    Text(kind.name(arabic: arabic))
                        .font(.system(size: metrics.short ? 15 : 17, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                        .padding(.bottom, metrics.short ? 17 : 20)
                }
                .padding(.horizontal, 10)
            }
        }
    }
}

@MainActor
private func widgetConfiguration(_ kind: ContentKind) -> some WidgetConfiguration {
    StaticConfiguration(kind: kind.id, provider: WorshipProvider(kind: kind)) { entry in
        WorshipCard(entry: entry, kind: kind)
    }
    .configurationDisplayName(Text(verbatim: kind.name(arabic: Snapshot.load().arabic)))
    .supportedFamilies(kind.families)
    .useCustomMargins()
}

private struct PrayerWidget: Widget {
    var body: some WidgetConfiguration { widgetConfiguration(.prayer) }
}

private struct RemembranceWidget: Widget {
    var body: some WidgetConfiguration { widgetConfiguration(.remembrance) }
}

private struct TasbeehWidget: Widget {
    var body: some WidgetConfiguration { widgetConfiguration(.tasbeeh) }
}

private struct MorningWidget: Widget {
    var body: some WidgetConfiguration { widgetConfiguration(.morning) }
}

private struct EveningWidget: Widget {
    var body: some WidgetConfiguration { widgetConfiguration(.evening) }
}

private struct QuranWidget: Widget {
    var body: some WidgetConfiguration { widgetConfiguration(.quran) }
}

@main
struct TamaninaWidgets: WidgetBundle {
    var body: some Widget {
        PrayerWidget()
        RemembranceWidget()
        TasbeehWidget()
        MorningWidget()
        EveningWidget()
        QuranWidget()
    }
}

private extension WidgetConfiguration {
    func useCustomMargins() -> some WidgetConfiguration {
        if #available(iOS 17.0, iOSApplicationExtension 17.0, *) {
            return contentMarginsDisabled()
        } else {
            return self
        }
    }
}

private extension View {
    @ViewBuilder
    func worshipAccent() -> some View {
        if #available(iOS 16.0, iOSApplicationExtension 16.0, *) {
            widgetAccentable()
        } else {
            self
        }
    }

    @ViewBuilder
    func widgetSurface() -> some View {
        if #available(iOS 17.0, iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) { WidgetSurface() }
        } else {
            background(WidgetSurface())
        }
    }
}
