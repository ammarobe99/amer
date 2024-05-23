import 'package:flutter/material.dart';
import 'package:social_media_app/data/post_model.dart';
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
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                width: width,
                height: 240.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        final ScaffoldMessengerState scaffoldMessengerState =
                            ScaffoldMessenger.of(context);
                        final NavigatorState navigatorState =
                            Navigator.of(context);
                        try {
                          await launchUrl(
                              Uri.parse('tel:${postModel.phoneNumber}'));
                        } catch (e) {
                          navigatorState.pop();
                          scaffoldMessengerState.showSnackBar(
                            const SnackBar(
                              content: Text('Something went wrong, try again!'),
                            ),
                          );
                        }
                      },
                      child: const Text('Phone call'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final ScaffoldMessengerState scaffoldMessengerState =
                            ScaffoldMessenger.of(context);
                        final NavigatorState navigatorState =
                            Navigator.of(context);
                        try {
                          final WhatsAppUnilink link = WhatsAppUnilink(
                            phoneNumber: postModel.phoneNumber,
                          );
                          await launchUrl(link.asUri());
                        } catch (e) {
                          navigatorState.pop();
                          scaffoldMessengerState.showSnackBar(
                            const SnackBar(
                              content: Text('Something went wrong, try again!'),
                            ),
                          );
                        }
                      },
                      child: const Text('WhatsApp'),
                    ),
                  ],
                ),
              );
            },
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
          '${postModel.content}',
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${postModel.budget} JOD',
            ),
            Text(
              '${postModel.location}',
            ),
          ],
        ),
        leading: const Icon(Icons.phone),
      ),
    );
  }
}
