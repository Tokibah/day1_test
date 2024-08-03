import 'package:d1_wsf24_driver/Welcome/launchpage.dart';
import 'package:d1_wsf24_driver/firebase_options.dart';
import 'package:d1_wsf24_driver/pushnavi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _existToken = false;
  bool notLoading = false;
  String? user;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    user = prefs.getString('token');
    if (user == null) {
      return;
    } else {
      setState(() {
        _existToken = true;
        notLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Provider.of<ThemeProvider>(context).themeData,
          home: child),
      child: notLoading
          ? (_existToken ? PushNavigation(user: user) : const LaunchPage())
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  final ThemeData _themeData = _lightMode;
  ThemeData get themeData => _themeData;

  static const Color highlightColor = Color(0xFF4CC486);
  static const Color trustColor = Color(0xFF87CEEB);
  static const Color popColor = Color(0xFFFFD700);
  static const Color lightColor = Color(0xFFF5F5F5);
  static const Color honeydew = Color(0xFFE0F5EB);

  static final _lightMode = ThemeData(
      useMaterial3: true,
      iconTheme: const IconThemeData(color: highlightColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: highlightColor)),
      textTheme: GoogleFonts.montserratTextTheme(const TextTheme(
          bodyMedium: TextStyle(
        color: Colors.black,
      ))),
      scaffoldBackgroundColor: lightColor,
      colorScheme: const ColorScheme.light(
        outline: Colors.black,
        primary: highlightColor,
        surface: lightColor,
        secondary: highlightColor,
        tertiary: trustColor,
      ));
}

class StateRefresh extends ChangeNotifier {
  bool state = true;

  void togglerefresh() {
    state = !state;
    state = !state;
  }
}
