import 'package:shared_preferences/shared_preferences.dart';
import '../models/meditation_record.dart';

class StorageService {
  static const String _recordsKey = 'meditation_records';

  static Future<void> saveRecord(MeditationRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.add(record);
    await prefs.setString(_recordsKey, MeditationRecord.encodeList(records));
  }

  static Future<List<MeditationRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recordsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    return MeditationRecord.decodeList(jsonString);
  }

  static Future<int> getTotalMinutes() async {
    final records = await getRecords();
    return records.fold<int>(0, (sum, r) => sum + r.durationMinutes);
  }

  static Future<int> getStreak() async {
    final records = await getRecords();
    if (records.isEmpty) return 0;

    records.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final hasRecord = records.any((r) =>
          r.date.year == dayStart.year &&
          r.date.month == dayStart.month &&
          r.date.day == dayStart.day);

      if (hasRecord) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (i == 0) {
        // Today might not have a record yet, check yesterday
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  static Future<List<MeditationRecord>> getRecentRecords(int days) async {
    final records = await getRecords();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return records.where((r) => r.date.isAfter(cutoff)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
