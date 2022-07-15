import 'package:cloud_firestore/cloud_firestore.dart';

class AmbulanceRequest {
  final String type = "ambulance";
  String id;
  String location;
  String status;
  String? userId;
  DateTime? dateTime;
  String comment;
  String? ambulanceName;
  String? ambulancePhoneNo;

  AmbulanceRequest({
    required this.id,
    required this.location,
    required this.status,
    required this.comment,
    required this.userId,
    required this.dateTime,
    this.ambulanceName,
    this.ambulancePhoneNo,
  });

  factory AmbulanceRequest.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map['dateTime'];
    return AmbulanceRequest(
      id: map['id'],
      status: map['status'],
      userId: map['action'],
      comment: map['comment'],
      location: map['location'],
      ambulanceName: map['ambulanceName'],
      ambulancePhoneNo: map['ambulancePhoneNo'],
      dateTime:
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'comment': comment,
      'location': location,
      'userId': userId,
      'dateTime': dateTime,
    };
  }
}
