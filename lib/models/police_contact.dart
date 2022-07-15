class PoliceContact {
  final String? location;
  final String id;
  final String? name;
  final String? phoneNumber;

  PoliceContact({required this.id, this.name, this.phoneNumber, this.location});

  factory PoliceContact.fromMap(Map<String, dynamic> map) {
    return PoliceContact(
      id: map["id"],
      name: map["Name"],
      phoneNumber: map['phone'],
      location: map["address"],
    );
  }
}
