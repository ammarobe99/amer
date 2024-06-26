import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_app/ui/pages/profile_page.dart';
import 'waveform.dart';
import 'clip_status_bar.dart';
import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/data/post_model.dart';
import 'package:social_media_app/ui/widgets/custom_bottom_sheet_comments.dart';
import 'package:uuid/uuid.dart';

class CardPost extends StatefulWidget {
  final PostModel post;
  String outputpath = '';

  CardPost({required this.post, Key? key}) : super(key: key);

  @override
  State<CardPost> createState() => _CardPostState();
}

class _CardPostState extends State<CardPost> {
  late Future<void> audioFuture;

  @override
  void initState() {
    super.initState();
    // audioFuture = base64ToAudio(widget.post.audio);
  }

  Future<void> base64ToAudio(String base64Data) async {
    List<int> bytes = base64Decode(base64Data);

    final appDir = await getApplicationDocumentsDirectory();
    Uuid uuid = Uuid();
    String uniqueId = uuid.v1();
    String tempPath = '${appDir.path}/$uniqueId.wav';
    await File(tempPath).writeAsBytes(bytes);
    setState(() {
      widget.outputpath = tempPath;
    });
  }

  Widget _buildImageCover() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor2,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  Widget _buildImageGradient() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
      ),
    );
  }

  // Container _buildItemPublisher(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.only(left: 18, right: 40, bottom: 80),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         GestureDetector(
  //           onTap: () {
  //             Navigator.of(context).push(MaterialPageRoute(
  //               builder: (_) => ProfilePage(
  //                 email: '${widget.post.sender}@gmail.com',
  //                 id: widget.post.senderId,
  //               ),
  //             ));
  //           },
  //           child: Row(
  //             children: [
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(50),
  //                 child: Image.asset(
  //                   widget.post.imgProfile,
  //                   width: 55,
  //                   height: 55,
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               const SizedBox(width: 10),
  //               Text(
  //                 widget.post.sender,
  //                 style: AppTheme.whiteTextStyle.copyWith(
  //                   fontSize: 25,
  //                   fontWeight: AppTheme.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           "Financing type: Home financing",
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //           style: AppTheme.whiteTextStyle.copyWith(
  //             fontSize: 18,
  //             fontWeight: AppTheme.regular,
  //           ),
  //         ),
  //         const SizedBox(height: 2),
  //         Text(
  //           "Loction : Irbid",
  //           style: AppTheme.whiteTextStyle.copyWith(
  //             color: AppColors.whiteColor,
  //             fontSize: 12,
  //             fontWeight: AppTheme.medium,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  List<Widget> _itemStatus(String icon, String text, BuildContext context) => [
        GestureDetector(
          onTap: icon == "assets/images/ic_message.png"
              ? () => customBottomSheetComments(context)
              : () {},
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                scale: 2.3,
                image: AssetImage(icon),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTheme.whiteTextStyle.copyWith(
            fontSize: 12,
            fontWeight: AppTheme.regular,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold();
    // return FutureBuilder<void>(
    //   future: audioFuture,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return CircularProgressIndicator();
    //     } else if (snapshot.hasError) {
    //       return Text('Error: ${snapshot.error}');
    //     } else {
    //       debugPrint('Output Path: ${widget.outputpath}');
    //       return Container(
    //         width: double.infinity,
    //         height: 250,
    //         margin: const EdgeInsets.only(bottom: 24),
    //         child: Stack(
    //           children: [
    //             _buildImageCover(),
    //             _buildImageGradient(),
    //             Positioned(
    //               height: 375,
    //               width: 85,
    //               right: 0,
    //               top: 25,
    //               child: Transform.rotate(
    //                 angle: 3.14,
    //                 child: ClipPath(
    //                   clipper: ClipStatusBar(),
    //                   child: BackdropFilter(
    //                     filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    //                     child: ColoredBox(
    //                       color: AppColors.whiteColor.withOpacity(0.3),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             Positioned(
    //               top: 75,
    //               right: 20,
    //               child: Column(
    //                 children: [
    //                   const SizedBox(
    //                     height: 20,
    //                   ),
    //                   ..._itemStatus("assets/images/like_button.png",
    //                       widget.post.like, context),
    //                   const SizedBox(height: 10),
    //                   ..._itemStatus("assets/images/ic_message.png",
    //                       widget.post.comment, context)
    //                 ],
    //               ),
    //             ),
    //             _buildItemPublisher(context),
    //             // Row(
    //             //   children: [
    //             //     Align(
    //             //       alignment: Alignment.bottomLeft,
    //             //       child: Row(
    //             //         children: [
    //             //           SizedBox(width: 15),
    //             //           WaveformScreen(assetPath: widget.outputpath),
    //             //         ],
    //             //       ),
    //             //     ),
    //             //   ],
    //             // ),
    //           ],
    //         ),
    //       );
    //     }
    //   },
    // );
  }
}
