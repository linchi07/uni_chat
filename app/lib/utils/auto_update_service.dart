import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xxh3/xxh3.dart';

import '../generated/l10n.dart';

class AutoUpdateService {
  static const String _updateUrl =
      "https://unichatupdapi.wejoinnwk.com/v1/check_update";
  static const String _lastCheckKey = "last_update_check_time";
  static const String _modelsVersionKey = "models_version";
  static const String _providersVersionKey = "providers_version";
  static const String _dismissedAnnouncementKey = "dismissed_announcement_hash";

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
        "locale": PlatForm().languageCode,
      };
      final response = await http.post(
        Uri.parse(_updateUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'update_available') {
          // 过滤公告
          if (data['announcement'] != null) {
            final announcementStr = jsonEncode(data['announcement']);
            final announcementHash = xxh3(
              utf8.encode(announcementStr),
            ).toString();
            final dismissedHash = prefs.getString(_dismissedAnnouncementKey);

            if (announcementHash == dismissedHash) {
              data.remove('announcement');
            } else {
              data['announcement_hash'] = announcementHash;
            }
          }

          // 1. 处理 App 更新与公告
          if ((data['app_update'] != null || data['announcement'] != null) &&
              context.mounted) {
            _showAppUpdateOrAnnouncementDialog(
              context,
              backgroundColor,
              data,
              prefs,
            );
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

  static void _showAppUpdateOrAnnouncementDialog(
    BuildContext context,
    Color backgroundColor,
    Map<String, dynamic> data,
    SharedPreferences prefs,
  ) {
    final appUpdate = data['app_update'];
    final announcement = data['announcement'];
    final announcementHash = data['announcement_hash'];

    if (appUpdate == null && announcement == null) return;

    // 0 = App 更新阶段, 1 = 公告阶段
    final stepNotifier = ValueNotifier<int>(appUpdate != null ? 0 : 1);
    OverlayPortalService.showDialog(
      width: 400,
      context,
      backGroundColor: backgroundColor,
      child: ValueListenableBuilder<int>(
        valueListenable: stepNotifier,
        builder: (context, step, _) {
          if (step == 0) {
            final latestVersion = appUpdate!['latest_version'];
            final releaseNotes = appUpdate['release_notes'];
            final downloadUrl = appUpdate['download_url'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${S.of(context).new_version_available} ($latestVersion)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(releaseNotes ?? ''),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StdButton(
                      onPressed: () {
                        if (announcement != null) {
                          stepNotifier.value = 1; // 切换到公告
                        } else {
                          OverlayPortalService.hide(context);
                        }
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
                ),
              ],
            );
          } else {
            // 显示公告
            final text = announcement!['text'] ?? '';
            final String? url = announcement['url'];
            bool noPopOut = false;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "公告 Announcement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(text),
                const SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        StdCheckbox(
                          value: noPopOut,
                          onChanged: (value) {
                            setState(() {
                              noPopOut = value ?? false;
                            });
                          },
                          text: S.of(context).no_pop_out_announcement,
                        ),
                        const SizedBox(width: 10),
                        StdButton(
                          onPressed: () {
                            if (announcementHash != null && noPopOut) {
                              prefs.setString(
                                _dismissedAnnouncementKey,
                                announcementHash,
                              );
                            }
                            OverlayPortalService.hide(context);
                          },
                          text: S.of(context).confirm,
                        ),
                        if (url != null) ...[
                          const SizedBox(width: 10),
                          StdButton(
                            onPressed: () async {
                              if (announcementHash != null) {
                                prefs.setString(
                                  _dismissedAnnouncementKey,
                                  announcementHash,
                                );
                              }
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                              if (context.mounted) {
                                OverlayPortalService.hide(context);
                              }
                            },
                            child: const Text('前往查看'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
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
