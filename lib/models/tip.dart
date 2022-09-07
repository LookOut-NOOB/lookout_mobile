class Tip {
  String id;
  String tipText;
  Tip({required this.id, required this.tipText});

  factory Tip.fromMap(Map<String, dynamic> map) {
    return Tip(
      id: map["id"],
      tipText: map["tipText"],
    );
  }
}
