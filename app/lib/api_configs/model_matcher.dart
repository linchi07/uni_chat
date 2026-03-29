import 'dart:math';
import 'api_models.dart';

enum MatchCategory { confirmed, suggested, unknown }

class ModelMatchResult {
  final String remoteName;
  Model? localModel;
  ProviderModelConfig? config;
  MatchCategory category;
  final double similarity;

  ModelMatchResult({
    required this.remoteName,
    this.localModel,
    this.config,
    required this.category,
    this.similarity = 0.0,
  });
}

class ModelMatcher {
  static double calculateSimilarity(String s1, String s2) {
    String r1 = _stripPrefix(s1).toLowerCase();
    String r2 = _stripPrefix(s2).toLowerCase();

    // 1. Extract and remove dates
    final dateReg = RegExp(
      r'[-_\.]?(20[23]\d[-_\.]?\d{2}[-_\.]?\d{2}|[01]\d[0123]\d|[2-9]\d(?:0[1-9]|1[0-2]))(?:[-_\.]|$)',
    );
    final dateMatch1 = dateReg.firstMatch(r1);
    final dateMatch2 = dateReg.firstMatch(r2);
    String dateStr1 = dateMatch1 != null ? dateMatch1.group(1)! : '';
    String dateStr2 = dateMatch2 != null ? dateMatch2.group(1)! : '';

    if (dateMatch1 != null) {
      r1 = r1.replaceFirst(dateMatch1.group(0)!, ' ');
    }
    if (dateMatch2 != null) {
      r2 = r2.replaceFirst(dateMatch2.group(0)!, ' ');
    }

    double penalty = 0.0;
    if (dateStr1 != dateStr2) {
      // Date mismatch: extremely light penalty (allows different snapshots of same model)
      penalty += 0.05;
    }

    // 2. Extract params (e.g., 7b, 14b, 8x7b, 128k)
    final paramReg = RegExp(
      r'\b(?:\d+x)?\d+(?:\.\d+)?[bmk]\b',
      caseSensitive: false,
    );
    final size1 = paramReg.allMatches(r1).map((m) => m.group(0)!).toSet();
    final size2 = paramReg.allMatches(r2).map((m) => m.group(0)!).toSet();

    if (size1.isNotEmpty || size2.isNotEmpty) {
      if (size1.isNotEmpty && size2.isNotEmpty) {
        if (size1.intersection(size2).isEmpty) {
          // Hard mismatch: models have different parameter sizes (e.g., 7b vs 14b)
          return 0.3; // Hard penalty cap
        }
      } else {
        // Soft mismatch: one has sizes specified, the other doesn't
        penalty += 0.15;
      }
    }

    // Strip params for further checks
    r1 = r1.replaceAll(paramReg, ' ');
    r2 = r2.replaceAll(paramReg, ' ');

    // 3. Extract version numbers (e.g., v3.5, 4o, 2.5 -> 3.5, 4, 2.5)
    final versionReg = RegExp(r'\d+(?:\.\d+)*');
    final ver1 = versionReg.allMatches(r1).map((m) => m.group(0)!).toSet();
    final ver2 = versionReg.allMatches(r2).map((m) => m.group(0)!).toSet();

    if (ver1.isNotEmpty && ver2.isNotEmpty) {
      if (ver1.intersection(ver2).isEmpty) {
        // Hard mismatch: completely different version numbers (e.g., qwen2 vs qwen3)
        return 0.4;
      }
    } else if (ver1.isNotEmpty || ver2.isNotEmpty) {
      // Soft mismatch: one specifies version, the other doesn't
      penalty += 0.15;
    }

    // 4. Clean up noise words (functional synonyms)
    final noiseReg = RegExp(
      r'\b(chat|instruct|base|preview|uncensored|awq|gptq|gguf|int[48]|fp16|0)\b',
      caseSensitive: false,
    );
    r1 = r1.replaceAll(noiseReg, ' ');
    r2 = r2.replaceAll(noiseReg, ' ');

    // 5. Base Name Levenshtein
    String core1 = r1.replaceAll(RegExp(r'[^a-z0-9]'), '');
    String core2 = r2.replaceAll(RegExp(r'[^a-z0-9]'), '');

    double coreSim = 0.0;
    if (core1 == core2) {
      coreSim = 1.0;
    } else if (core1.isEmpty || core2.isEmpty) {
      coreSim = 0.0;
    } else {
      int distance = _levenshteinDistance(core1, core2);
      int maxLength = max(core1.length, core2.length);
      coreSim = 1.0 - (distance / maxLength);

      // Substring bonus: 减缓未匹配到的自定义后缀导致的相似度暴降
      if (core1.length > 2 && core2.length > 2) {
        if (core1.contains(core2) || core2.contains(core1)) {
          coreSim = coreSim + (1.0 - coreSim) * 0.5;
        }
      }
    }

    double finalSim = coreSim - penalty;
    return max(0.0, finalSim);
  }

  static String _stripPrefix(String name) {
    int idx = name.lastIndexOf('/');
    if (idx != -1) {
      return name.substring(idx + 1);
    }
    return name;
  }

  static int _levenshteinDistance(String s1, String s2) {
    List<int> prev = List.generate(s2.length + 1, (i) => i);
    List<int> curr = List.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= s2.length; j++) {
        int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        curr[j] = min(curr[j - 1] + 1, min(prev[j] + 1, prev[j - 1] + cost));
      }
      prev = List.from(curr);
    }
    return prev[s2.length];
  }

  static List<ModelMatchResult> matchModels(
    String providerId,
    List<String> remoteNames,
    List<Model> localModels,
  ) {
    List<ModelMatchResult> results = [];

    for (var remote in remoteNames) {
      // 1. Exact match (ID or Friendly Name)
      Model? exactMatch;
      for (var local in localModels) {
        if (local.id.toLowerCase() == remote.toLowerCase() ||
            local.friendlyName.toLowerCase() == remote.toLowerCase()) {
          exactMatch = local;
          break;
        }
        // Handle Gemini format "models/..."
        if (remote.startsWith("models/") &&
            local.id.toLowerCase() == remote.substring(7).toLowerCase()) {
          exactMatch = local;
          break;
        }
      }

      if (exactMatch != null) {
        results.add(
          ModelMatchResult(
            remoteName: remote,
            localModel: exactMatch,
            config: ProviderModelConfig(
              providerId: providerId,
              modelId: exactMatch.id,
              callName: remote,
            ),
            category: MatchCategory.confirmed,
            similarity: 1.0,
          ),
        );
        continue;
      }

      // 2. Fuzzy match
      Model? bestMatch;
      double maxSimilarity = 0.0;

      for (var local in localModels) {
        double simId = calculateSimilarity(remote, local.id);
        double simName = calculateSimilarity(remote, local.friendlyName);
        double currentMax = max(simId, simName);

        if (currentMax > maxSimilarity) {
          maxSimilarity = currentMax;
          bestMatch = local;
        }
      }

      if (maxSimilarity >= 0.65) {
        results.add(
          ModelMatchResult(
            remoteName: remote,
            localModel: bestMatch,
            config: ProviderModelConfig(
              providerId: providerId,
              modelId: bestMatch!.id,
              callName: remote,
            ),
            category: MatchCategory.suggested,
            similarity: maxSimilarity,
          ),
        );
      } else {
        results.add(
          ModelMatchResult(
            remoteName: remote,
            localModel: null,
            config: null,
            category: MatchCategory.unknown,
            similarity: maxSimilarity,
          ),
        );
      }
    }

    return results;
  }
}
