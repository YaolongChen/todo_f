import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KvStore {
  const KvStore({required this._prefs, required this._secureStorage});

  final SharedPreferencesAsync _prefs;
  final FlutterSecureStorage _secureStorage;
}
