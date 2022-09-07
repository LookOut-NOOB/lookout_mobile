import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/models/incident.dart';
import 'package:look_out/services/service_locator.dart';
import 'package:stacked/stacked.dart';
import 'package:video_compress/video_compress.dart';

import '../../main.dart';
import '../../models/recorded_video.dart';
import '../../views/app_viewmodel.dart';
import '../repository_service.dart';

class IncidentViewModel extends ReactiveViewModel {
  final _repositoryService = getIt<RepositoryService>();
  @override
  List<ReactiveServiceMixin> get reactiveServices => [_repositoryService];

  RepositoryService get repositoryService => _repositoryService;

  void clearModel() {
    setRecordedVideo(null);
  }

  Future<bool> submitReportedIncident(Incident reportedIncident) async {
    // await _repositoryService.submitReportedIncident(reportedIncident);
    final appViewModel = GetIt.instance<AppViewModel>();
    return await appViewModel.repository.reportIncident(reportedIncident);
  }

  UploadTask? createImageUploadTask(String incidentId, File file) {
    try {
      String fileName = file.uri.pathSegments.last;
      final ref = FirebaseStorage.instance
          .ref('incidents/$incidentId')
          .child('img/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      return uploadTask;
    } catch (e) {
      printDebug('Failed to upload file!');
      return null;
    }
  }

  Future<String?> uploadImageFileToStorage(String articleId, File file) async {
    try {
      String fileName = file.uri.pathSegments.last;
      final ref = FirebaseStorage.instance
          .ref('incidents/$articleId')
          .child('img/$fileName');
      TaskSnapshot taskSnapshot = await ref.putFile(file);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      printDebug('Failed to upload file!');
      return null;
    }
  }

  Future<String?> uploadVideoThumbnailFileToStorage(
    String articleId,
    File file,
  ) async {
    try {
      String fileName = file.uri.pathSegments.last;
      String fileExtension = fileName.split('.').last;
      String newFileName = "thumbnail_$articleId.$fileExtension";
      final ref = FirebaseStorage.instance
          .ref('incidents/$articleId')
          .child('vid_rec/$newFileName');
      TaskSnapshot taskSnapshot = await ref.putFile(file);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      printDebug('Failed to upload file!');
      return null;
    }
  }

  UploadTask? uploadVideoFileToStorage(String articleId, File file) {
    try {
      String fileName = file.uri.pathSegments.last;
      String fileExtension = fileName.split('.').last;
      String newFileName = "LookOut_video_$articleId.$fileExtension";
      final ref = FirebaseStorage.instance
          .ref('incidents/$articleId')
          .child('vid_rec/$newFileName');
      UploadTask uploadTask = ref.putFile(file);
      return uploadTask;
    } catch (e) {
      printDebug('Failed to upload file!');
      return null;
    }
  }

  void setRecordedVideo(RecordedVideo? video) {
    _repositoryService.setRecordedVideo(video);
    notifyListeners();
  }

  RecordedVideo? getRecordedVideo() {
    return _repositoryService.getRecordedVideo();
  }

  Future<MediaInfo?> compressRecordedVideo() {
    return _repositoryService.compressRecordedVideo();
  }
}
