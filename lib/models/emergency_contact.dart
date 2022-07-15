class EmergencyContact {
  final String id;
  final String? name;
  final String? phoneNumber;

  EmergencyContact({required this.id, this.name, this.phoneNumber});

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map["id"],
      name: map["Name"],
      phoneNumber: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phoneNumber,
    };
  }
}
