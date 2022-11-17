import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundrivr/src/data/filter.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants.dart';
import '../../data/ble_functional_test.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _targetDigits = "";

  bool _showLoadingSpinner = false;

  // create an instance of ble functional test with the param for updating the loading spinner
  late BleFunctionalTest bleFunctionalTest =
      BleFunctionalTest(updateShowLoadingSpinner, showMyDialog);

  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _redirecting = false;

  Future<void> showMyDialog(String title, String message) async {
    // if not mounted don't do anything
    if (!mounted) {
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateShowLoadingSpinner(bool showLoadingSpinner) {
    setState(() {
      _showLoadingSpinner = showLoadingSpinner;
    });
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

  void _startBleTest() async {
    bleFunctionalTest.start(EndsWithFilter(_targetDigits));
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session == null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    // get the current user from supabase
    final User user = supabase.auth.currentUser!;
    return Scaffold(
      backgroundColor: laundrivrTheme.opaqueBackgroundColor,
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Home Screen'),
            const SizedBox(height: 20),
            Text('CURRENT USER ${user.email}'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signOut, child: const Text('Sign out')),
            const SizedBox(height: 100),
            SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '3 DIGIT MACHINE ID',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _targetDigits = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _startBleTest, child: const Text('EXECUTE')),
                  const SizedBox(height: 20),
                  if (_showLoadingSpinner)
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
