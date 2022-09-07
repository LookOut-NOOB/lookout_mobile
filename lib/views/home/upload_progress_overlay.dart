import 'package:flutter/material.dart';

class UploadProgressOverlay extends StatefulWidget {
  final List<UploadProgress> progressList;
  const UploadProgressOverlay({Key? key, required this.progressList})
      : super(key: key);

  @override
  State<UploadProgressOverlay> createState() => _UploadProgressOverlayState();
}

class _UploadProgressOverlayState extends State<UploadProgressOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Uploading Files",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ...widget.progressList.map((uploadProgress) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UploadProgressItem(uploadProgress: uploadProgress),
                            const Divider(
                              height: 20,
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UploadProgressItem extends StatelessWidget {
  final UploadProgress uploadProgress;
  const UploadProgressItem({
    Key? key,
    required this.uploadProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            CircularProgressIndicator(
              value: uploadProgress.progress,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Center(
                  child: Text("${(uploadProgress.progress * 100).ceil()}%")),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Text(uploadProgress.label),
      ],
    );
  }
}

class UploadProgress {
  final double progress;
  final String label;

  UploadProgress(this.progress, this.label);
}
