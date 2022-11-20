import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundrivr/src/features/root/root_screen.dart';
import 'package:laundrivr/src/features/sign_in/sign_in_screen.dart';
import 'package:laundrivr/src/features/splash/splash_screen.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'features/number_entry/number_entry_screen.dart';

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
      theme: ThemeData.dark().copyWith(extensions: <ThemeExtension<dynamic>>[
        LaundrivrTheme(
          opaqueBackgroundColor: const Color(0xff0F162A),
          secondaryOpaqueBackgroundColor: const Color(0xff182243),
          tertiaryOpaqueBackgroundColor: const Color(0xff14223D),
          primaryBrightTextColor: const Color(0xffffffff),
          primaryTextStyle: GoogleFonts.urbanist(),
          selectedIconColor: const Color(0xffb3b8c8),
          unselectedIconColor: const Color(0xff546087),
          goldenTextColor: const Color(0xffFDDD02),
          bottomNavBarBackgroundColor: const Color(0xff273563),
          brightBadgeBackgroundColor: const Color(0xff4A72FF),
          pricingGreen: const Color(0xff6EF54C),
        )
      ]),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashScreen(), // rename to splash screen
        '/signin': (_) => const SignInScreen(),
        '/home': (_) => const RootScreen(), // actually make a home page
        '/number_entry': (_) => const NumberEntryScreen(),
      },
    );
  }
}
