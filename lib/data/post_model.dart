import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? title;
  String? content;
  String? location;
  String? budget;
  DateTime? dateTime;
  String? userId;
  String? phoneNumber;
  String? username;

  PostModel({
    this.id,
    this.title,
    this.content,
    this.location,
    this.budget,
    this.dateTime,
    this.userId,
    this.phoneNumber,
    this.username,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
    return PostModel(
      id: id,
      title: json['title'],
      content: json['content'],
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
      'title': title,
      'content': content,
      'location': location,
      'budget': budget,
      'dateTime': DateTime.timestamp(),
      'userId': userId,
      'phoneNumber': phoneNumber,
      'username': username,
    };
  }
}
