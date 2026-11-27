import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

Uri? _artwork;

/// The cover image shown in the media notification and on the lock screen.
Future<Uri?> recitationArtwork() async {
  if (_artwork != null) return _artwork;
  try {
    final support = await getApplicationSupportDirectory();
    final file = File('${support.path}/media/recitation_art.png');
    if (!await file.exists() || await file.length() == 0) {
      final data = await rootBundle.load('assets/images/media_art.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    return _artwork = Uri.file(file.path);
  } catch (_) {
    return null;
  }
}

class RecitationPlayback extends BaseAudioHandler {
  RecitationPlayback._() {
    _player.playbackEventStream.listen((_) => _publishState());
    _player.errorStream.listen((_) => unawaited(stop()));
    _player.currentIndexStream.listen(_onIndex);
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _completions.add(null);
        unawaited(stop());
      } else {
        _publishState();
      }
    });
  }

  static Future<RecitationPlayback>? _instance;

  static Future<RecitationPlayback> get instance => _instance ??=
      AudioService.init(
        builder: RecitationPlayback._,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.abdalluh.tamanina.recitation',
          androidNotificationChannelName: 'Quran recitation',
          androidNotificationIcon: 'drawable/ic_notification',
          androidStopForegroundOnPause: false,
        ),
      ).onError<Object>((error, stackTrace) {
        _instance = null;
        Error.throwWithStackTrace(error, stackTrace);
      });

  final _player = AudioPlayer();
  final _completions = StreamController<void>.broadcast();
  List<MediaItem> _items = const [];
  int _revision = 0;

  /// Fires when the whole playlist has been played to the end.
  Stream<void> get completions => _completions.stream;

  /// Index of the item being played.
  Stream<int?> get currentIndex => _player.currentIndexStream;

  void _onIndex(int? index) {
    if (index != null && index < _items.length) mediaItem.add(_items[index]);
    _publishState();
  }

  bool get hasPage => mediaItem.value != null;

  Future<void> preparePage({
    required int page,
    required String title,
    required List<AudioSource> sources,
    List<MediaItem>? items,
  }) async {
    final revision = ++_revision;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    if (revision != _revision) return;
    _items = items ?? const [];
    mediaItem.add(
      _items.isNotEmpty
          ? _items.first
          : MediaItem(id: 'mushaf-page-$page', title: title),
    );
    await _player.setAudioSources(sources).timeout(const Duration(seconds: 15));
  }

  void _publishState() => playbackState.add(
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (_player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
    ),
  );

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    _revision++;
    _items = const [];
    mediaItem.add(null);
    await _player.stop();
    await super.stop();
  }
}
