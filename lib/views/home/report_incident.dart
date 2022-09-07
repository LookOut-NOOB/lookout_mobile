import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get_it/get_it.dart';
import 'package:helpers/helpers.dart' as helpers;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:look_out/app.dart';
import 'package:look_out/models/incident.dart';
import 'package:look_out/services/location_service.dart';
import 'package:look_out/widgets/dialogs.dart';

import '../../main.dart';
import '../../services/viewmodels/incident_viewmodel.dart';
import '../app_viewmodel.dart';
import 'recording_method_widget.dart';
import 'upload_progress_overlay.dart';

class ReportIncident extends StatefulWidget {
  static const String routeName = "/report_incident";
  final Function(String type)? resetSuccess;
  const ReportIncident({Key? key, this.resetSuccess}) : super(key: key);

  @override
  _ReportIncidentState createState() => _ReportIncidentState();
}

class _ReportIncidentState extends State<ReportIncident> {
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _incidentCtrl = TextEditingController();
  final TextEditingController _statementCtrl = TextEditingController();
  bool shareContact = false;
  List<String> myList = ["Tonny", "Baw"];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final appViewModel = GetIt.instance<AppViewModel>();
  IncidentViewModel incidentViewModel = IncidentViewModel();

  List<File> additionalImageFiles = [];
  double? additionalImagesUploadProgress;
  double? videoRecordingUploadProgress;
  final _isSubmitting = ValueNotifier<bool>(false);

