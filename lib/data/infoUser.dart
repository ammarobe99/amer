import 'package:cloud_firestore/cloud_firestore.dart';

class infoUser {
  String? role;
  String? age;
  String? location;
  String? budget;
  DateTime? dateTime;
  String? userId;
  String? phoneNumber;
  String? username;

  infoUser({
    this.role,
    this.age,
    this.location,
    this.budget,
    this.dateTime,
    this.userId,
    this.phoneNumber,
    this.username,
  });

  factory infoUser.fromJson(Map<String, dynamic> json, String id) {
    return infoUser(
      role: id,
      age: json['age'],
      location: json['location'],
      budget: json['budget'],
      dateTime: (json['dateTime'] as Timestamp).toDate(),
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
      'budget': budget,
      'dateTime': DateTime.timestamp(),
      'userId': userId,
      'phoneNumber': phoneNumber,
      'username': username,
    };
  }
}
