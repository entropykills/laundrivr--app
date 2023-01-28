flutter pub run flutter_launcher_icons
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk -t lib/main.dart
flutter build appbundle