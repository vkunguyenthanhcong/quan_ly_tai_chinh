import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iouuvwuynbiukcqjzlwn.supabase.co',
    anonKey: 'sb_publishable_hY3bPs0ggrhEG3Xu0uPg7A_WLUBnwE4',
  );

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: isLoggedIn
          ? const MainScreen()
          : const LoginScreen(),
    );
  }
}
