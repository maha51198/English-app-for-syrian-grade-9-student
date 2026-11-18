import 'dart:convert';
import 'dart:math';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivationService {
  // ⚠️ حدّث هذا الرابط إذا تغيّر رابط ngrok
  static const String baseUrl = 'https://fulsome-filmier-axton.ngrok-free.dev';

  static const String _deviceIdKey = 'deviceId';

  /// يعيد معرفًا فريدًا للجهاز (ANDROID_ID على أندرويد، identifierForVendor على iOS)
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? cached = prefs.getString(_deviceIdKey);
    if (cached != null && cached.isNotEmpty) return cached;

    String deviceId;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // ANDROID_ID الحقيقي: فريد لكل جهاز + توقيع تطبيق
        final id = await const AndroidId().getId();
        deviceId = id ?? _generateRandomId();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor ?? _generateRandomId();
      } else {
        deviceId = _generateRandomId();
      }
    } catch (e) {
      debugPrint('getDeviceId error: $e');
      deviceId = _generateRandomId();
    }

    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  String _generateRandomId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// يتحقق من المفتاح عبر السيرفر
  Future<bool> verifyKey(String key) async {
    final deviceId = await getDeviceId();

    final uri = Uri.parse('$baseUrl/api/verify');
    debugPrint('POST $uri');
    debugPrint('deviceId=$deviceId');

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'StudyApp/1.0',
      },
      body: jsonEncode({
        'deviceId': deviceId,
        'key': key,
      }),
    )
        .timeout(const Duration(seconds: 20));

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['valid'] == true;
      } catch (e) {
        debugPrint('JSON parse error: $e');
        return false;
      }
    }
    return false;
  }
}