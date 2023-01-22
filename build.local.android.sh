# shellcheck disable=SC2046
export $(grep -v '^#' .env.local | xargs)

flutter pub run flutter_launcher_icons
flutter build apk --split-per-abi --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" -t lib/main.dart