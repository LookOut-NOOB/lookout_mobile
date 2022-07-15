import 'package:cloud_firestore/cloud_firestore.dart';

class AppLog{
  final String? id;
  final String? action;
  final DateTime? time;
  final String? name;

  AppLog({this.id, this.action, this.time, this.name});

  factory AppLog.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map['time'];
    return AppLog(
      id: map['id'],
      action: map['action'] ?? "",
      time:
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
      name: map["name"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "action": action,
      "name": name,
      "date": time,
    };
  }
}