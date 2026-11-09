import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AlmacenamientoToken {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _keyToken = 'auth_token';

  // Guardar token tras el login
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Leer token al abrir la app
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Borrar token al hacer logout
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }
}