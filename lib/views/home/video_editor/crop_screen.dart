import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:helpers/helpers.dart' as helpers;
import 'package:video_editor/video_editor.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({Key? key, required this.controller}) : super(key: key);

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: (() => Navigator.pop(context)),
                    icon: const Icon(Ionicons.md_close_circle_outline,
                        color: Colors.white),
                    label: const Text(
                      "CANCEL",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      //2 WAYS TO UPDATE CROP
                      //WAY 1:
                      controller.updateCrop();
                      /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      "Crop",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: helpers.AnimatedInteractiveViewer(
                  maxScale: 2.4,
                  child: CropGridViewer(controller: controller),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  aspectRatioButton(
                    "4:3",
                    4 / 3,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    icon: const Icon(Ionicons.md_tablet_landscape,
                        color: Colors.white),
                  ),
                  aspectRatioButton(
                    "1:1",
                    1 / 1,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    icon: const Icon(Ionicons.md_square_outline,
                        color: Colors.white),
                  ),
                  aspectRatioButton(
                    "3:4",
                    3 / 4,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    icon: const Icon(Ionicons.md_tablet_portrait,
                        color: Colors.white),
                  ),
                  aspectRatioButton(
                    "None",
                    null,
                    padding: const EdgeInsets.only(right: 10),
                    icon: const Icon(Icons.rectangle, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget aspectRatioButton(
    String title,
    double? aspectRatio, {
    EdgeInsetsGeometry? padding,
    Widget? icon,
  }) {
    return helpers.SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? const Icon(Icons.aspect_ratio, color: Colors.white),
            const SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
