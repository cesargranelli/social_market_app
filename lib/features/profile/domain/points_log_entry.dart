import 'package:cloud_firestore/cloud_firestore.dart';

class PointsLogEntry {
  final String reason;
  final int delta;
  final DateTime at;

  const PointsLogEntry({
    required this.reason,
    required this.delta,
    required this.at,
  });

  factory PointsLogEntry.fromMap(Map<String, dynamic> map) {
    return PointsLogEntry(
      reason: (map['reason'] as String?) ?? '',
      delta: (map['delta'] as num?)?.toInt() ?? 0,
      at: _asDateTime(map['at']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reason': reason,
      'delta': delta,
      'at': Timestamp.fromDate(at),
    };
  }

  static DateTime _asDateTime(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value;
    throw ArgumentError.value(value, 'at', 'Data inválida');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointsLogEntry &&
        other.reason == reason &&
        other.delta == delta &&
        other.at.isAtSameMomentAs(at);
  }

  @override
  int get hashCode => Object.hash(reason, delta, at);

  @override
  String toString() =>
      'PointsLogEntry(reason: $reason, delta: $delta, at: $at)';
}