  String? videoPath;
  String? videoThumbnailPath;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReportIncident;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Report Incident"),
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: const [
                            Icon(Icons.location_pin),
                            SizedBox(
                              width: 2,
                            ),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Your location is being captured automatically!",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _incidentCtrl,
                      decoration:
                          _inputDecoOutline(hint: 'Name to describe incident'),
                    ),
                    const Divider(),
                    CheckboxListTile(
                        value: shareContact,
                        title: const Text("Share my contact information"),
                        subtitle: const Text(
                            "Your name and phone number will be shared to authorities for more inquiries"),
                        onChanged: (newValue) {
                          setState(() {
                            shareContact = newValue ?? false;
                          });
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ])),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _statementCtrl,
                        decoration: _inputDecoOutline(
                            hint:
                                'Provide a brief statement to describe more (optional)'),
                        minLines: 5,
                        maxLines: 10,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      RecordingMethodWidget(
                        doneVideoRecording: () => setState(() {
                          videoPath = incidentViewModel
                              .getRecordedVideo()
                              ?.compressedVideo
                              ?.path;
                          videoThumbnailPath = incidentViewModel
                              .getRecordedVideo()
                              ?.videoThumbnail
                              ?.path;
                        }),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Theme.of(context).textTheme.caption?.color,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Attach photos (Optional)",
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 8,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                            itemCount: additionalImageFiles.length + 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              if (index == additionalImageFiles.length) {
                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.blue,
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        pickMultiple();
                                      },
                                      icon: const Icon(
                                        Ionicons.md_add_circle_outline,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return imageTile(
                                  imageFile: additionalImageFiles[index]);
                            }),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            reportIncident(context, args);
                          },
                          child: const Text("Report")),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder(
              valueListenable: _isSubmitting,
              builder: (_, bool submitting, __) {
                return helpers.OpacityTransition(
                  visible: submitting,
                  child: Center(
                    child: UploadProgressOverlay(
                      progressList: [
                        if (videoRecordingUploadProgress != null)
                          UploadProgress(
                            videoRecordingUploadProgress!,
                            "Uploading Video Recording",
                          ),
                        if (additionalImagesUploadProgress != null)
                          UploadProgress(
                            additionalImagesUploadProgress!,
                            "Uploading Images",
                          ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  // void onPressedGetVideo(ImageSource source) async {
  //   setState(() {
  //     videoPath = null;
  //   });
  //   recordedVideo = null;

  //   VideoCompress.cancelCompression();
  //   try {
  //     await getVideo(source).then((value) async {
  //       if (value != null) {
  //         String gotPath = value.path;
  //         setState(() {
  //           videoPath = gotPath;
  //         });
  //         if (videoPath != null) {
  //           //if a video was recorded, then show video editor
  //           await Navigator.of(context)
  //               .push(
  //             MaterialPageRoute(
  //               builder: (context) => VideoEditor(
  //                 file: File(videoPath!),
  //                 setEditedVideo: (RecordedVideo? recordedVid) {
  //                   setState(() {
  //                     recordedVideo = recordedVid;
  //                   });
  //                 },
  //               ),
  //             ),
  //           )
  //               .whenComplete(() {
  //             setState(() {
  //               finalVideoPath = null;
  //             });
  //           });
  //           //Starts video compression.
  //           MediaInfo? compressedVideo = await appViewModel.repository
  //               .compressRecordedVideo(recordedVideo);
  //           recordedVideo?.compressedVideo = compressedVideo;

  //           setState(() {
  //             finalVideoPath = recordedVideo!.compressedVideo?.path ??
  //                 recordedVideo!.originalVideoFile.path;
  //           });
  //           setState(() {
  //             videoPath = recordedVideo?.compressedVideo?.path;
  //             videoThumbnailPath = recordedVideo?.videoThumbnail?.path;
  //           });
  //         }
  //       }
  //     });
  //   } catch (e) {
  //     printDebug("Failed to record video: $e");
  //   }
  // }

  void reportIncident(BuildContext context, ReportIncident args) {
    if (_formKey.currentState!.validate()) {
      loadingDialog(context, message: "Reporting Incident");
      String incidentId = uuid.v4();
      LocationService()
          .getCurrentLocation()
          .then((LocationData? locationData) async {
        GeoPoint? geoPoint;

        List<String> additionalImagesDownloadUrls = [];

        setUploadQueue();
        File videoFile = File(videoPath!);

        String? videoDownloadUrl = await uploadVideo(incidentId, videoFile);

        String? videoThumbnailDownloadUrl;
        if (videoThumbnailPath != null) {
          File videoThumbnailFile = File(videoThumbnailPath!);
          videoThumbnailDownloadUrl = await incidentViewModel
              .uploadVideoThumbnailFileToStorage(incidentId, videoThumbnailFile)
              .then((value) {
            videoThumbnailFile.delete();
            setState(() {
              videoRecordingUploadProgress = 1.0;
            });
            return value;
          });
        }

        additionalImagesDownloadUrls =
            await uploadAdditionalImageFiles(incidentId);

        if (locationData != null) {
          geoPoint = GeoPoint(locationData.latitude!, locationData.longitude!);
          Incident incident = Incident(
            id: incidentId,
            name: _incidentCtrl.text,
            location: geoPoint,
            dateTime: DateTime.now(),
            statement: _statementCtrl.text,
            imagesDownloadUrls: additionalImagesDownloadUrls,
            userId: shareContact ? appViewModel.repository.profile?.uid : null,
          );
          incidentViewModel.submitReportedIncident(incident).then((value) {
            popDialog(context);
            if (value) {
              //pop route
              Navigator.of(context).pop();
              args.resetSuccess!("report");
            }
          });
        } else {
          popDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to get current location')));
        }
      }).catchError((error) {
        popDialog(context);
        printDebug("Error getting location: $error");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error getting current location')));
      });
    }
  }

  void setUploadQueue() {
    if (additionalImageFiles.isNotEmpty) {
      setState(() {
        additionalImagesUploadProgress = 0.0;
      });
    }
  }

  Future<List<String>> uploadAdditionalImageFiles(String articleId) async {
    List<String> additionalImagesDownloadUrls = [];
    if (additionalImageFiles.isNotEmpty) {
      int imagesNumber = additionalImageFiles.length;
      for (int i = 0; i < imagesNumber; i++) {
        File imageFile = additionalImageFiles[i];
        double imageUploadProgress = 0.0;
        UploadTask? additionalImgUploadTask =
            incidentViewModel.createImageUploadTask(articleId, imageFile);
        additionalImgUploadTask?.snapshotEvents
            .listen((TaskSnapshot taskSnapshot) async {
          if (taskSnapshot.state == TaskState.running) {
            setState(() {
              imageUploadProgress =
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
              additionalImagesUploadProgress =
                  (additionalImagesUploadProgress ?? 0.0) +
                      imageUploadProgress / imagesNumber;
            });
          } else if (taskSnapshot.state == TaskState.success) {
            imageFile.delete();
          }
        });
        await additionalImgUploadTask
            ?.then((TaskSnapshot uploadTaskSnapshot) async {
          await uploadTaskSnapshot.ref.getDownloadURL().then(
            (String downloadURL) {
              additionalImagesDownloadUrls.add(downloadURL);
            },
          );
        });
      }
    }
    return additionalImagesDownloadUrls;
  }

  Future<String?> uploadVideo(String articleId, File videoFile) async {
    UploadTask? videoFileUploadTask =
        incidentViewModel.uploadVideoFileToStorage(articleId, videoFile);
    videoFileUploadTask?.snapshotEvents
        .listen((TaskSnapshot taskSnapshot) async {
      if (taskSnapshot.state == TaskState.running) {
        setState(() {
          if (taskSnapshot.bytesTransferred == taskSnapshot.totalBytes) {
            videoRecordingUploadProgress = 0.8;
          } else {
            videoRecordingUploadProgress =
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          }
        });
      } else if (taskSnapshot.state == TaskState.success) {
        videoFile.delete();
      }
    });
    String? videoDownloadUrl;
    await videoFileUploadTask?.then((TaskSnapshot uploadTaskSnapshot) async {
      await uploadTaskSnapshot.ref.getDownloadURL().then(
        (String downloadURL) {
          setState(() {
            videoDownloadUrl = downloadURL;
          });
        },
      );
    });
    return videoDownloadUrl;
  }

  InputDecoration _inputDeco({label}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(0),
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black87,
      ),
      hintText: "Enter location or tap icon to get map",
      border: const OutlineInputBorder(borderSide: BorderSide.none),
    );
  }

  InputDecoration _inputDecoOutline({label, hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: hint,
    );
  }

  pickMultiple() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        setState(() {
          additionalImageFiles.add(File(pickedFile.path));
        });
      }
    }
  }

  Widget imageTile({required File imageFile}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  topLeft: Radius.circular(12)),
              color: Colors.blue.shade50,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  additionalImageFiles.remove(imageFile);
                });
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
