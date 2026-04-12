import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/log_manager.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';

class LogSettingsPage extends ConsumerStatefulWidget {
  const LogSettingsPage({super.key});

  @override
  ConsumerState<LogSettingsPage> createState() => _LogSettingsPageState();
}

class _LogSettingsPageState extends ConsumerState<LogSettingsPage> {
  String? _logs;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    LogManager.instance.addListener(_onLogManagerChange);
  }

  @override
  void dispose() {
    LogManager.instance.removeListener(_onLogManagerChange);
    super.dispose();
  }

  void _onLogManagerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadLogs() async {
    final logs = await LogManager.instance.getLogs();
    if (mounted) {
      if (logs == "ERROR_NOT_INIT") {
        setState(() { _logs = S.of(context).log_file_not_init; });
      } else if (logs == "ERROR_NONE") {
        setState(() { _logs = S.of(context).log_none; });
      } else if (logs.startsWith("ERROR_READ_FAIL:")) {
        setState(() { _logs = S.of(context).log_read_fail(logs.substring("ERROR_READ_FAIL:".length)); });
      } else {
        setState(() { _logs = logs; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    bool isCopied = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            S.of(context).log_settings,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
          child: StdCheckbox(
            text: S.of(context).log_enable_global_catch,
            value: LogManager.instance.isLoggingEnabled,
            onChanged: (val) {
              if (val == null) return;
              LogManager.instance.setLoggingEnabled(val);
              if (val) {
                _loadLogs();
              }
            },
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.zeroGradeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: SelectableText(
                    _logs ?? S.of(context).log_loading,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: theme.textColor,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StdIconButton(
                        icon: Icons.refresh, 
                        tooltip: S.of(context).log_refresh,
                        onPressed: _loadLogs
                      ),
                      const SizedBox(width: 8),
                      StdIconButton(
                        icon: Icons.delete_outline,
                        color: theme.errorColor,
                        tooltip: S.of(context).log_clear,
                        onPressed: () async {
                          await LogManager.instance.clearLogs();
                          _loadLogs();
                        },
                      ),
                      const SizedBox(width: 8),
                      StatefulBuilder(
                        builder: (context, setState) {
                          if (isCopied) {
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                isCopied = false;
                              });
                            });
                          }
                          return StdIconButton(
                            iconSize: 16,
                            icon: isCopied ? Icons.check : Icons.copy,
                            tooltip: S.of(context).log_copy,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _logs ?? ""));
                              setState(() {
                                isCopied = true;
                              });
                            },
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),  
        const SizedBox(height: 16),
      ],
    );
  }
}
