class Profile {
  final String? uid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? encryptionKey;

  Profile(
      {this.uid,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.address,
      this.encryptionKey});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
        uid: map["id"],
        firstName: map["firstName"],
        lastName: map["lastName"],
        email: map["email"],
        address: map["address"],
        phone: map['phone'],
        encryptionKey: map['encryptionKey']);
  }
}
