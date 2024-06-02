import 'package:flutter/material.dart';
import 'package:tamwelkom/data/infoUser.dart';
import 'package:tamwelkom/data/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/data/message_model.dart';
import 'package:tamwelkom/ui/pages/chat_page.dart';

import '../../data/post_model.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<infoUser> fetchUserInfo() async {
    // Assuming you have a 'users' collection where user data is stored
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('userInfo').doc().get();

      if (doc.exists) {
        // Create an instance of infoUser from the fetched data
        return infoUser.fromDocument(doc);
      }
    }
    // Return a default user info or handle accordingly if no user is found
    return infoUser(username: 'Guest', email: 'guest@example.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<infoUser>(
          future: fetchUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('User data not found'));
            } else {
              infoUser userInfo = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/student.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      userInfo.username ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ProfileDetail(
                    icon: Icons.person,
                    label: 'Name',
                    value: userInfo.username ?? '',
                  ),
                  ProfileDetail(
                    icon: Icons.email,
                    label: 'Age',
                    value: "18" ?? '',
                  ),
                  ProfileDetail(
                    icon: Icons.email,
                    label: 'Email',
                    value: userInfo.email ?? '',
                  ),
                  ProfileDetail(
                    icon: Icons.email,
                    label: 'Email',
                    value: userInfo.email ?? '',
                  ),
                  ProfileDetail(
                    icon: Icons.email,
                    label: 'Email',
                    value: userInfo.email ?? '',
                  ),
                  // Add other profile details as needed
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.teal,
            size: 30,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class infoUser {
  final String? username;
  final String? email;

  infoUser({this.username, this.email});

  factory infoUser.fromDocument(DocumentSnapshot doc) {
    return infoUser(
      username: doc['username'],
      email: doc['email'],
    );
  }
}
