import 'dart:convert';

/// A Quran reciter whose verse-by-verse recitation is streamed or downloaded
/// from cdn.islamic.network.
class Reciter {
  const Reciter(this.id, this.nameAr, this.nameEn, this.bitrate);

  final String id;
  final String nameAr;
  final String nameEn;
  final int bitrate;

  Uri verseUri(int verse) => Uri.parse(
    'https://cdn.islamic.network/quran/audio/$bitrate/$id/$verse.mp3',
  );
}

const defaultReciterId = 'ar.alafasy';

/// Editions whose first and last verse were checked on the CDN at the listed
/// bitrate.
const builtInReciters = [
  Reciter('ar.alafasy', 'مشاري العفاسي', 'Mishary Alafasy', 128),
  Reciter('ar.husary', 'محمود خليل الحصري', 'Mahmoud Khalil Al-Husary', 128),
  Reciter('ar.husarymujawwad', 'الحصري (المجوّد)', 'Al-Husary (Mujawwad)', 128),
  Reciter('ar.mahermuaiqly', 'ماهر المعيقلي', 'Maher Al-Muaiqly', 128),
  Reciter('ar.hudhaify', 'علي الحذيفي', 'Ali Al-Hudhaify', 128),
  Reciter('ar.shaatree', 'أبو بكر الشاطري', 'Abu Bakr Ash-Shaatree', 128),
  Reciter('ar.ahmedajamy', 'أحمد العجمي', 'Ahmed Al-Ajamy', 128),
  Reciter('ar.muhammadayyoub', 'محمد أيوب', 'Muhammad Ayyoub', 128),
  Reciter('ar.muhammadjibreel', 'محمد جبريل', 'Muhammad Jibreel', 128),
  Reciter(
    'ar.abdurrahmaansudais',
    'عبد الرحمن السديس',
    'Abdurrahman As-Sudais',
    64,
  ),
  Reciter('ar.saoodshuraym', 'سعود الشريم', 'Saud Ash-Shuraim', 64),
  Reciter(
    'ar.abdulsamad',
    'عبد الباسط عبد الصمد',
    'Abdul Basit Abdus-Samad',
    64,
  ),
  Reciter('ar.hanirifai', 'هاني الرفاعي', 'Hani Ar-Rifai', 64),
  Reciter('ar.abdullahbasfar', 'عبد الله بصفر', 'Abdullah Basfar', 64),
  Reciter('ar.aymanswoaid', 'أيمن سويد', 'Ayman Sowaid', 64),
];

/// One downloadable adhan recording.
class AdhanFile {
  const AdhanFile({
    required this.url,
    required this.sha256,
    required this.bytes,
    required this.durationMs,
    this.phrases,
    this.iosUrl,
    this.iosSha256,
    this.iosBytes,
  });

  final Uri url;
  final String sha256;
  final int bytes;
  final int durationMs;

  /// Start and end seconds of each adhan phrase, in the standard order. Without
  /// them the screen shows the phrases without highlighting.
  final List<({double start, double end})>? phrases;

  /// Notification clip for iOS: at most 30 seconds, `.caf`, `.aiff` or `.wav`.
  final Uri? iosUrl;
  final String? iosSha256;
  final int? iosBytes;

  static AdhanFile? fromJson(Object? json) {
    if (json is! Map) return null;
    final url = _httpsUri(json['url']);
    final sha = _sha(json['sha256']);
    final bytes = json['bytes'];
    final duration = json['durationMs'];
    if (url == null ||
        sha == null ||
        bytes is! int ||
        bytes <= 0 ||
        duration is! int ||
        duration <= 0) {
      return null;
    }
    final timings = _parsePhrases(json['phrases']);
    final iosUrl = _httpsUri(json['iosUrl']);
    final iosSha = _sha(json['iosSha256']);
    final iosBytes = json['iosBytes'];
    final hasIos = iosUrl != null && iosSha != null && iosBytes is int;
    return AdhanFile(
      url: url,
      sha256: sha,
      bytes: bytes,
      durationMs: duration,
      phrases: timings,
      iosUrl: hasIos ? iosUrl : null,
      iosSha256: hasIos ? iosSha : null,
      iosBytes: hasIos ? iosBytes : null,
    );
  }
}

/// An adhan voice. The bundled voice has no files to download.
class AdhanVoice {
  const AdhanVoice({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.main,
    this.fajr,
    this.credit,
  });

  static const bundledId = 'local';
  static const bundled = AdhanVoice(
    id: bundledId,
    nameAr: 'أذان طمأنينة',
    nameEn: 'Tamanina adhan',
  );

  final String id;
  final String nameAr;
  final String nameEn;
  final AdhanFile? main;

  /// Optional separate recording for Fajr. Falls back to [main].
  final AdhanFile? fajr;

  /// Attribution shown with the voice, e.g. the recordist and license.
  final String? credit;

  bool get isBundled => main == null;

  AdhanFile? fileFor({required bool isFajr}) => isFajr ? (fajr ?? main) : main;

  Iterable<AdhanFile> get files => [?main, ?fajr];

  int get totalBytes =>
      files.fold(0, (sum, file) => sum + file.bytes + (file.iosBytes ?? 0));
}

/// One downloadable file with the Mushaf pages [from]..[to].
class MushafChunk {
  const MushafChunk({
    required this.from,
    required this.to,
    required this.url,
    required this.sha256,
    required this.bytes,
  });

  final int from;
  final int to;
  final Uri url;
  final String sha256;
  final int bytes;
}

