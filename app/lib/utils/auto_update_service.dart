import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';

class AutoUpdateService {
  static const String _updateUrl =
      "https://unichatupdapi.wejoinnwk.com/v1/check_update";
  static const String _lastCheckKey = "last_update_check_time";
  static const String _modelsVersionKey = "models_version";
  static const String _providersVersionKey = "providers_version";

  static Future<void> checkUpdates(
    BuildContext context, {
    required Color backgroundColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;
      final buildNumberStr = packageInfo.buildNumber;
      final buildNumber = int.tryParse(buildNumberStr) ?? 0;

      final modelsVersion = prefs.getString(_modelsVersionKey) ?? "1970.01.01";
      final providersVersion =
          prefs.getString(_providersVersionKey) ?? "1970.01.01";

      final requestBody = {
        "app_version": appVersion,
        "build_number": buildNumber,
        "models_version": modelsVersion,
        "providers_version": providersVersion,
      };
      final response = await http.post(
        Uri.parse(_updateUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'update_available') {
          // 1. 处理 App 更新
          if (data['app_update'] != null && context.mounted) {
            _showAppUpdateDialog(context, backgroundColor, data['app_update']);
          }

          // 2. 处理 Models 更新
          if (data['models_update'] != null) {
            await _processModelsUpdate(data['models_update'], prefs);
          }

          // 3. 处理 Providers 更新
          if (data['providers_update'] != null) {
            await _processProvidersUpdate(data['providers_update'], prefs);
          }
        }

        // 更新最后检查时间
        await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());
      }
    } catch (e) {
      debugPrint("AutoUpdateService checkUpdates Error: $e");
    }
  }

  static void _showAppUpdateDialog(
    BuildContext context,
    Color backgroundColor,
    Map<String, dynamic> appUpdate,
  ) {
    final latestVersion = appUpdate['latest_version'];
    final releaseNotes = appUpdate['release_notes'];
    final downloadUrl = appUpdate['download_url'];

    OverlayPortalService.showDialog(
      context,
      backGroundColor: backgroundColor,
      child: Column(
        children: [
          Text(
            "${S.of(context).new_version_available} ($latestVersion)",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(releaseNotes ?? ''),
        ],
      ),
      actions: [
        StdButton(
          onPressed: () {
            OverlayPortalService.hide(context);
          },
          text: S.of(context).cancel,
        ),
        const SizedBox(width: 10),
        StdButton(
          onPressed: () async {
            if (downloadUrl != null) {
              final uri = Uri.parse(downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            }
            if (context.mounted) {
              OverlayPortalService.hide(context);
            }
          },
          child: Text(S.of(context).download),
        ),
      ],
    );
  }

  static Future<void> _processModelsUpdate(
    Map<String, dynamic> modelsUpdate,
    SharedPreferences prefs,
  ) async {
    final newVersion = modelsUpdate['version'];
    final dataList = modelsUpdate['data'] as List<dynamic>?;

    if (newVersion != null && dataList != null) {
      final db = ApiDatabase.instance;
      await db.processModelsUpdateMapList(dataList);
      await prefs.setString(_modelsVersionKey, newVersion);
    }
  }

  static Future<void> _processProvidersUpdate(
    Map<String, dynamic> providersUpdate,
    SharedPreferences prefs,
  ) async {
    final newVersion = providersUpdate['version'];
    final dataList = providersUpdate['data'] as List<dynamic>?;

    if (newVersion != null && dataList != null) {
      final db = ApiDatabase.instance;
      await db.processProvidersUpdateMapList(dataList);
      await prefs.setString(_providersVersionKey, newVersion);
    }
  }
}
