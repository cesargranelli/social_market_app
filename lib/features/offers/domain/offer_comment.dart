import 'package:cloud_firestore/cloud_firestore.dart';

/// Comentário de uma oferta (`offers/{offerId}/comments/{commentId}`).
///
/// Imutável após a criação: as rules negam update/delete no client
/// (moderação futura via Admin SDK).
class OfferComment {
  final String? id;
  final String uid;
  final String authorName;
  final String text;
  final DateTime? createdAt;

  const OfferComment({
    this.id,
    required this.uid,
    this.authorName = '',
    required this.text,
    this.createdAt,
  });

  factory OfferComment.fromMap(String id, Map<String, dynamic> map) {
    return OfferComment(
      id: id,
      uid: (map['uid'] as String?) ?? '',
      authorName: (map['authorName'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      createdAt: _asDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'authorName': authorName,
      'text': text,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  static DateTime? _asDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value;
    throw ArgumentError.value(value, 'createdAt', 'Data inválida');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OfferComment) return false;
    return other.id == id &&
        other.uid == uid &&
        other.authorName == authorName &&
        other.text == text &&
        _sameDate(other.createdAt, createdAt);
  }

  static bool _sameDate(DateTime? a, DateTime? b) =>
      a == null ? b == null : (b != null && a.isAtSameMomentAs(b));

  @override
  int get hashCode => Object.hash(id, uid, authorName, text);

  @override
  String toString() =>
      'OfferComment(id: $id, uid: $uid, authorName: $authorName, text: $text)';
}
