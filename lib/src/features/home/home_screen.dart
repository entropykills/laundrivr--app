import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/model/user/unloaded_user_metadata.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants.dart';
import '../../model/user/user_metadata.dart';
import '../../network/user_metadata_fetcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Create a subscription for the broadcast stream for the user metadata
  StreamSubscription<UserMetadata>? _userMetadataSubscription;

  /// User metadata
  UserMetadata _userMetadata = UnloadedUserMetadata();

  @override
  void initState() {
    super.initState();

    // subscribe to the user metadata
    _userMetadataSubscription = UserMetadataFetcher().stream.listen((metadata) {
      // set the state
      setState(() {
        _userMetadata = metadata;
      });
    });

    // initialize the metadata
    _initializeMetadata();
  }

  void _initializeMetadata() async {
    // fetch the metadata
    var metadata = await UserMetadataFetcher().fetchMetadata();
    setState(() {
      _userMetadata = metadata;
    });
  }

  Future<void> _refreshUserMetadata() async {
    // refresh the user metadata
    UserMetadataFetcher().clearCache();
    await UserMetadataFetcher().fetchMetadata(force: true);
  }

  @override
  void dispose() {
    // cancel the subscription
    _userMetadataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    // get the user from supabase
    final user = supabase.auth.currentUser!;
    String name = user.userMetadata?.entries
        .firstWhere((element) => element.key == 'name')
        .value;
    return RefreshIndicator(
      onRefresh: () => _refreshUserMetadata(),
      child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: GestureDetector(
                onTap: _signOut,
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: laundrivrTheme.primaryBrightTextColor,
                      size: 50,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out of',
                      style: laundrivrTheme.primaryTextStyle!
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 250),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: laundrivrTheme.bottomNavBarBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: laundrivrTheme.primaryTextStyle!.copyWith(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                    )
                  ],
                ),
              ),
            )),
        const SizedBox(height: 25),
        GestureDetector(
          onTap: () => _refreshUserMetadata(),
          child: SizedBox(
            width: 320,
            height: 220,
            // make the child a box with color
            child: Container(
              // rounded
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: laundrivrTheme.tertiaryOpaqueBackgroundColor,
                // add box shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: const Offset(2, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _userMetadata is UnloadedUserMetadata
                        ? const CircularProgressIndicator()
                        : Text(
                            _userMetadata is UnloadedUserMetadata
                                ? '\u{221E}'
                                : _userMetadata.loadsAvailable.toString(),
                            style: laundrivrTheme.primaryTextStyle!.copyWith(
                              fontSize: 120,
                              fontWeight: FontWeight.w800,
                              color: laundrivrTheme.goldenTextColor,
                            ),
                          ),
                    Text(
                      'Loads Available',
                      style: laundrivrTheme.primaryTextStyle!.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 50),
        SizedBox(
          width: 320,
          height: 150,
          // make the child a box with color
          child: Container(
            // rounded
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: laundrivrTheme.secondaryOpaqueBackgroundColor,
              // add box shadow
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 20,
                  offset: const Offset(2, 2), // changes position of shadow
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/scan_qr');
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/qr-code-scan-icon.svg',
                      height: 85,
                      width: 85,
                    ),
                    const SizedBox(width: 25),
                    Text(
                      'Scan',
                      style: laundrivrTheme.primaryTextStyle!.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: 320,
          height: 150,
          // make the child a box with color
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/number_entry');
            },
            child: Container(
              // rounded
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: laundrivrTheme.secondaryOpaqueBackgroundColor,
                // add box shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/enter-number-icon.svg',
                      height: 75,
                      width: 75,
                    ),
                    const SizedBox(width: 25),
                    Text(
                      'Enter',
                      style: laundrivrTheme.primaryTextStyle!.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ])),
    );
  }
}
