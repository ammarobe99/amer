class InfoUser {
  String? id;
  String? role;
  String? age;
  String? location;
  String? userId;
  String? phoneNumber;
  String? username;

  InfoUser({
    this.id,
    this.role,
    this.age,
    this.location,
    this.userId,
    this.phoneNumber,
    this.username,
  });

  factory InfoUser.fromJson(Map<String, dynamic> json, String id) {
    return InfoUser(
      id: id,
      role: json['role'],
      age: json['age'],
      location: json['location'],
      userId: json['userId'],
      phoneNumber: json['phoneNumber'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'age': age,
      'location': location,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'username': username,
    };
  }
}
