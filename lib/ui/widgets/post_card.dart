import 'package:flutter/material.dart';
import 'package:tamwelkom/data/post_model.dart';
import 'package:tamwelkom/ui/pages/DetailScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.postModel});
  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailScreen(postModel: postModel)),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          '${postModel.title}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${postModel.content}",
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${postModel.budget} JOD',
            ),
            Text(
              "${postModel.location}",
            ),
          ],
        ),
        leading: const Icon(Icons.phone),
      ),
    );
  }
}
