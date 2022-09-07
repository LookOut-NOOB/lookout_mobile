import 'dart:io';

import 'package:video_compress/video_compress.dart';

import '../main.dart';

class RecordedVideo {
  File originalVideoFile;
  int? originalVideoSize;
  MediaInfo? compressedVideo;
  File? videoThumbnail;

  RecordedVideo(this.originalVideoFile) {
    generateVideoThumbnail();
    getVideoSize();
    // compressVideo();
  }

  Future generateVideoThumbnail() async {
    final thumbFile =
        await VideoCompress.getFileThumbnail(originalVideoFile.path);
    videoThumbnail = thumbFile;
  }

  Future getVideoSize() async {
    final size = await originalVideoFile.length();
    originalVideoSize = size;
  }

  // Future<MediaInfo?> compressVideo() async {
  //   try {
  //     await VideoCompress.setLogLevel(0);
  //     final MediaInfo? compressedInfo = await VideoCompress.compressVideo(
  //       originalVideoFile.path,
  //       quality: VideoQuality.DefaultQuality,
  //       deleteOrigin: false,
  //       includeAudio: true,
  //     );
  //     compressedVideo = compressedInfo;
  //     return compressedInfo;
  //   } on Exception catch (e) {
  //     VideoCompress.cancelCompression();
  //     printDebug("Failed to compress video! : ($e)");
  //     return null;
  //   }
  // }

  Future<MediaInfo?> justCompressVideo() async {
    try {
      await VideoCompress.setLogLevel(0);
      final MediaInfo? compressedInfo = await VideoCompress.compressVideo(
        originalVideoFile.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return compressedInfo;
    } on Exception catch (e) {
      VideoCompress.cancelCompression();
      printDebug("Failed to compress video! : ($e)");
      return null;
    }
  }
}
