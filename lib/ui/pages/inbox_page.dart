import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/data/message_model.dart';
import 'package:tamwelkom/ui/pages/chat_page.dart';

import '../../data/post_model.dart';
import '../widgets/post_card.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 70,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'My Project',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('dateTime', descending: true)
                  // .where('userId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  // .where(
                  //   'dateTime',
                  //   isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
                  // )
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                final List<PostModel> postsList = [];
                for (var item in dataList) {
                  final PostModel postModel =
                      PostModel.fromJson(item.data(), item.id);
                  postsList.add(postModel);
                }

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('financing')
                      .where(
                        'financierId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> s) {
                    if (s.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!s.hasData) {
                      return const Center(
                        child: Text(
                          "No Project",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                      );
                    }

                    List<PostModel> myPostsList = [];
                    s.data?.docs.forEach((e) {
                      myPostsList.addAll(postsList.where((post) {
                        return post.id == e.data()['postId'];
                      }).toList());
                    });

                    myPostsList = myPostsList.toSet().toList();
                    if (myPostsList.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Project",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.separated(
                        itemCount: myPostsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PostModel postModel =
                              myPostsList.elementAt(index);
                          return PostCard(postModel: postModel);
                        },
                        separatorBuilder: (_, __) {
                          return const SizedBox(height: 16.0);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
