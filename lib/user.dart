class User {
  User({
    required this.id,
    required this.name,
    //required this.email,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
        id: data['UID'], name: data['Username']); //, email: data['email']);
  }

  final String id;
  final String name;
  //final String email;
}
