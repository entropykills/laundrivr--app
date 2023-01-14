import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundrivr/src/ble/ble_reactive_instance.dart';
import 'package:laundrivr/src/features/root/root_screen.dart';
import 'package:laundrivr/src/features/scan_qr/scan_qr_screen.dart';
import 'package:laundrivr/src/features/sign_in/sign_in_screen.dart';
import 'package:laundrivr/src/features/splash/splash_screen.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/network/package_fetcher.dart';
import 'package:laundrivr/src/network/user_metadata_fetcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletons/skeletons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/constants.dart';
import 'src/features/number_entry/number_entry_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );

  // fetch user metadata
  UserMetadataFetcher().fetchMetadata();
  // fetch packages
  PackageFetcher().fetchPackages();

  runApp(const LaundrivrApp());
}

class LaundrivrApp extends StatelessWidget {
  const LaundrivrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsFlutterBinding.ensureInitialized();

    _handlePermissionsRequests(context);

    // initialize ble
    BleReactiveInstance().ble.initialize();

    return SkeletonTheme(
      darkShimmerGradient: const LinearGradient(
        colors: [
          Color(0xff0F162A),
          Color(0xff14223D),
          Color(0xff14223D),
          Color(0xff0F162A),
        ],
        stops: [
          0.0,
          0.3,
          1,
          1,
        ],
        begin: Alignment(-1, 0),
        end: Alignment(1, 0),
      ),
      child: MaterialApp(
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
            brightBadgeBackgroundColor: const Color(0xff479ade),
            pricingGreen: const Color(0xff6EF54C),
            backButtonBackgroundColor: const Color(0xD9D9D9D9),
            pinCodeInactiveColor: const Color(0xff546087),
            pinCodeActiveValidColor: const Color(0xff6EF54C),
            pinCodeActiveInvalidColor: const Color(
              0xffFF0000,
            ),
          )
        ]),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (_) => const SplashScreen(),
          '/signin': (_) => const SignInScreen(),
          '/home': (_) => const RootScreen(),
          '/number_entry': (_) => const NumberEntryScreen(),
          '/scan_qr': (_) => const ScanQrScreen(),
        },
      ),
    );
  }

  Future<AlertButton> _showDialog(String title, String message) async {
    return FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
  }

  Future<void> _handlePermissionsRequests(BuildContext context) async {
    // add all bluetooth permissions to a list and check if all are granted
    final List<Permission> permissions = <Permission>[
      // Permission.bluetoothScan,
      Permission.bluetooth,
      // Permission.bluetoothAdvertise,
      // Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    // check if all permissions are granted by requesting them
    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    // loop entire list and check if all permissions are granted
    for (final Permission permission in permissions) {
      PermissionStatus status = statuses[permission]!;
      log('Permission: $permission, Status: $status');
    }

    // check if all permissions are granted
    if (statuses.values.every((PermissionStatus status) => status.isGranted)) {
      // all permissions are granted
      return;
    } else {
      // at least one permission is denied
      // check if any are permanently denied, if so open app settings
      if (statuses.values
          .any((PermissionStatus status) => status.isPermanentlyDenied)) {
        // show a dialog to open app settings
        final AlertButton result = await _showDialog(
            'Permissions Required',
            'Please grant all permissions to use the app. '
                'You can do this by going to the app settings.');

        if (result == AlertButton.okButton) {
          // open app settings
          await openAppSettings();
        }
      }
    }
  }
}
