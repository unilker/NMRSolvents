import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis_record.dart';

/// Saved analysis records, kept on the device in shared preferences as one
/// versioned JSON document.
class RecordsStore extends ChangeNotifier {
  RecordsStore(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final doc = jsonDecode(raw) as Map<String, dynamic>;
      _records.addAll(
        (doc['records'] as List).map(
          (e) => AnalysisRecord.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Object catch (e) {
      // Set the unreadable data aside instead of losing it, and keep
      // saving new records normally.
      debugPrint('Could not read saved records: $e');
      _records.clear();
      if (_prefs.getString(unreadableKey) == null) {
        _prefs.setString(unreadableKey, raw);
      }
    }
  }

  static const _key = 'records.v1';

  /// Where data that could not be read is kept for manual recovery.
  static const unreadableKey = 'records.v1.unreadable';

  final SharedPreferences _prefs;
  final List<AnalysisRecord> _records = [];

  /// Newest analysis first; same day: most recently saved first.
  List<AnalysisRecord> get records => [..._records]
    ..sort((a, b) {
      final byDate = b.analysisDate.compareTo(a.analysisDate);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });

  AnalysisRecord? byId(String id) {
    for (final r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> add(AnalysisRecord record) async {
    _records.add(record);
    await _save();
  }

  /// Saves changes made to a record returned by [records] or [byId].
  Future<void> update(AnalysisRecord record) async {
    assert(_records.contains(record));
    await _save();
  }

  Future<void> delete(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _save();
  }

  static String newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  Future<void> _save() async {
    notifyListeners();
    await _prefs.setString(
      _key,
      jsonEncode({
        'version': 1,
        'records': _records.map((r) => r.toJson()).toList(),
      }),
    );
  }
}
