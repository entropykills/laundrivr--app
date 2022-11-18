import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundrivr/src/features/home/home_screen.dart';
import 'package:laundrivr/src/features/sign_in/sign_in_screen.dart';
import 'package:laundrivr/src/features/splash/splash_screen.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );

  runApp(const LaundrivrApp());
}

class LaundrivrApp extends StatelessWidget {
  const LaundrivrApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundrivr',
      theme: ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[
          LaundrivrTheme(
            opaqueBackgroundColor: const Color(0xff0F162A),
            secondaryOpaqueBackgroundColor: const Color(0xff182243),
            primaryBrightTextColor: const Color(0xffffffff),
            primaryTextStyle: GoogleFonts.urbanist(),
          )
        ],
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashScreen(), // rename to splash screen
        '/signin': (_) => const SignInScreen(),
        '/home': (_) => const HomeScreen(), // actually make a home page
      },
    );
  }
}
