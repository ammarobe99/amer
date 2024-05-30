import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/data/message_model.dart';
import 'package:tamwelkom/data/post_model.dart';
import 'package:tamwelkom/ui/pages/chat_page.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required PostModel postModel});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? userMap;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  String latestMessage = '';

  @override
  void initState() {
    super.initState();
  }

//edit here
  void findLastMessage(String roomId) async {
    String lastMessage = '';
    await fireStore
        .collection('chatroom')
        .doc(roomId)
        .collection('chats')
        .orderBy('time', descending: true)
        .limit(1)
        .get()
        .then((value) {
      lastMessage = value.docs[0].data()['message'];
    });
    setState(() {
      latestMessage = lastMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 70,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Project Details',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          // Expanded(
          //   child: SizedBox(
          //     height: MediaQuery.of(context).size.height * 0.8,
          //     child: StreamBuilder<QuerySnapshot>(
          //       stream: fireStore.collection('chatroom').snapshots(),
          //       builder: (BuildContext context,
          //           AsyncSnapshot<QuerySnapshot> snapshot) {
          //         if (snapshot.data != null) {
          //           // final allData = snapshot.data!.docs.toList();
          //           return ListView.builder(
          //               reverse: false,
          //               itemCount: snapshot.data!.docs.length,
          //               itemBuilder: (context, index) {
          //                 Map<String, dynamic> map = snapshot.data!.docs[index]
          //                     .data() as Map<String, dynamic>;
          //                 findLastMessage(map['id']);
          //                 return InboxChat(
          //                     message: Message(
          //                         image: _auth.currentUser!.email! ==
          //                                 map['id'].split('-')[0]
          //                             ? 'assets/images/ali.jpeg'
          //                             : 'assets/images/berk.png',
          //                         sender: _auth.currentUser!.email! ==
          //                                 map['id'].split('-')[0]
          //                             ? map['id'].split('-')[1].split('@')[0]
          //                             : map['id'].split('-')[0].split('@')[0],
          //                         text: latestMessage,
          //                         time: '12:00'),
          //                     roomID: map['id'],
          //                     mail: _auth.currentUser!.email! ==
          //                             map['id'].split('-')[0]
          //                         ? map['id'].split('-')[1].split('@')[0]
          //                         : map['id'].split('-')[0].split('@')[0]);
          //               });
          //         } else {
          //           return Container();
          //         }
          //       },
          //     ), /*ListView.builder(
          //       itemCount: messages.length,
          //       itemBuilder: (BuildContext context, int index) {
          //         final Message message = messages[index];
          //         return InboxChat(message: message);
          //       },
          //     ),*/
          //   ),
          // ),
        ],
      ),
    );
  }
}
