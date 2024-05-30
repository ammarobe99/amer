import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final int age;
  final String gender;
  final String email;

  UserModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
  });
}

class ProfileScreen extends StatelessWidget {
  //  UserModel userModel;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/student.png'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "userModel.name",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            SizedBox(height: 40),
            ProfileDetail(
              icon: Icons.person,
              label: 'Name',
              value: "userModel.name",
            ),
            ProfileDetail(
              icon: Icons.cake,
              label: 'Age',
              value: '{userModel.age} years',
            ),
            ProfileDetail(
              icon: Icons.person_outline,
              label: 'Gender',
              value: "userModel.gender",
            ),
            ProfileDetail(
              icon: Icons.email,
              label: 'Email',
              value: "userModel.email",
            ),
          ],
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
