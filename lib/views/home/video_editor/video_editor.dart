import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart' as helpers;
import 'package:progresso/progresso.dart';
import 'package:video_editor/video_editor.dart';

import '../../../../models/recorded_video.dart';
import '../../../services/viewmodels/incident_viewmodel.dart';
import 'crop_screen.dart';

class VideoEditor extends StatefulWidget {
  // final Function(String?) setEditedVideoPath;
  const VideoEditor({
    Key? key,
    required this.file,
    // required this.setEditedVideoPath,
  }) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  late VideoEditorController _controller;
  final IncidentViewModel _incidentViewModel = IncidentViewModel();

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: const Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CropScreen(controller: _controller)));

  void _dontEdit() {
    //just send video path back for compression.
    _incidentViewModel.setRecordedVideo(RecordedVideo(File(widget.file.path)));

    //pop the editing screen
    Navigator.pop(context);
  }

  void _exportVideo() async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isExporting.value = true;
    });
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    await _controller.exportVideo(
        // preset: VideoExportPreset.medium,
        preset: VideoExportPreset.faster,
        customInstruction: "-crf 17",
        onProgress: (statistics, progress) {
          _exportingProgress.value = progress;
          // _exportingProgress.value =
          //     statistics.getTime() / _controller.video.value.duration.inMilliseconds;
        },
        onCompleted: (File? editedFile) {
          if (editedFile != null) {
            _isExporting.value = false;
            _exportingProgress.value = 0.0;

            setState(() => _exported = true);

            //send the edited video path back for compression.
            if (editedFile != null) {
              _incidentViewModel.setRecordedVideo(RecordedVideo(editedFile));
            } else {
              _incidentViewModel.setRecordedVideo(null);
            }
            //pop the editing screen
            Navigator.pop(context);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.delayed(const Duration(milliseconds: 100), () {
        if (!_exported) {
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      }),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                TextButton(
                  onPressed: _dontEdit,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                TextButton.icon(
                  onPressed: _exportVideo,
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text("Done"),
                ),
                const SizedBox(
                  width: 25,
                ),
              ],
            ),
            body: _controller.initialized
                ? SafeArea(
                    child: Stack(children: [
                    Column(children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CropGridViewer(
                                    controller: _controller,
                                    showGrid: false,
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller.video,
                                    builder: (_, __) =>
                                        helpers.OpacityTransition(
                                      visible: !_controller.isPlaying,
                                      child: GestureDetector(
                                        onTap: _controller.video.play,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.play_arrow,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            controlsNavBar(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _trimSlider(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ])
                  ]))
                : const Center(child: CircularProgressIndicator()),
          ),
          ValueListenableBuilder(
            valueListenable: _isExporting,
            builder: (_, bool export, __) => helpers.OpacityTransition(
              visible: export,
              child: ValueListenableBuilder(
                  valueListenable: _exportingProgress,
                  builder: (_, double value, __) {
                    return Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            exportProgressWidget(value),
                          ],
                        ));
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget controlsNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Spacer(),
          Expanded(
            child: GestureDetector(
              onTap: () => _controller.rotate90Degrees(RotateDirection.left),
              child: const Icon(Icons.rotate_left, color: Colors.white),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _controller.rotate90Degrees(RotateDirection.right),
              child: const Icon(Icons.rotate_right, color: Colors.white),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _openCropScreen,
              child: const Icon(Icons.crop, color: Colors.white),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(
                formatter(Duration(seconds: pos.toInt())),
                style: const TextStyle(color: Colors.white),
              ),
              const Expanded(child: SizedBox()),
              helpers.OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    formatter(Duration(seconds: start.toInt())),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                ]),
              ),
              Text(
                formatter(Duration(seconds: end.toInt())),
                style: const TextStyle(color: Colors.white),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
            controller: _controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
              controller: _controller,
              margin: const EdgeInsets.only(top: 10),
            )),
      )
    ];
  }

  Widget exportProgressWidget(double value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 30)
          .copyWith(top: 8),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Applying changes",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "${(value * 100).ceil()}%",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Progresso(
                progress: value,
                backgroundStrokeWidth: 3.0,
                progressStrokeWidth: 5.0,
                progressStrokeCap: StrokeCap.round,
                backgroundStrokeCap: StrokeCap.round),
          ],
        ),
      ),
    );
  }
}
