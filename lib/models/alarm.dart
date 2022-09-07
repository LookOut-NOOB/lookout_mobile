import 'package:cloud_firestore/cloud_firestore.dart';

class Alarm {
  String id;
  String status;
  String? userId;
  GeoPoint? location;
  DateTime dateTime;

  Alarm({
    required this.id,
    required this.status,
    required this.userId,
    required this.dateTime,
    this.location,
  });

  factory Alarm.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map['dateTime'];
    return Alarm(
        id: map["id"],
        status: map["status"],
        userId: map["userId"],
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            timestamp.millisecondsSinceEpoch),
        location: map["location"]);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'userId': userId,
      'dateTime': dateTime,
      'location': location,
    };
  }
}

///Status
///1=> on
///2=> off
///0=> cancelled