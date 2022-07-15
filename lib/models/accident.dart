import 'package:cloud_firestore/cloud_firestore.dart';

class Accident {
  final String type = "accident";
  String id;
  String location;
  String? statement;
  String? userId;
  DateTime dateTime;

  Accident(
      {required this.id,
      required this.location,
      required this.dateTime,
      this.statement,
      this.userId});

  factory Accident.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map['dateTime'];
    return Accident(
      id: map['id'],
      userId: map['action'],
      statement: map['statement'],
      location: map['location'],
      dateTime:
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'statement': statement,
      'location': location,
      'userId': userId,
      'dateTime': dateTime,
    };
  }
}
