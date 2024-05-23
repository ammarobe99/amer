import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tamwelkom/app/configs/colors.dart';
import 'package:tamwelkom/ui/pages/profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1-$user2";
    } else {
      return "$user2-$user1";
    }
  }

  Map<String, dynamic>? chatRoom(String id) {
    return {
      "id": id,
    };
  }

  void onSearch() async {
    if (_searchController.text.isEmpty) return;

    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });

    await fireStore
        .collection('users')
        .where("email", isEqualTo: '${_searchController.text}@gmail.com')
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: isLoading
          ? const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 70,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Find a New Friend!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 230, 230, 230),
                          border: Border.all(color: AppColors.whiteColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 50,
                        width: 270,
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                height: 30,
                                child: Image.asset(
                                    'assets/images/ic_search.png',
                                    color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                    hintText: "Search for a user...",
                                    border: InputBorder
                                        .none //OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: onSearch,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                userMap != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text('Users found',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: ListTile(
                              horizontalTitleGap: 0,
                              dense: true,
                              tileColor: Colors.grey[200],
                              shape: ShapeBorder.lerp(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  0.5),
                              contentPadding: EdgeInsetsGeometry.lerp(
                                  const EdgeInsets.all(8),
                                  const EdgeInsets.all(10),
                                  0.2),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ProfilePage(
                                        email:
                                            '${_searchController.text}@gmail.com',
                                        id: userMap!['id'])));
                                /*String roomId = chatRoomId(
                                    _auth.currentUser!.email!,
                                    userMap?['email']);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                          chatRoom: chatRoom(roomId),
                                          userMap: userMap,
                                        )));*/
                              },
                              leading: const Icon(
                                Icons.person,
                                color: AppColors.primaryColor2,
                              ),
                              title: Text(
                                userMap?['email'],
                                style: const TextStyle(
                                  color: AppColors.primaryColor2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: const Icon(Icons.chat,
                                  color: AppColors.primaryColor2),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
    );
  }
}
