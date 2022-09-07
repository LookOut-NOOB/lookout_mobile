import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  final String videoPath;
  const AppVideoPlayer({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool playerLoaded = false;
  double aspectRatio = 0;

  @override
  void initState() {
    if (widget.videoPath.contains("http")) {
      videoPlayerController = VideoPlayerController.network(widget.videoPath);
    } else {
      videoPlayerController =
          VideoPlayerController.file(File(widget.videoPath));
    }
    initializePlayer();
    super.initState();
  }

  initializePlayer() async {
    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: false,
      looping: false,
      fullScreenByDefault: false,
      allowPlaybackSpeedChanging: false,
    );
    setState(() {
      aspectRatio = videoPlayerController!.value.aspectRatio;
      playerLoaded = true;
    });
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return playerLoaded
        ? AspectRatio(
            aspectRatio: aspectRatio,
            child: Chewie(
              controller: chewieController!,
            ),
          )
        : Container(
            // color: Colors.black,
            padding: const EdgeInsets.all(10),
            child: const Center(
              child: CircularProgressIndicator(
                  // valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
            ),
          );
  }
}
