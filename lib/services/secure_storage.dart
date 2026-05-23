import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyEmail = 'email';
  static const _keyUserName = 'user_name';
  static const _keyTrackingTrip = 'tracking_trip';
  static const _keyPickupLocation = 'pickup_location';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() => _storage.read(key: _keyToken);

  static Future<void> saveRole(String role) =>
      _storage.write(key: _keyRole, value: role);

  static Future<String?> getRole() => _storage.read(key: _keyRole);

  static Future<void> saveEmail(String email) =>
      _storage.write(key: _keyEmail, value: email);

  static Future<String?> getEmail() => _storage.read(key: _keyEmail);

  static Future<void> saveUserName(String name) =>
      _storage.write(key: _keyUserName, value: name);

  static Future<String?> getUserName() => _storage.read(key: _keyUserName);

  static Future<void> saveAvatar(String avatar) async {
    await _storage.write(key: 'avatar', value: avatar);
  }

  static Future<String?> getAvatar() async {
    return await _storage.read(key: 'avatar');
  }

  static Future<void> saveTrackingTrip(
    int tripId,
  ) =>
      _storage.write(
        key: _keyTrackingTrip,
        value: tripId.toString(),
      );

  static Future<int?> getTrackingTrip() async {
    final value = await _storage.read(
      key: _keyTrackingTrip,
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  static Future<void> clearTrackingTrip() async {
    await _storage.delete(
      key: _keyTrackingTrip,
    );
  }

  static Future<void> savePickupLocation(
    String value,
  ) =>
      _storage.write(
        key: _keyPickupLocation,
        value: value,
      );
  static Future<String?> getPickupLocation() => _storage.read(
        key: _keyPickupLocation,
      );
  static Future<void> clearPickupLocation() async {
    await _storage.delete(
      key: _keyPickupLocation,
    );
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static const _keyDropoff = 'dropoff_location';

  static Future<void> saveDropoffLocation(
    String value,
  ) =>
      _storage.write(
        key: _keyDropoff,
        value: value,
      );

  static Future<String?> getDropoffLocation() => _storage.read(
        key: _keyDropoff,
      );
}
