import 'package:upgrader/upgrader.dart';

import '../../env/env.dart';

class AppcastConfigurationProvider {
  // singleton
  static final AppcastConfigurationProvider _instance =
      AppcastConfigurationProvider._internal();

  factory AppcastConfigurationProvider() {
    return _instance;
  }

  AppcastConfigurationProvider._internal();

  AppcastConfiguration provide() {
    return AppcastConfiguration(
      url: Env.appcastUrl,
      supportedOS: ['android', 'ios'],
    );
  }
}
