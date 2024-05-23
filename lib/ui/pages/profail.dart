import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/app/configs/theme.dart';

import '../../data/post_model.dart';
import '../widgets/post_card.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24,
            color: AppColors.blackColor,
          ),
        ),
        title: Text(
          FirebaseAuth.instance.currentUser!.email!.split('@')[0],
          style: AppTheme.blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: AppTheme.bold,
          ),
        ),
        actions: const [
          Icon(
            Icons.more_horiz_rounded,
            size: 24,
            color: AppColors.blackColor,
          ),
          SizedBox(width: 24),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 24, left: 24, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageProfile(),
                  const SizedBox(height: 16),
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    style: AppTheme.blackTextStyle.copyWith(
                      fontWeight: AppTheme.bold,
                      fontSize: 22,
                    ),
                  ),
                  //const SizedBox(height: 24),
                  //_buildDescription(),
                  const SizedBox(height: 35),
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('dateTime', descending: true)
                        .where('userId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
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
                  // BlocProvider(
                  //   create: (context) =>
                  //       PostCubit()..getMyPosts(_firebaseAuth.currentUser!.uid),
                  //   child: BlocBuilder<PostCubit, PostState>(
                  //     builder: (context, state) {
                  //       if (state is PostError) {
                  //         return Center(child: Text(state.message));
                  //       } else if (state is PostLoaded) {
                  //         return Column(
                  //           children: [
                  //             Column(
                  //               children: state.posts
                  //                   .map((post) => GestureDetector(
                  //                         child: CardPost(post: post),
                  //                       ))
                  //                   .toList(),
                  //             ),
                  //             const SizedBox(height: 200)
                  //           ],
                  //         );
                  //       } else {
                  //         return const Center(
                  //             child: CircularProgressIndicator());
                  //       }
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          _buildBackgroundGradient()
        ],
      ),
    );
  }

  Row _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Uploaded Project",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Container _buildImageProfile() {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.dashedLineColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.asset(
          _firebaseAuth.currentUser!.email! == 'berk@gmail.com'
              ? 'assets/images/berk.png'
              : 'assets/images/ali.jpeg',
          width: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _buildBackgroundGradient() => Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.whiteColor.withOpacity(0),
            AppColors.whiteColor.withOpacity(0.8),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
      );
}
