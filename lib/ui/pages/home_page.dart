import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/ui/widgets/clip_status_bar.dart';
import 'package:social_media_app/ui/widgets/post_card.dart';

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
            // SingleChildScrollView(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            //     child: Column(
            //       children: [
            //         const SizedBox(height: 12),
            //         _buildCustomAppBar(context),
            //         const SizedBox(height: 18),
            //         BlocProvider(
            //           create: (context) =>
            //               PostCubit()..getPosts(_firebaseAuth.currentUser!.uid),
            //           child: BlocBuilder<PostCubit, PostState>(
            //             builder: (context, state) {
            //               if (state is PostError) {
            //                 return Center(child: Text(state.message));
            //               } else if (state is PostLoaded) {
            //                 return Column(
            //                   children: [
            //                     if (state.posts.isNotEmpty)
            //                       Column(
            //                         children: state.posts
            //                             .map((post) => GestureDetector(
            //                                   child: CardPost(post: post),
            //                                 ))
            //                             .toList(),
            //                       ),
            //                     if (state.posts.isEmpty)
            //                       const SizedBox(
            //                         height: 1000,
            //                         child: Padding(
            //                           padding: EdgeInsets.only(top: 200),
            //                           child: Text("No Project",
            //                               style: TextStyle(
            //                                 fontSize: 28,
            //                               )),
            //                         ),
            //                       ),
            //                     const SizedBox(height: 1000)
            //                   ],
            //
            //                   /*children: state.posts
            //                       .map((post) => GestureDetector(
            //                             child: CardPost(post: post),
            //                           ))
            //                       .toList(),*/
            //                 );
            //               } else {
            //                 return const Column(children: [
            //                   CircularProgressIndicator(),
            //                   SizedBox(height: 1000)
            //                 ]);
            //               }
            //             },
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            _buildBackgroundGradient(),
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
                  color: AppColors.blackColor.withOpacity(0.2),
                  blurRadius: 35,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/business-and-finance.png',
              width: 30,
              height: 30,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: AppColors.backgroundColor,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.whiteColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          _firebaseAuth.currentUser!.email == 'berk@gmail.com'
                              ? 'assets/images/berk.png'
                              : 'assets/images/ali.jpeg',
                        )),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _firebaseAuth.currentUser!.email!.split('@')[0],
                  style: AppTheme.blackTextStyle
                      .copyWith(fontWeight: AppTheme.bold, fontSize: 12),
                ),
                const SizedBox(width: 6),
              ],
            ),
          )
        ],
      ),
    );
  }
}
