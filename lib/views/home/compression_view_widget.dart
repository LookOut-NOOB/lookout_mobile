import 'package:flutter/material.dart';
import 'package:progresso/progresso.dart';
import 'package:video_compress/video_compress.dart';

import '../../../models/recorded_video.dart';

class CompressionViewWidget extends StatelessWidget {
  const CompressionViewWidget({
    Key? key,
    required this.progress,
    required this.recordedVideo,
  }) : super(key: key);

  final double? progress;
  final RecordedVideo? recordedVideo;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (recordedVideo?.compressedVideo != null) {
          int originalSize =
              (recordedVideo?.originalVideoSize ?? 0) / 1024 ~/ 1024;
          int compressedSize =
              (recordedVideo?.compressedVideo?.filesize ?? 0) / 1024 ~/ 1024;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Compression complete",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Original size: ($originalSize MB )",
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(
                height: 3,
              ),
              Row(
                children: [
                  const Text(
                    "Current size: ",
                  ),
                  Text(
                    "($compressedSize MB )",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: compressedSize > originalSize
                              ? Colors.red
                              : Colors.green,
                        ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Compressing video",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              children: [
                Expanded(
                  child: Progresso(
                      progress: (progress ?? 0) / 100,
                      backgroundStrokeWidth: 3.0,
                      progressStrokeWidth: 5.0,
                      progressStrokeCap: StrokeCap.round,
                      backgroundStrokeCap: StrokeCap.round),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () => VideoCompress.cancelCompression(),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
