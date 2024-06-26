import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/ui/bloc/gallery_profile_cubit.dart';
import 'package:social_media_app/ui/bloc/post_cubit.dart';
import 'package:social_media_app/ui/pages/chat_page.dart';
import 'package:social_media_app/ui/pages/login_page.dart';
import 'package:social_media_app/ui/widgets/card_post.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, required this.email, required this.id})
      : super(key: key);

  final String email;
  final String id;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final followersRef = FirebaseFirestore.instance.collection('followers');
  final followingRef = FirebaseFirestore.instance.collection('following');

  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    getFollowers();
    getFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.id)
        .collection('userFollowers')
        .doc(_firebaseAuth.currentUser!.uid)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot =
        await followersRef.doc(widget.id).collection('userFollowers').get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }
  // getFollowers() async {
  //   QuerySnapshot snapshot =
  //       await followersRef.doc(widget.id).collection('post').get();
  //   setState(() {
  //     followerCount = snapshot.docs.length;
  //   });
  // }

  getFollowing() async {
    QuerySnapshot snapshot =
        await followingRef.doc(widget.id).collection('userFollowing').get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1-$user2";
    } else {
      return "$user2-$user1";
    }
  }

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
          widget.email.split('@')[0],
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
                    widget.email,
                    style: AppTheme.blackTextStyle.copyWith(
                      fontWeight: AppTheme.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildButtonAction(context),
                  const SizedBox(height: 35),
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  BlocProvider(
                    create: (context) => PostCubit()..getMyPosts(widget.id),
                    child: BlocBuilder<PostCubit, PostState>(
                      builder: (context, state) {
                        if (state is PostError) {
                          return Center(child: Text(state.message));
                        } else if (state is PostLoaded) {
                          return Column(
                            children: [
                              Column(
                                children: state.posts
                                    .map((post) => GestureDetector(
                                          child: CardPost(post: post),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 200)
                            ],
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
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

  Map<String, dynamic>? chatRoom(String id) {
    return {
      "id": id,
    };
  }

  Map<String, dynamic>? userMap(String mail) {
    return {
      "email": mail,
    };
  }

  Row _buildButtonAction(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildProfileButton(),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            String roomId =
                chatRoomId(_firebaseAuth.currentUser!.email!, widget.email);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatPage(
                      chatRoom: chatRoom(roomId),
                      userMap: userMap(widget.email),
                    )));
          },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.greyColor.withOpacity(0.17),
              image: const DecorationImage(
                scale: 2.3,
                image: AssetImage("assets/images/ic_inbox.png"),
              ),
            ),
          ),
        )
      ],
    );
  }

  buildProfileButton() {
    if (isFollowing) {
      return buildButton('Unfollow', handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton('Follow', handleFollowUser);
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .doc(widget.id)
        .collection('userFollowers')
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('userFollowing')
        .doc(widget.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });

    followersRef
        .doc(widget.id)
        .collection('userFollowers')
        .doc(_firebaseAuth.currentUser!.uid)
        .set({});

    followingRef
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('userFollowing')
        .doc(widget.id)
        .set({});
  }

  ElevatedButton buildButton(String text, Function() onPressed) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFollowing ? AppColors.primaryColor : AppColors.primaryColor2,
        minimumSize: const Size(120, 45),
        elevation: 8,
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text,
          style:
              AppTheme.whiteTextStyle.copyWith(fontWeight: AppTheme.semiBold)),
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
            asset()!,
            width: 120,
            fit: BoxFit.cover,
          )),
    );
  }

  String? asset() {
    if (widget.email == 'berk@gmail.com') {
      return 'assets/images/berk.png';
    } else {
      return 'assets/images/ali.jpeg';
    }
  }

  Row _buildDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              followingCount.toString(),
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Following",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              followerCount.toString(),
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Followers",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ],
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
