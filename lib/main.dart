import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lechat/screens/cadastre_screen.dart';
import 'package:lechat/screens/home_screen.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/service/firebaseapi.dart';
import 'package:lechat/utils/theme_data.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:lechat/screens/chat_screen.dart';
import 'package:lechat/screens/login_screen.dart';
import 'package:lechat/screens/registration_screen.dart';
import 'package:lechat/screens/welcome_screen.dart';


final navigatorKey = GlobalKey<NavigatorState>();

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(const ProviderScope(child: LeChat()));
}

class LeChat extends ConsumerStatefulWidget {
  const LeChat({super.key});

  @override
  ConsumerState<LeChat> createState() => _LeChatState();
}

class _LeChatState extends ConsumerState<LeChat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Chat', 
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      darkTheme: AppTheme.darktheme,
      navigatorKey: navigatorKey,
      initialRoute: ref.read(authentication).getCurrentUser() == null ? LoginScreen.id : HomeScreen.id,
      routes: {
        WelcomeScreen.id :(context) => const WelcomeScreen(),
        LoginScreen.id :(context) => const LoginScreen(), 
        RegistrationScreen.id :(context) => const RegistrationScreen(),
        CadastreScreen.id :(context) => CadastreScreen(),
        HomeScreen.id :(context) => const HomeScreen(),
        ChatScreen.id :(context) => ChatScreen(),  
      },
    );
  }
}