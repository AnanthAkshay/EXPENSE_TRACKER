import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCache {
  static const String _cacheBoxName = 'http_cache_box';
  static const String _queueBoxName = 'offline_queue_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_cacheBoxName);
    await Hive.openBox(_queueBoxName);
  }

  static Box get _cacheBox => Hive.box(_cacheBoxName);
  static Box get _queueBox => Hive.box(_queueBoxName);

  static Future<void> saveCache(String key, dynamic data) async {
    await _cacheBox.put(key, jsonEncode(data));
  }

  static dynamic getCache(String key) {
    final raw = _cacheBox.get(key);
    if (raw != null) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> enqueueWrite(Map<String, dynamic> action) async {
    final list = _queueBox.get('queue', defaultValue: <dynamic>[]) as List;
    list.add(jsonEncode(action));
    await _queueBox.put('queue', list);
  }

  static List<Map<String, dynamic>> getQueue() {
    final list = _queueBox.get('queue', defaultValue: <dynamic>[]) as List;
    return list.map((e) => jsonDecode(e as String) as Map<String, dynamic>).toList();
  }

  static Future<void> clearQueue() async {
    await _queueBox.put('queue', <dynamic>[]);
  }

  static bool hasPendingSync() {
    final list = _queueBox.get('queue', defaultValue: <dynamic>[]) as List;
    return list.isNotEmpty;
  }
}
