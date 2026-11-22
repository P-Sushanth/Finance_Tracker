import 'dart:convert';
import 'package:http/http.dart' as http;

class AppUpdateInfo {
  final int currentVersionCode;
  final String currentVersionName;
  final int latestVersionCode;
  final String latestVersionName;
  final String apkUrl;
  final String releaseNotes;
  final bool isUpdateAvailable;

  const AppUpdateInfo({
    required this.currentVersionCode,
    required this.currentVersionName,
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.apkUrl,
    required this.releaseNotes,
    required this.isUpdateAvailable,
  });

  factory AppUpdateInfo.fromMap({
    required Map<String, dynamic> map,
    required int currentVersionCode,
    required String currentVersionName,
  }) {
    final latestCode = (map['version_code'] as num?)?.toInt() ?? currentVersionCode;
    final latestName = (map['version_name'] as String?) ?? currentVersionName;
    final apkUrl = (map['apk_url'] as String?) ?? '';
    final notes = (map['release_notes'] as String?) ?? 'No release notes provided.';

    return AppUpdateInfo(
      currentVersionCode: currentVersionCode,
      currentVersionName: currentVersionName,
      latestVersionCode: latestCode,
      latestVersionName: latestName,
      apkUrl: apkUrl,
      releaseNotes: notes,
      isUpdateAvailable: latestCode > currentVersionCode,
    );
  }
}

class UpdateService {
  static const int currentVersionCode = 1;
  static const String currentVersionName = '1.0.0';
  static const String defaultManifestUrl =
      'https://raw.githubusercontent.com/personal/finance_tracker/main/version.json';

  final http.Client _client;

  UpdateService([http.Client? client]) : _client = client ?? http.Client();

  /// Checks for available APK update against a version.json manifest.
  Future<AppUpdateInfo> checkForUpdate({String? manifestUrl}) async {
    final url = Uri.parse(manifestUrl ?? defaultManifestUrl);
    final response = await _client.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return AppUpdateInfo.fromMap(
          map: decoded,
          currentVersionCode: currentVersionCode,
          currentVersionName: currentVersionName,
        );
      }
    }

    throw Exception('Failed to load version manifest (HTTP ${response.statusCode})');
  }
}
