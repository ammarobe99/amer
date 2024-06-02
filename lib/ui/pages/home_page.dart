import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/data/infoUser.dart';
import 'package:tamwelkom/ui/pages/login_page.dart';
import 'package:tamwelkom/ui/pages/profail.dart';
import 'package:tamwelkom/ui/widgets/clip_status_bar.dart';
import 'package:tamwelkom/ui/widgets/post_card.dart';

import '../../app/resources/constant/named_routes.dart';
import '../../data/post_model.dart';
import '../widgets/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                _buildCustomAppBar(context),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('dateTime', descending: true)
                        .where('userId',
                            isNotEqualTo:
                                FirebaseAuth.instance.currentUser!.uid)
                        // .where(
                        //   'dateTime',
                        //   isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
                        // )
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text(
                            "No Project",
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          ),
                        );
                      }
                      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          dataList = snapshot.data!.docs;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.separated(
                          itemCount: dataList.length,
                          itemBuilder: (BuildContext context, int index) {
                            QueryDocumentSnapshot<Map<String, dynamic>> item =
                                dataList.elementAt(index);
                            final PostModel postModel =
                                PostModel.fromJson(item.data(), item.id);
                            return PostCard(postModel: postModel);
                          },
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 16.0);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 91,
              child: Transform.rotate(
                angle: 11,
                child: ClipPath(
                  clipper: ClipStatusBar(),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(NamedRoutes.addPostScreen);
                    },
                    child: Container(
                      height: 110,
                      width: 40,
                      color: AppColors.primaryColor2, //New Post
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomAppBar _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 35,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                // Add your logout logic here
                // For example, navigate to the login screen and clear user session
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ); // You can also add logic to clear user session
              },
              child: const Icon(
                Icons.logout,
                size: 30,
                color: Colors.black, // Set the color you prefer
              ),
            ),
          ),
          // SizedBox(
          //   width: 120,
          // ),
          // Container(
          //   width: 80,
          //   height: 50,
          //   decoration: BoxDecoration(
          //     boxShadow: [
          //       BoxShadow(
          //         color:
          //             const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
          //         blurRadius: 35,
          //         offset: const Offset(0, 10),
          //       ),
          //     ],
          //   ),
          //   child: const Center(
          //     child: Text(
          //       'Home Page',
          //       style: TextStyle(
          //         color: Colors.black,
          //         fontSize: 12,
          //       ),
          //     ),
          //   ),
          // ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: Colors.grey,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/images/ali.jpeg',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _firebaseAuth.currentUser!.email!.split('@')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // استخدم الوزن المناسب هنا
                      fontSize: 12,
                      color: Colors.black, // استخدم اللون المناسب هنا
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
