import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/screens/add_transaction_screen.dart';
import 'package:quan_ly_chi_tieu/screens/scan_bill_page.dart';
import 'package:quan_ly_chi_tieu/services/transaction_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'package:home_widget/home_widget.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iouuvwuynbiukcqjzlwn.supabase.co',
    anonKey: 'sb_publishable_hY3bPs0ggrhEG3Xu0uPg7A_WLUBnwE4',
  );

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  final WidgetService = TransactionService();
  // 🔥 AUTO UPDATE WIDGET KHI APP START
  if (isLoggedIn) {
    //await WidgetService.updateTodayExpenseWidget();
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // 🔥 NHẬN ROUTE KHI CLICK TỪ WIDGET
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri == null) return;

      if (uri.path == '/add-transaction') {
        navigatorKey.currentState
            ?.pushNamed('/add-transaction');
      }

      if (uri.path == '/scan') {
        navigatorKey.currentState?.pushNamed('/scan');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,  
      theme: ThemeData.dark(useMaterial3: true),
      home: widget.isLoggedIn
          ? const MainScreen()
          : const LoginScreen(),
      routes: {
        '/add-transaction': (_) => const AddTransactionScreen(),
        '/scan': (_) => const ScanBillPage(),
      },
    );
  }
}
