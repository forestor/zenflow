import 'dart:convert';

class MeditationRecord {
  final DateTime date;
  final int durationMinutes;
  final String type; // 'timer' or 'breathing'

  MeditationRecord({
    required this.date,
    required this.durationMinutes,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'type': type,
      };

  factory MeditationRecord.fromJson(Map<String, dynamic> json) {
    return MeditationRecord(
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      type: json['type'] as String,
    );
  }

  static String encodeList(List<MeditationRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }

  static List<MeditationRecord> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((item) => MeditationRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
