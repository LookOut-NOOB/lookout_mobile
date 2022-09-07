import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:image_picker/image_picker.dart';
import 'package:look_out/services/viewmodels/incident_viewmodel.dart';
import 'package:video_compress/video_compress.dart';

import '../../../models/recorded_video.dart';
import '../../main.dart';
import 'app_video_player.dart';
import 'compression_view_widget.dart';
import 'video_editor/video_editor.dart';

class RecordingMethodWidget extends StatefulWidget {
  final Function() doneVideoRecording;

  const RecordingMethodWidget({
    Key? key,
    required this.doneVideoRecording,
  }) : super(key: key);

  @override
  State<RecordingMethodWidget> createState() => _RecordingMethodWidgetState();
}

class _RecordingMethodWidgetState extends State<RecordingMethodWidget> {
  String? videoPath;
  String? finalVideoPath;
  RecordedVideo? recordedVideo;
  final IncidentViewModel _incidentViewModel = IncidentViewModel();

  Subscription? subscription;
  double? progress;

  @override
  void initState() {
    recordedVideo = _incidentViewModel.getRecordedVideo();

    videoPath = recordedVideo?.originalVideoFile.path;
    finalVideoPath = recordedVideo?.compressedVideo?.path;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription = VideoCompress.compressProgress$.subscribe((event) {
      setState(() => progress = event);
    });
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression();
    subscription?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormField(
          // validator: (value) {
          //   if (videoPath == null) {
          //     return "Video Recording is required.";
          //   }
          //   return null;
          // },
          builder: (state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: videoPath != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (finalVideoPath != null)
                              AppVideoPlayer(videoPath: finalVideoPath!),
                            const SizedBox(
                              height: 10,
                            ),
                            CompressionViewWidget(
                              progress: progress,
                              recordedVideo: recordedVideo,
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
                if (!state.validate())
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      state.errorText ?? "invalid recording",
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: onPressedRecordVideo,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Ionicons.ios_videocam,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text("Record Video"),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: onPressedPickVideo,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Ionicons.md_document,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text("Pick Video"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void onPressedRecordVideo() {
    onPressedGetVideo(ImageSource.camera);
  }

  void onPressedPickVideo() {
    onPressedGetVideo(ImageSource.gallery);
  }

  Future<XFile?> getVideo(ImageSource source) async {
    return ImagePicker().pickVideo(source: source);
  }

  void onPressedGetVideo(ImageSource source) async {
    setState(() {
      videoPath = null;
    });
    _incidentViewModel.setRecordedVideo(null);

    VideoCompress.cancelCompression();
    try {
      await getVideo(source).then((value) async {
        if (value != null) {
          String gotPath = value.path;
          setState(() {
            videoPath = gotPath;
          });
          if (videoPath != null) {
            //if a video was recorded, then show video editor
            await Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => VideoEditor(
                  file: File(videoPath!),
                ),
              ),
            )
                .whenComplete(() {
              setState(() {
                recordedVideo = _incidentViewModel.getRecordedVideo();
                finalVideoPath = null;
              });
            });
            //Starts video compression.
            MediaInfo? compressedVideo =
                await _incidentViewModel.compressRecordedVideo();
            recordedVideo?.compressedVideo = compressedVideo;
            _incidentViewModel.setRecordedVideo(recordedVideo);

            setState(() {
              recordedVideo = _incidentViewModel.getRecordedVideo();
              finalVideoPath = recordedVideo!.compressedVideo?.path ??
                  recordedVideo!.originalVideoFile.path;
            });
            widget.doneVideoRecording();
          }
        }
      });
    } catch (e) {
      printDebug("Failed to record video: $e");
    }
  }
}
