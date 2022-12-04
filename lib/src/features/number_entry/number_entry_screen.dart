import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants.dart';
import '../starting/starting_screen.dart';

class NumberEntryScreen extends StatefulWidget {
  const NumberEntryScreen({Key? key}) : super(key: key);

  @override
  State<NumberEntryScreen> createState() => _NumberEntryScreenState();
}

class _NumberEntryScreenState extends State<NumberEntryScreen> {
  String _targetDigits = "";
  bool _isTargetDigitsValidValue = false;

  late final StreamSubscription<AuthState> _authStateSubscription;
  final TextEditingController _targetDigitsValidityController =
      TextEditingController();
  bool _redirecting = false;

  Future<void> _backToHome() async {
    // push back to home
    Navigator.of(context).pop();
  }

  void _startBleTransaction() async {
    String targetMachineNameEnding = _targetDigits;

    _targetDigitsValidityController.clear();

    setState(() {
      _targetDigits = "";
    });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => StartingScreen(
              targetMachineNameEnding: targetMachineNameEnding,
            )));
  }

  @override
  void initState() {
    _targetDigitsValidityController.addListener(() {
      final isTargetDigitsValid =
          _targetDigitsAreValid(_targetDigitsValidityController.value.text);
      if (isTargetDigitsValid != _isTargetDigitsValidValue) {
        setState(() {
          _isTargetDigitsValidValue = isTargetDigitsValid;
        });
      }
    });
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

  String _validateTargetDigits(String value) {
    if (value.isEmpty) {
      return 'Please enter three numbers';
    }
    if (!_targetDigitsAreOnlyNumbers(value)) {
      return 'Please enter only numbers';
    }

    if (!_targetDigitsAreThree(value)) {
      return 'Please enter three numbers';
    }

    return "";
  }

  bool _targetDigitsAreValid(String value) {
    return value.isNotEmpty &&
        _targetDigitsAreThree(value) &&
        _targetDigitsAreOnlyNumbers(value);
  }

  bool _targetDigitsAreThree(String value) {
    return value.length == 3;
  }

  bool _targetDigitsAreOnlyNumbers(String targetDigits) {
    // return false if the input is not only numbers or if it's less than 3 digits
    return RegExp(r'^[0-9]+$').hasMatch(targetDigits);
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return Scaffold(
      backgroundColor: laundrivrTheme.opaqueBackgroundColor,
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 25),
                GestureDetector(
                  onTap: _backToHome,
                  child: Container(
                      decoration: BoxDecoration(
                          color: laundrivrTheme.backButtonBackgroundColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 45,
                          color: laundrivrTheme.opaqueBackgroundColor,
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 300,
              child: Text(
                "Enter the number on the Laundry Machine",
                textAlign: TextAlign.center,
                style: laundrivrTheme.primaryTextStyle!
                    .copyWith(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 300,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: PinCodeTextField(
                        controller: _targetDigitsValidityController,
                        appContext: context,
                        length: 3,
                        animationType: AnimationType.scale,
                        cursorColor: laundrivrTheme.primaryBrightTextColor,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          activeColor: _isTargetDigitsValidValue
                              ? laundrivrTheme.pinCodeActiveValidColor
                              : laundrivrTheme.pinCodeActiveInvalidColor,
                          fieldHeight: 75,
                          fieldWidth: 60,
                          inactiveColor: laundrivrTheme.pinCodeInactiveColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        validator: (v) {
                          String output = _validateTargetDigits(v!);
                          if (output.isEmpty) {
                            return null;
                          } else {
                            return output;
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            _targetDigits = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 320,
                      height: 75,
                      child: Container(
                        decoration: BoxDecoration(
                          color: laundrivrTheme.brightBadgeBackgroundColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: TextButton(
                          onPressed: _isTargetDigitsValidValue
                              ? _startBleTransaction
                              : null,
                          child: Text(
                            'Start',
                            style: laundrivrTheme.primaryTextStyle!.copyWith(
                              color: laundrivrTheme.primaryBrightTextColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        )),
      ),
    );
  }
}
