import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundrivr/src/features/home/home_screen.dart';
import 'package:laundrivr/src/features/sign_in/sign_in_screen.dart';
import 'package:laundrivr/src/features/splash/splash_screen.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://miniydczoaawbdteltpm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pbml5ZGN6b2Fhd2JkdGVsdHBtIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjU2MDQyOTEsImV4cCI6MTk4MTE4MDI5MX0.m1wlatPPRLcQI6PeFu_0LqH0MoVuU_6kqNtVJ5dX_g0',
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
