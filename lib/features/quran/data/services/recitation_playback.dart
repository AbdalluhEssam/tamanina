import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class RecitationPlayback extends BaseAudioHandler {
  RecitationPlayback._() {
    _player.playbackEventStream.listen((_) => _publishState());
    _player.errorStream.listen((_) => unawaited(stop()));
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
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
  int _revision = 0;

  bool get hasPage => mediaItem.value != null;

  Future<void> preparePage({
    required int page,
    required String title,
    required List<AudioSource> sources,
  }) async {
    final revision = ++_revision;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    if (revision != _revision) return;
    mediaItem.add(MediaItem(id: 'mushaf-page-$page', title: title));
    await _player.setAudioSources(sources).timeout(const Duration(seconds: 15));
  }

  void _publishState() => playbackState.add(
    PlaybackState(
      controls: [
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
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
  Future<void> stop() async {
    _revision++;
    mediaItem.add(null);
    await _player.stop();
    await super.stop();
  }
}
