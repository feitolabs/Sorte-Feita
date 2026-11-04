import 'package:uuid/uuid.dart';

class HistoryEntry {
  final String id;
  final String type; // wheel, name_draw, number_draw, teams, pairs, decision, tasks
  final String title;
  final String summary;
  final DateTime createdAt;
  final Map<String, dynamic> configSnapshot;
  final dynamic result;
  bool isFavorite;

  HistoryEntry({
    String? id,
    required this.type,
    required this.title,
    required this.summary,
    DateTime? createdAt,
    required this.configSnapshot,
    required this.result,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'summary': summary,
        'createdAt': createdAt.toIso8601String(),
        'configSnapshot': configSnapshot,
        'result': result,
        'isFavorite': isFavorite,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String?,
        type: json['type'] as String? ?? 'generic',
        title: json['title'] as String? ?? 'Atividade',
        summary: json['summary'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        configSnapshot: json['configSnapshot'] as Map<String, dynamic>? ?? {},
        result: json['result'],
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}

