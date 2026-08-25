import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final int points;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.points = 0,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      displayName: (map['displayName'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      points: (map['points'] as num?)?.toInt() ?? 0,
      createdAt: _asDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    int? points,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      photoUrl:
          identical(photoUrl, _unset) ? this.photoUrl : photoUrl,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _asDateTime(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value;
    throw ArgumentError.value(value, 'createdAt', 'Data inválida');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.points == points &&
        other.createdAt.isAtSameMomentAs(createdAt);
  }

  @override
  int get hashCode => Object.hash(uid, displayName, photoUrl, points, createdAt);

  @override
  String toString() =>
      'UserModel(uid: $uid, displayName: $displayName, points: $points)';
}

class _Unset {
  const _Unset();
}

const _unset = _Unset();
