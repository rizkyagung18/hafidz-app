import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:uuid/uuid.dart';

const _deviceIdKey = 'device_id';

/// Anonymous UUID v4 persisted on first launch (docs/02 §7, docs/05 §1).
final deviceIdProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final existing = prefs.getString(_deviceIdKey);
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }
  final id = const Uuid().v4();
  // Fire-and-forget persist; Provider build must stay sync.
  prefs.setString(_deviceIdKey, id);
  return id;
});
