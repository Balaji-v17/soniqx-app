// ============================================================
//  SONIQ — lib/utils/audio_header_reader.dart
//  Sub-millisecond pure Dart binary audio header reader.
// ============================================================

import 'dart:io';
import 'dart:typed_data';

class AudioHeaderReader {
  /// Reads audio duration directly from file headers in under 1ms.
  static Future<int?> getDurationMs(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    final length = await file.length();
    if (length < 128) return null;

    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      final ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';

      switch (ext) {
        case 'wav':
          return _parseWav(raf, length);
        case 'flac':
          return _parseFlac(raf);
        case 'm4a':
        case 'aac':
        case 'mp4':
          return _parseM4a(raf, length);
        case 'mp3':
        default:
          return _parseMp3(raf, length);
      }
    } catch (_) {
      return null;
    } finally {
      await raf?.close();
    }
  }

  static Future<int?> _parseWav(RandomAccessFile raf, int fileSize) async {
    final header = await raf.read(44);
    if (header.length < 44) return null;
    final view = ByteData.sublistView(header);
    
    if (header[0] != 0x52 || header[1] != 0x49 || header[2] != 0x46 || header[3] != 0x46) return null;
    
    final byteRate = view.getUint32(28, Endian.little);
    if (byteRate == 0) return null;

    final dataSize = fileSize - 44;
    return ((dataSize * 1000) / byteRate).round();
  }

  static Future<int?> _parseFlac(RandomAccessFile raf) async {
    final header = await raf.read(42);
    if (header.length < 42) return null;
    
    if (header[0] != 0x66 || header[1] != 0x4C || header[2] != 0x61 || header[3] != 0x63) return null;

    final b18 = header[18];
    final b19 = header[19];
    final b20 = header[20];
    final sampleRate = ((b18 << 12) | (b19 << 4) | (b20 >> 4)) & 0xFFFFF;

    if (sampleRate == 0) return null;

    final b20low = b20 & 0x0F;
    final b21 = header[21];
    final b22 = header[22];
    final b23 = header[23];
    final b24 = header[24];
    
    final totalSamples = (b20low * 4294967296) + (b21 << 24) + (b22 << 16) + (b23 << 8) + b24;

    if (totalSamples == 0) return null;
    return ((totalSamples * 1000) / sampleRate).round();
  }

  static Future<int?> _parseM4a(RandomAccessFile raf, int fileSize) async {
    final bytesToRead = fileSize < 131072 ? fileSize : 131072;
    final buffer = await raf.read(bytesToRead);
    
    for (int i = 0; i < buffer.length - 32; i++) {
      if (buffer[i] == 0x6D && buffer[i+1] == 0x76 && buffer[i+2] == 0x68 && buffer[i+3] == 0x64) {
        final view = ByteData.sublistView(buffer, i + 4);
        final version = view.getUint8(0);
        
        int timescale = 0;
        int duration = 0;

        if (version == 1) {
          timescale = view.getUint32(12, Endian.big);
          duration = view.getUint64(16, Endian.big);
        } else {
          timescale = view.getUint32(8, Endian.big);
          duration = view.getUint32(12, Endian.big);
        }

        if (timescale > 0 && duration > 0) {
          return ((duration * 1000) / timescale).round();
        }
      }
    }
    return null;
  }

  static Future<int?> _parseMp3(RandomAccessFile raf, int fileSize) async {
    final header = await raf.read(8192);
    if (header.length < 10) return null;

    int offset = 0;

    if (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33) {
      final tagSize = ((header[6] & 0x7F) << 21) |
                      ((header[7] & 0x7F) << 14) |
                      ((header[8] & 0x7F) << 7)  |
                       (header[9] & 0x7F);
      offset = 10 + tagSize;

      for (int i = 10; i < header.length - 12; i++) {
        if (header[i] == 0x54 && header[i+1] == 0x4C && header[i+2] == 0x45 && header[i+3] == 0x4E) {
          final frameSize = (header[i+4] << 24) | (header[i+5] << 16) | (header[i+6] << 8) | header[i+7];
          if (frameSize > 0 && frameSize < 20 && (i + 10 + frameSize) <= header.length) {
            final tlenStr = String.fromCharCodes(header.sublist(i + 11, i + 10 + frameSize)).trim();
            final ms = int.tryParse(RegExp(r'\d+').stringMatch(tlenStr) ?? '');
            if (ms != null && ms > 0) return ms;
          }
        }
      }
    }

    if (offset < header.length - 156) {
      for (int i = offset; i < header.length - 156; i++) {
        if (header[i] == 0xFF && (header[i+1] & 0xE0) == 0xE0) {
          final view = ByteData.sublistView(header, i);
          final headerInt = view.getUint32(0, Endian.big);

          final bitrateIdx = (headerInt >> 12) & 0x0F;
          final sampleRateIdx = (headerInt >> 10) & 0x03;
          
          const bitrates = [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320];
          const sampleRates = [44100, 48000, 32000];

          if (bitrateIdx > 0 && bitrateIdx < bitrates.length && sampleRateIdx < sampleRates.length) {
            final bitrateKbps = bitrates[bitrateIdx];
            final audioBytes = fileSize - offset;
            final durationSec = (audioBytes * 8) / (bitrateKbps * 1000);
            if (durationSec > 0) return (durationSec * 1000).round();
          }
        }
      }
    }
    return null;
  }
}