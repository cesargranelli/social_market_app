import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferStatus {
  active,
  expired;

  static OfferStatus fromString(String value) {
    for (final status in OfferStatus.values) {
      if (status.name == value) return status;
    }
    throw ArgumentError.value(value, 'status', 'Status inválido');
  }
}

class OfferModel {
  final String? id;
  final String productName;
  final double price;
  final double? regularPrice;
  final String unit;
  final String storeId;

  /// Nome do mercado denormalizado na criação (evita join com /stores no
  /// feed). Sempre gravado no documento, mesmo vazio.
  final String storeName;
  final String authorUid;

  /// Nome de exibição do autor denormalizado na criação. Sempre gravado no
  /// documento, mesmo vazio.
  final String authorName;
  final String? imageUrl;
  final DateTime createdAt;
  final int confirmCount;
  final OfferStatus status;
  final DateTime? expiresAt;

  OfferModel({
    this.id,
    required this.productName,
    required this.price,
    this.regularPrice,
    this.unit = 'un',
    required this.storeId,
    this.storeName = '',
    required this.authorUid,
    this.authorName = '',
    this.imageUrl,
    required this.createdAt,
    this.confirmCount = 0,
    this.status = OfferStatus.active,
    this.expiresAt,
  }) {
    if (productName.trim().isEmpty) {
      throw ArgumentError.value(
        productName,
        'productName',
        'Nome do produto não pode ser vazio',
      );
    }
    if (price <= 0) {
      throw ArgumentError.value(price, 'price', 'Preço deve ser maior que zero');
    }
    if (regularPrice != null && regularPrice! <= 0) {
      throw ArgumentError.value(
        regularPrice,
        'regularPrice',
        'Preço regular deve ser maior que zero',
      );
    }
  }

  factory OfferModel.fromMap(String id, Map<String, dynamic> map) {
    return OfferModel(
      id: id,
      productName: (map['productName'] as String?) ?? '',
      price: (map['price'] as num).toDouble(),
      regularPrice: _asDoubleOrNull(map['regularPrice']),
      unit: (map['unit'] as String?) ?? 'un',
      storeId: (map['storeId'] as String?) ?? '',
      storeName: (map['storeName'] as String?) ?? '',
      authorUid: (map['authorUid'] as String?) ?? '',
      authorName: (map['authorName'] as String?) ?? '',
      imageUrl: map['imageUrl'] as String?,
      createdAt: _asDateTime(map['createdAt'])!,
      confirmCount: (map['confirmCount'] as num?)?.toInt() ?? 0,
      status: OfferStatus.fromString((map['status'] as String?) ?? 'active'),
      expiresAt: _asDateTime(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productName': productName,
      'price': price,
      if (regularPrice != null) 'regularPrice': regularPrice,
      'unit': unit,
      'storeId': storeId,
      // Sempre presentes (mesmo vazios) p/ consistência com as rules e leitura
      // direta no feed sem join.
      'storeName': storeName,
      'authorUid': authorUid,
      'authorName': authorName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmCount': confirmCount,
      'status': status.name,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }

  bool get isExpired => status == OfferStatus.expired;

  OfferModel copyWith({
    String? productName,
    double? price,
    Object? regularPrice = _unset,
    String? unit,
    String? storeId,
    String? storeName,
    String? authorUid,
    String? authorName,
    Object? imageUrl = _unset,
    DateTime? createdAt,
    int? confirmCount,
    OfferStatus? status,
    Object? expiresAt = _unset,
  }) {
    return OfferModel(
      id: id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      regularPrice:
          identical(regularPrice, _unset)
              ? this.regularPrice
              : regularPrice as double?,
      unit: unit ?? this.unit,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      authorUid: authorUid ?? this.authorUid,
      authorName: authorName ?? this.authorName,
      imageUrl: identical(imageUrl, _unset) ? this.imageUrl : imageUrl as String?,
      createdAt: createdAt ?? this.createdAt,
      confirmCount: confirmCount ?? this.confirmCount,
      status: status ?? this.status,
      expiresAt:
          identical(expiresAt, _unset) ? this.expiresAt : expiresAt as DateTime?,
    );
  }

  static double? _asDoubleOrNull(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw ArgumentError.value(value, 'regularPrice', 'Número inválido');
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
    if (other is! OfferModel) return false;
    return other.id == id &&
        other.productName == productName &&
        other.price == price &&
        other.regularPrice == regularPrice &&
        other.unit == unit &&
        other.storeId == storeId &&
        other.storeName == storeName &&
        other.authorUid == authorUid &&
        other.authorName == authorName &&
        other.imageUrl == imageUrl &&
        other.createdAt.isAtSameMomentAs(createdAt) &&
        other.confirmCount == confirmCount &&
        other.status == status &&
        _sameDate(other.expiresAt, expiresAt);
  }

  static bool _sameDate(DateTime? a, DateTime? b) =>
      a == null ? b == null : (b != null && a.isAtSameMomentAs(b));

  @override
  int get hashCode => Object.hash(
    id,
    productName,
    price,
    unit,
    storeId,
    storeName,
    authorUid,
    authorName,
    createdAt,
  );

  @override
  String toString() =>
      'OfferModel(id: $id, productName: $productName, price: $price)';
}

class _Unset {
  const _Unset();
}

const _unset = _Unset();
