import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/api_configs/api_service.dart';
import 'package:uni_chat/api_configs/model_discovery_service.dart';
import 'package:uni_chat/api_configs/model_matcher.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

import '../utils/llm_icons.dart';
import 'api_configure.dart' show ModelAddWidget;

enum DiscoveryStatus { fetching, reviewing, empty, error }

class ModelDiscoveryWidget extends StatefulWidget {
  final BaseApiService service;
  final ApiKey apiKey;
  final String endpoint;
  final ThemeConfig theme;
  final Function(List<ModelMatchResult>) onSave;

  const ModelDiscoveryWidget({
    super.key,
    required this.service,
    required this.apiKey,
    required this.endpoint,
    required this.theme,
    required this.onSave,
  });

  @override
  State<ModelDiscoveryWidget> createState() => _ModelDiscoveryWidgetState();
}

class _ModelDiscoveryWidgetState extends State<ModelDiscoveryWidget>
    with TickerProviderStateMixin {
  DiscoveryStatus _status = DiscoveryStatus.fetching;
  List<ModelMatchResult> _results = [];
  String _errorMessage = "";

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 180),
    );
    final curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation);
    _fadeAnim = curvedAnimation;

    _startDiscovery();
    _animController.forward();

    // 注册关闭拦截
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        OverlayWrapper.registerOnClose(context, _handleClose);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// 带有动画的关闭函数
  Future<void> _closeWithAnimation() async {
    // 移除拦截器，防止无限递归
    OverlayWrapper.registerOnClose(context, null);
    await _animController.reverse();
    if (mounted) {
      OverlayWrapper.removeOverlay(context);
    }
  }

  Future<void> _startDiscovery() async {
    try {
      final discoveryService = ModelDiscoveryService(
        service: widget.service,
        endpoint: widget.endpoint,
        apiKey: widget.apiKey,
      );

      final results = await discoveryService.discoverAndMatch();

      if (!mounted) return;

      if (results.isEmpty) {
        setState(() => _status = DiscoveryStatus.empty);
      } else {
        setState(() {
          _results = results;
          _status = DiscoveryStatus.reviewing;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _status = DiscoveryStatus.error;
      });
    }
  }

  Future<bool> _handleClose() async {
    // 只有在审查界面且已经获取到结果时才提示
    if (_status == DiscoveryStatus.reviewing || _results.isNotEmpty) {
      final completer = Completer<bool>();
      OverlayPortalService.showDialog(
        context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).abandon_match_title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.theme.darkTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).abandon_match_subtitle,
              style: TextStyle(
                fontSize: 14,
                color: widget.theme.darkTextColor.withAlpha(150),
              ),
            ),
          ],
        ),
        backGroundColor: widget.theme.zeroGradeColor,
        actions: [
          StdButton(
            text: S.of(context).continue_editing,
            onPressed: () {
              completer.complete(false);
              OverlayPortalService.hide(context);
            },
          ),
          const SizedBox(width: 8),
          StdButton(
            text: S.of(context).abandon_and_exit,
            color: widget.theme.errorColor,
            onPressed: () {
              completer.complete(true);
              OverlayPortalService.hide(context);
            },
          ),
        ],
      );

      final shouldAbandon = await completer.future;
      if (shouldAbandon) {
        // 如果决定放弃，则执行带动画的关闭
        unawaited(_closeWithAnimation());
        return false; // 返回 false 因为我们手动处理了关闭
      }
      return false; // 继续留在页面
    }
    // 其他状态执行带动画的关闭
    unawaited(_closeWithAnimation());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: 600,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: widget.theme.zeroGradeColor,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case DiscoveryStatus.fetching:
        return _buildFetching();
      case DiscoveryStatus.reviewing:
        return _buildReviewing();
      case DiscoveryStatus.empty:
        return _buildEmpty();
      case DiscoveryStatus.error:
        return _buildError();
    }
  }

  Widget _buildFetching() {
    return Column(
      key: const ValueKey('fetching'),
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: widget.theme.primaryColor,
          strokeWidth: 3,
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context).fetching_models,
          style: TextStyle(
            color: widget.theme.darkTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewing() {
    return FutureBuilder<List<Model>>(
      key: const ValueKey('reviewing'),
      future: ApiDatabase.instance.getAllModels(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return ModelMatchReviewDialog(
          results: _results,
          allModels: snapshot.data!,
          theme: widget.theme,
          onConfirm: (finalResults) {
            widget.onSave(finalResults);
            unawaited(_closeWithAnimation());
          },
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Column(
      key: const ValueKey('empty'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.search_off_outlined,
          size: 48,
          color: widget.theme.darkTextColor.withAlpha(100),
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).no_models_found,
          textAlign: TextAlign.center,
          style: TextStyle(color: widget.theme.darkTextColor, fontSize: 16),
        ),
        const SizedBox(height: 24),
        StdButton(text: S.of(context).cancel, onPressed: _closeWithAnimation),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      key: const ValueKey('error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: widget.theme.errorColor),
        const SizedBox(height: 16),
        Text(
          S.of(context).fetch_failed,
          style: TextStyle(
            color: widget.theme.errorColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.theme.darkTextColor.withAlpha(150),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StdButton(
              text: S.of(context).cancel,
              onPressed: _closeWithAnimation,
            ),
            const SizedBox(width: 8),
            StdButton(
              text: S.of(context).retry,
              onPressed: () {
                setState(() => _status = DiscoveryStatus.fetching);
                _startDiscovery();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ModelMatchReviewDialog extends StatefulWidget {
  final List<ModelMatchResult> results;
  final List<Model> allModels;
  final ThemeConfig theme;
  final Function(List<ModelMatchResult>) onConfirm;

  const ModelMatchReviewDialog({
    super.key,
    required this.results,
    required this.allModels,
    required this.theme,
    required this.onConfirm,
  });

  @override
  State<ModelMatchReviewDialog> createState() => _ModelMatchReviewDialogState();
}

class _ModelMatchReviewDialogState extends State<ModelMatchReviewDialog> {
  late List<ModelMatchResult> _results;

  @override
  void initState() {
    super.initState();
    _results = List.from(widget.results);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            S.of(context).match_review_title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.theme.darkTextColor,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shrinkWrap: true,
            itemCount: _results.length,
            separatorBuilder: (context, index) =>
                Divider(color: widget.theme.darkTextColor.withAlpha(20)),
            itemBuilder: (context, index) {
              final result = _results[index];
              String? imgP;
              if (result.localModel != null) {
                imgP = LLMImageIndexer.tryGetImagePath(
                  result.localModel!.family,
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tooltip(
                            message: result.remoteName,
                            child: Text(
                              result.remoteName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.theme.darkTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildTag(result),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: widget.theme.darkTextColor.withAlpha(100),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (result.localModel != null)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: result.isConflictLoss
                                      ? widget.theme.errorColor.withAlpha(120)
                                      : widget.theme.primaryColor.withAlpha(80),
                                  width: result.isConflictLoss ? 1.5 : 1.0,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(7),
                                onTap: () => _showModelPicker(index),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      if (imgP != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: StdAvatar(
                                            assetImage: AssetImage(imgP),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          result.localModel?.friendlyName ??
                                              S.of(context).no_model,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: widget.theme.darkTextColor,
                                          ),
                                        ),
                                      ),
                                      if (result.localModel != null)
                                        StdIconButton(
                                          padding: const EdgeInsets.all(2),
                                          icon: Icons.close,
                                          onPressed: () {
                                            setState(() {
                                              _results[index].localModel = null;
                                              _results[index].config = null;
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (result.localModel != null && result.isConflictLoss)
                            const SizedBox(height: 8),
                          if (result.localModel == null || result.isConflictLoss)
                            Row(
                              children: [
                                if (result.localModel == null)
                                  Expanded(
                                    child: StdButton(
                                      text: S.of(context).select_model,
                                      onPressed: () => _showModelPicker(index),
                                    ),
                                  ),
                                if (result.localModel == null)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: StdButton(
                                    text: S.of(context).create_variant,
                                    color: widget.theme.primaryColor.withAlpha(
                                      result.localModel != null ? 30 : 50,
                                    ),
                                    onPressed: () async {
                                      Model? baseModel = result.localModel;
                                      // If it has a similarity > 0, find which model it almost matched
                                      if (baseModel == null &&
                                          result.similarity > 0) {
                                        // Find the best matching model from all models
                                        Model? best;
                                        double maxSim = 0;
                                        for (var m in widget.allModels) {
                                          double simId =
                                              ModelMatcher.calculateSimilarity(
                                                result.remoteName,
                                                m.id,
                                              );
                                          double simName =
                                              ModelMatcher.calculateSimilarity(
                                                result.remoteName,
                                                m.friendlyName,
                                              );
                                          double current = max(simId, simName);
                                          if (current > maxSim) {
                                            maxSim = current;
                                            best = m;
                                          }
                                        }
                                        if (maxSim > 0.3) {
                                          baseModel = best;
                                        }
                                      }

                                      final initialConfig = ProviderModelConfig(
                                        providerId: "",
                                        modelId: "",
                                        callName: result.remoteName,
                                      );

                                      OverlayPortalService.showDialog(
                                        context,
                                        width: 450,
                                        backGroundColor:
                                            widget.theme.zeroGradeColor,
                                        child: ModelAddWidget(
                                          theme: widget.theme,
                                          modelConfig: initialConfig,
                                          initialModel: baseModel,
                                          startWithAdding: true,
                                          onSave: (model, config) {
                                            setState(() {
                                              _results[index] =
                                                  ModelMatchResult(
                                                    remoteName: result.remoteName,
                                                    localModel: model,
                                                    config: config,
                                                    category: MatchCategory
                                                        .suggested,
                                                    similarity: 1.0,
                                                  );
                                            });
                                            OverlayPortalService.hide(context);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StdButton(
              text: S
                  .of(context)
                  .add_confirmed_models(
                    _results.where((r) => r.localModel != null).length,
                  ),
              color: widget.theme.primaryColor,
              onPressed: () {
                widget.onConfirm(
                  _results.where((r) => r.config != null).toList(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(ModelMatchResult result) {
    MatchCategory category = result.category;
    double similarity = result.similarity;
    Color color;
    String text;

    if (result.isConflictLoss) {
      color = widget.theme.errorColor;
      text = S.of(context).match_conflict;
    } else if (category == MatchCategory.confirmed || similarity >= 0.85) {
      color = widget.theme.okColor;
      text = S.of(context).match_confirmed;
    } else if (similarity >= 0.65) {
      color = widget.theme.warningColor;
      text = S.of(context).match_suggested;
    } else {
      color = widget.theme.primaryColor.withAlpha(150);
      text = S.of(context).match_unsupported;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (similarity > 0 && similarity < 1.0)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              S.of(context).match_similarity((similarity * 100).toStringAsFixed(0)),
              style: TextStyle(
                fontSize: 10,
                color: widget.theme.darkTextColor.withAlpha(150),
              ),
            ),
          ),
      ],
    );
  }

  void _showModelPicker(int index) {
    final result = _results[index];
    final initialConfig =
        result.config ??
        ProviderModelConfig(
          providerId: "", // 这里在 matchModels 中已经处理了，但为了安全做兜底
          modelId: result.localModel?.id ?? "",
          callName: result.remoteName,
        );

    OverlayPortalService.showDialog(
      context,
      width: 450,
      backGroundColor: widget.theme.zeroGradeColor,
      child: ModelAddWidget(
        theme: widget.theme,
        modelConfig: initialConfig,
        onSave: (model, config) {
          setState(() {
            _results[index] = ModelMatchResult(
              remoteName: result.remoteName,
              localModel: model,
              config: config,
              category: MatchCategory.suggested,
              similarity: 1.0,
            );
          });
          OverlayPortalService.hide(context);
        },
      ),
    );
  }
}
