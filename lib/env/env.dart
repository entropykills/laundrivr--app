import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.local')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static const supabaseUrl = _Env.supabaseUrl;
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const supabaseAnonKey = _Env.supabaseAnonKey;
  @EnviedField(varName: 'APPCAST_URL')
  static const appcastUrl = _Env.appcastUrl;
}
