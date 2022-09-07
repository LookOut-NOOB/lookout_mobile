import 'package:look_out/models/incident.dart';
import 'package:stacked/stacked.dart';
import 'package:video_compress/video_compress.dart';

import '../models/recorded_video.dart';
//This is a complementary repository service that is used to store data in the cloud
//It is used by the IncidentViewModel to store data in the cloud
// It complements the repository class implementing ReactiveServiceMixin.

class RepositoryService with ReactiveServiceMixin {
  RepositoryService() {
    listenToReactiveValues([
      _recordedVideo,
    ]);
  }

  final ReactiveValue<RecordedVideo?> _recordedVideo =
      ReactiveValue<RecordedVideo?>(null);

  RecordedVideo? get recordedVideo => _recordedVideo.value;

  void setRecordedVideo(RecordedVideo? video) {
    _recordedVideo.value = video;
  }

  RecordedVideo? getRecordedVideo() {
    return recordedVideo;
  }

  Future<MediaInfo?> compressRecordedVideo() {
    if (recordedVideo != null) {
      return recordedVideo!.justCompressVideo();
    }
    return Future.value(null);
  }

  Future<void> submitReportedIncident(Incident reportedIncident) async {
    // await FirebaseFirestore.instance
    //     .collection("reportedNews")
    //     .doc(reportedIncident.id)
    //     .set(reportedIncident.toMap());
  }
}
