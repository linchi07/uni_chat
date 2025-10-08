import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_provider.dart';

class ActivityState {
  Map<String, Activity> activities;
  ActivityState({required this.activities});

  ActivityState copyWith({Map<String, Activity>? activities}) =>
      ActivityState(activities: activities ?? this.activities);
}

enum ActivityType { ragEmbedding }

enum ActivityStateType { loading, success, error }

class Activity {
  String name;
  String referTo;
  ActivityType type;
  ActivityStateType stateType;
  String? errorMessage;
  Activity({
    required this.name,
    required this.referTo,
    required this.type,
    required this.stateType,
    this.errorMessage,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'],
      referTo: json['referTo'],
      type: ActivityType.values[json['type']],
      stateType: ActivityStateType.values[json['stateType']],
      errorMessage: json['errorMessage'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'referTo': referTo,
      'type': type.index,
      'stateType': stateType.index,
      'errorMessage': errorMessage,
    };
  }
}

class ActivityManager extends StateNotifier<ActivityState> {
  ActivityManager(Ref ref) : super(ActivityState(activities: {})) {
    _ref = ref;
    loadUnFinishedActivity();
  }
  late final Ref _ref;
  SharedPreferences? _prefs;
  void loadUnFinishedActivity() async {
    _prefs ??= await SharedPreferences.getInstance();
    var ac = _prefs!.getStringList("activity") ?? [];
    for (var o in ac) {
      var a = Activity.fromJson(jsonDecode(o));
      //这里重新启动任务的时候我认为可以把error给去掉
      a.errorMessage = null;
      a.stateType = ActivityStateType.loading;
      await startActivity(a);
    }
  }

  void saveState() async {
    _prefs ??= await SharedPreferences.getInstance();
    _prefs!.setStringList("activity", [
      for (var a in state.activities.values) jsonEncode(a.toJson()),
    ]);
  }

  Future<void> startActivity(Activity activity) async {
    if (activity.type == ActivityType.ragEmbedding) {
      var kb = await RAGDatabaseManager().getKnowledgeBaseById(
        activity.referTo,
      );
      if (kb == null) {
        //TODO: this should throw an error
        return;
      }
      //TODO: 处理短时间重复提交的问题
      _ref.read(ragProvider).processKnowledgeBase(kb, activity.name);
      state = state.copyWith(
        activities: {...state.activities, activity.name: activity},
      );
    }
    saveState();
  }

  void onActivityComplete(String activityId) async {
    state.activities.remove(activityId);
    state = state.copyWith(activities: {...state.activities});
    saveState();
  }

  void onActivityError(String activityId, String error) {
    state.activities[activityId]?.stateType = ActivityStateType.error;
    state.activities[activityId]?.errorMessage = error;
    state = state.copyWith();
  }
}

final activityProvider = StateNotifierProvider<ActivityManager, ActivityState>(
  (ref) => ActivityManager(ref),
);
