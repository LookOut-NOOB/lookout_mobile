class Profile {
  final String? uid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  Profile({
    this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      uid: map["id"],
      firstName: map["firstName"],
      lastName: map["lastName"],
      email: map["email"],
      phone: map['phone'],
    );
  }
}