/// The printed Mushaf pages that are not bundled with the app.
class MushafPack {
  const MushafPack({required this.bundledPages, required this.chunks});

  final int bundledPages;
  final List<MushafChunk> chunks;

  int get totalBytes => chunks.fold(0, (sum, chunk) => sum + chunk.bytes);

  static MushafPack? fromJson(Object? json) {
    if (json is! Map) return null;
    final bundled = json['bundledPages'];
    final items = json['chunks'];
    if (bundled is! int || bundled < 0 || items is! List || items.isEmpty) {
      return null;
    }
    final chunks = <MushafChunk>[];
    for (final item in items) {
      if (item is! Map) return null;
      final from = item['from'];
      final to = item['to'];
      final url = _httpsUri(item['url']);
      final sha = _sha(item['sha256']);
      final bytes = item['bytes'];
      if (from is! int ||
          to is! int ||
          from <= bundled ||
          to < from ||
          to > 604 ||
          url == null ||
          sha == null ||
          bytes is! int ||
          bytes <= 0 ||
          (chunks.isNotEmpty && from <= chunks.last.to)) {
        return null;
      }
      chunks.add(
        MushafChunk(from: from, to: to, url: url, sha256: sha, bytes: bytes),
      );
    }
    return MushafPack(bundledPages: bundled, chunks: chunks);
  }
}

/// Voices and reciters the app offers. Remote Config can extend the catalog;
/// without it the bundled voice and the built-in reciters remain.
class AudioCatalog {
  const AudioCatalog({
    required this.reciters,
    required this.adhanVoices,
    this.mushaf,
  });

  static const fallback = AudioCatalog(
    reciters: builtInReciters,
    adhanVoices: [AdhanVoice.bundled],
  );

  final List<Reciter> reciters;
  final List<AdhanVoice> adhanVoices;
  final MushafPack? mushaf;

  Reciter reciter(String id) => reciters.firstWhere(
    (reciter) => reciter.id == id,
    orElse: () => reciters.first,
  );

  AdhanVoice voice(String id) => adhanVoices.firstWhere(
    (voice) => voice.id == id,
    orElse: () => AdhanVoice.bundled,
  );

  /// Applies [source] on top of [base]: voices are added or replaced by id,
  /// and the reciter list and Mushaf pack are replaced when present.
  factory AudioCatalog.fromJson(String source, {AudioCatalog base = fallback}) {
    try {
      final json = jsonDecode(source);
      if (json is! Map) return base;
      final reciters = <Reciter>[];
      final remoteReciters = json['reciters'];
      if (remoteReciters is List) {
        for (final item in remoteReciters) {
          if (item is! Map) continue;
          final id = item['id'];
          final bitrate = item['bitrate'];
          final nameAr = item['nameAr'];
          final nameEn = item['nameEn'];
          if (id is String &&
              RegExp(r'^[a-z]{2}\.[a-z0-9-]{2,40}$').hasMatch(id) &&
              const {32, 40, 48, 64, 128, 192}.contains(bitrate) &&
              nameAr is String &&
              nameAr.isNotEmpty &&
              nameEn is String &&
              nameEn.isNotEmpty &&
              !reciters.any((reciter) => reciter.id == id)) {
            reciters.add(Reciter(id, nameAr, nameEn, bitrate as int));
          }
        }
      }
      final voices = <AdhanVoice>[...base.adhanVoices];
      final remoteVoices = json['adhan'];
      if (remoteVoices is List) {
        for (final item in remoteVoices) {
          if (item is! Map) continue;
          final id = item['id'];
          final nameAr = item['nameAr'];
          final nameEn = item['nameEn'];
          final main = AdhanFile.fromJson(item['main']);
          if (id is! String ||
              !RegExp(r'^[a-z0-9_-]{1,32}$').hasMatch(id) ||
              nameAr is! String ||
              nameAr.isEmpty ||
              nameEn is! String ||
              nameEn.isEmpty ||
              main == null ||
              id == AdhanVoice.bundledId) {
            continue;
          }
          final credit = item['credit'];
          final voice = AdhanVoice(
            id: id,
            nameAr: nameAr,
            nameEn: nameEn,
            main: main,
            fajr: AdhanFile.fromJson(item['fajr']),
            credit: credit is String && credit.isNotEmpty ? credit : null,
          );
          final index = voices.indexWhere((existing) => existing.id == id);
          if (index >= 0) {
            voices[index] = voice;
          } else {
            voices.add(voice);
          }
        }
      }
      return AudioCatalog(
        reciters: reciters.isEmpty ? base.reciters : reciters,
        adhanVoices: voices,
        mushaf: MushafPack.fromJson(json['mushaf']) ?? base.mushaf,
      );
    } catch (_) {
      return base;
    }
  }
}

List<({double start, double end})>? _parsePhrases(Object? value) {
  if (value is! List || value.isEmpty) return null;
  final result = <({double start, double end})>[];
  for (final item in value) {
    if (item is! List ||
        item.length != 2 ||
        item[0] is! num ||
        item[1] is! num) {
      return null;
    }
    final start = (item[0] as num).toDouble();
    final end = (item[1] as num).toDouble();
    if (end <= start || (result.isNotEmpty && start < result.last.end - 1)) {
      return null;
    }
    result.add((start: start, end: end));
  }
  return result;
}

Uri? _httpsUri(Object? value) {
  if (value is! String) return null;
  final uri = Uri.tryParse(value);
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
      ? uri
      : null;
}

String? _sha(Object? value) =>
    value is String && RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value)
    ? value.toLowerCase()
    : null;
