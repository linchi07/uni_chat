import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/utils/auto_update_service.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';

class UNIChatAbout extends ConsumerWidget {
  const UNIChatAbout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60, bottom: 20),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(80),
                  spreadRadius: 3,
                  blurRadius: 4,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Image.asset("resources/uni_chat_no_bg.png"),
          ),
          const SizedBox(height: 5),
          Text(
            S.of(context).title,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            S.of(context).slogan,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).version_preview,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            height: 46,
            child: StdButton(
              color: theme.warningColor,
              onPressed: () {
                AutoUpdateService.checkUpdates(
                  context,
                  backgroundColor: theme.zeroGradeColor,
                );
              },
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.update, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        S.of(context).check_updates,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 300,
            height: 46,
            child: StdButton(
              color: Colors.green[200],
              onPressed: () {
                launchUrl(
                  Uri(
                    scheme: "https",
                    host: "unichat.wejoinnwk.com",
                    path: "docs/intro",
                  ),
                );
              },
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        S.of(context).help_guides,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 300,
            child: StdButton(
              onPressed: () {
                launchUrl(
                  Uri(
                    scheme: "https",
                    host: "github.com",
                    path: "linchi07/uni_chat",
                  ),
                );
              },
              child: Center(
                child: Row(
                  children: [
                    Image.asset("resources/github-mark-white.png", height: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        S.of(context).github_repo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 300,
            height: 46,
            child: StdButton(
              color: Colors.blueAccent,
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectionArea(
                        child: Text(
                          S
                              .of(context)
                              .email_with_holder("linchi@wejoinnwk.com"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).all_rights_reserved,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
