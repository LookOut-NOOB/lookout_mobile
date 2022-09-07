import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String type = "incident";
  String id;
  String name;
  GeoPoint location;
  String? statement;
  String? userId;
  DateTime? dateTime;
  String? videoUrl;
  String? videoThumbnailUrl;
  List<String> imagesDownloadUrls;

  Incident(
      {required this.id,
      required this.name,
      required this.location,
      required this.dateTime,
      this.videoUrl,
      this.videoThumbnailUrl,
      required this.imagesDownloadUrls,
      this.statement,
      this.userId});

  factory Incident.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map['dateTime'];
    return Incident(
      id: map['id'],
      name: map['name'],
      userId: map['action'],
      statement: map['statement'],
      location: map['location'],
      videoUrl: map['videoUrl'],
      videoThumbnailUrl: map['videoThumbnailUrl'],
      imagesDownloadUrls: List<String>.from(map['imagesDownloadUrls']),
      dateTime:
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'statement': statement,
      'location': location,
      'userId': userId,
      'dateTime': dateTime,
      'videoUrl': videoUrl,
      'videoThumbnailUrl': videoThumbnailUrl,
      'imagesDownloadUrls': imagesDownloadUrls,
    };
  }
}
