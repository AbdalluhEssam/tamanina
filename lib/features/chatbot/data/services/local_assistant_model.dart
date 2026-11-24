import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:fllama/fllama.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../model/chat_message.dart';

enum LocalModelStatus { checking, missing, downloading, ready, failed }

class LocalAssistantModel extends ChangeNotifier {
  LocalAssistantModel._();

  static final instance = LocalAssistantModel._();
  static const _runtimeChannel = MethodChannel('fllama');
  static const expectedBytes = 491400032;
  static const _checksum =
      '74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db';
  static final _source = Uri.parse(
    'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/'
    '9217f5db79a29953eb74d5343926648285ec7e67/'
    'qwen2.5-0.5b-instruct-q4_k_m.gguf',
  );

  LocalModelStatus _status = LocalModelStatus.checking;
  int _percent = 0;
  HttpClient? _client;
  Future<File?>? _lookup;
  bool _cancelled = false;
  bool _generating = false;

  bool get supported => switch (Abi.current()) {
    Abi.androidArm64 || Abi.androidX64 || Abi.iosArm64 || Abi.iosX64 => true,
    _ => false,
  };
  LocalModelStatus get status => _status;
  int get percent => _percent;

  Future<File> _modelFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(
      '${directory.path}/assistant/qwen2.5-0.5b-instruct-q4_k_m.gguf',
    );
  }

  Future<File?> _existingFile() => _lookup ??= _findModel();

  Future<File?> _findModel() async {
    if (!supported) return null;
    try {
      final file = await _modelFile();
      if (await file.exists() && await file.length() == expectedBytes) {
        return file;
      }
    } catch (_) {
      // Offline app help is available without a model directory.
    }
    return null;
  }

  Future<void> check() async {
    final file = await _existingFile();
    if (_status == LocalModelStatus.checking) {
      _setStatus(
        file == null ? LocalModelStatus.missing : LocalModelStatus.ready,
      );
    }
  }

  void _setStatus(LocalModelStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<void> download() async {
    if (!supported || _client != null || _status == LocalModelStatus.ready) {
      return;
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    _client = client;
    _cancelled = false;
    _percent = 0;
    _setStatus(LocalModelStatus.downloading);
    File? partial;
    try {
      final file = await _modelFile();
      partial = File('${file.path}.part');
      await partial.parent.create(recursive: true);
      final request = await client.getUrl(_source);
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != HttpStatus.ok ||
          (response.contentLength != -1 &&
              response.contentLength != expectedBytes)) {
        throw const FormatException('Unexpected model response');
      }
      var bytes = 0;
      final output = partial.openWrite();
      try {
        await output.addStream(
          response.timeout(const Duration(seconds: 30)).map((chunk) {
            bytes += chunk.length;
            if (_cancelled || bytes > expectedBytes) {
              throw const FormatException('Incomplete model download');
            }
            final progress = bytes * 100 ~/ expectedBytes;
            if (progress != _percent) {
              _percent = progress;
              notifyListeners();
            }
            return chunk;
          }),
        );
      } finally {
        await output.close();
      }
      final digest = await sha256.bind(partial.openRead()).first;
      if (_cancelled ||
          bytes != expectedBytes ||
          digest.toString() != _checksum) {
        throw const FormatException('Invalid model checksum');
      }
      await partial.rename(file.path);
      _lookup = Future.value(file);
      _setStatus(LocalModelStatus.ready);
    } catch (_) {
      _setStatus(
        _cancelled ? LocalModelStatus.missing : LocalModelStatus.failed,
      );
    } finally {
      client.close(force: true);
      try {
        if (await partial?.exists() == true) await partial?.delete();
      } catch (_) {
        // A subsequent download overwrites the partial file.
      }
      _client = null;
    }
  }

  void cancelDownload() {
    _cancelled = true;
    _client?.close(force: true);
  }

  Future<void> remove() async {
    if (_generating || _client != null) return;
    final file = await _existingFile();
    try {
      if (file != null && await file.exists()) await file.delete();
      _lookup = null;
      _setStatus(LocalModelStatus.missing);
    } catch (_) {
      _setStatus(LocalModelStatus.failed);
    }
  }

  Future<String?> answer(
    String question,
    List<ChatMessage> history, {
    required bool arabic,
  }) async {
    final model = await _existingFile();
    if (model == null || _generating) return null;
    final runtime = Fllama.instance()!;
    final threads = math.min(4, Platform.numberOfProcessors);
    double? contextId;
    var operation = 'load';
    _generating = true;
    try {
      final context = await _runtimeChannel.invokeMapMethod<Object?, dynamic>(
        'initContext',
        {
          'model': model.path,
          'n_ctx': 1536,
          'n_batch': 144,
          'n_threads': threads,
          'n_gpu_layers': 0,
          'use_mlock': false,
          'use_mmap': true,
          // fllama's iOS loader requires this to initialize its native callback.
          'use_progress_callback': true,
        },
      );
      final rawId = context?['contextId'];
      if (rawId is! num) return null;
      contextId = rawId.toDouble();
      final language = arabic ? 'Arabic' : 'English';
      final turns = history.reversed
          .where((turn) => turn.type != MessageType.greeting)
          .take(2)
          .toList()
          .reversed;
      // This is the chat template of the pinned Qwen model.
      final prompt = StringBuffer();
      void appendTurn(String role, String content) {
        prompt.write('<|im_start|>$role\n$content<|im_end|>\n');
      }

      appendTurn(
        'system',
        'You are the Tamanina assistant. Reply concisely in $language. '
            'Say when you are unsure. Do not invent Quran verses, hadith or '
            'citations. Refer personal religious rulings to a qualified scholar.',
      );
      for (final turn in turns) {
        appendTurn(
          turn.isUser ? 'user' : 'assistant',
          _shorten(turn.content, 210),
        );
      }
      appendTurn('user', _shorten(question, 580));
      prompt.write('<|im_start|>assistant\n');

      operation = 'generate';
      final response = await runtime.completion(
        contextId,
        prompt: prompt.toString(),
        temperature: 0.3,
        nPredict: 144,
        nThreads: threads,
        stop: ['<|im_end|>', '<|endoftext|>'],
      );
      final value = response?['text'];
      if (value is! String || value.trim().isEmpty) return null;
      return value.trim();
    } catch (error) {
      if (kDebugMode) {
        final code = error is PlatformException
            ? error.code
            : error.runtimeType;
        debugPrint('On-device assistant could not $operation ($code)');
      }
      return null;
    } finally {
      if (contextId != null) {
        try {
          await runtime.releaseContext(contextId);
        } catch (_) {
          // The platform may already have released the context.
        }
      }
      _generating = false;
    }
  }

  String _shorten(String value, int length) => String.fromCharCodes(
    value.runes.take(length),
  ).replaceAll(RegExp(r'<\|(?:im_start|im_end|endoftext)\|>'), '');
}
