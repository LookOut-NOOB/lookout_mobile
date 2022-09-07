class AppLocation {
  String id;
  String name;
  AppLocation({required this.id, required this.name});

  factory AppLocation.fromMap(Map<String, dynamic> map) {
    return AppLocation(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
    );
  }
}
