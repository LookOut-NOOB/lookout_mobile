class Alert {
  String type; //alert, info, tip
  String message;
  DateTime? dateTime;

  Alert({
    required this.type,
    required this.message,
    this.dateTime,
  });
}
