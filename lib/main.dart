import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_plus/loading_plus.dart';
import 'package:tamwelkom/app/configs/theme.dart';
import 'package:tamwelkom/app/resources/constant/named_routes.dart';
import 'package:tamwelkom/ui/pages/home_page.dart';
import 'package:tamwelkom/ui/pages/inbox_page.dart';
import 'package:tamwelkom/ui/pages/login_page.dart';
import 'package:tamwelkom/ui/pages/add_post_page.dart';
import 'package:tamwelkom/ui/pages/navigation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case NamedRoutes.homeScreen:
            return MaterialPageRoute(builder: (context) => const HomePage());
          case NamedRoutes.addPostScreen:
            return MaterialPageRoute(builder: (context) => const AddPostPage());
          case NamedRoutes.navigationScreen:
            return MaterialPageRoute(
                builder: (context) => const NavigationPage(index: 0));
          case NamedRoutes.inboxPage:
            return MaterialPageRoute(builder: (context) => const InboxPage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
      builder: (BuildContext context, Widget? child) {
        return LoadingPlus(
          child: child!,
        );
      },
    );
  } //Deneme
}
