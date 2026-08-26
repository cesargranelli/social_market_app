import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String? id;
  final String name;
  final String city;
  final String neighborhood;
  final String? address;
  final GeoPoint? geoPoint;
  final String createdBy;
  final DateTime? createdAt;

  const StoreModel({
    this.id,
    required this.name,
    required this.city,
    required this.neighborhood,
    this.address,
    this.geoPoint,
    required this.createdBy,
    this.createdAt,
  });

  factory StoreModel.fromMap(String id, Map<String, dynamic> map) {
    return StoreModel(
      id: id,
      name: (map['name'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      neighborhood: (map['neighborhood'] as String?) ?? '',
      address: map['address'] as String?,
      geoPoint: map['geoPoint'] as GeoPoint?,
      createdBy: (map['createdBy'] as String?) ?? '',
      createdAt: _asDateTimeOrNull(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'nameSearch': name.toLowerCase(),
      'city': city,
      'neighborhood': neighborhood,
      if (address != null) 'address': address,
      if (geoPoint != null) 'geoPoint': geoPoint,
      'createdBy': createdBy,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  StoreModel copyWith({
    String? name,
    String? city,
    String? neighborhood,
    Object? address = _unset,
    Object? geoPoint = _unset,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StoreModel(
      id: id,
      name: name ?? this.name,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      address: identical(address, _unset) ? this.address : address as String?,
      geoPoint: identical(geoPoint, _unset) ? this.geoPoint : geoPoint as GeoPoint?,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _asDateTimeOrNull(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value;
    throw ArgumentError.value(value, 'createdAt', 'Data inválida');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StoreModel) return false;
    final otherCreatedAt = other.createdAt;
    final thisCreatedAt = createdAt;
    final sameCreatedAt =
        otherCreatedAt == null
            ? thisCreatedAt == null
            : (thisCreatedAt != null &&
                otherCreatedAt.isAtSameMomentAs(thisCreatedAt));
    final otherGeoPoint = other.geoPoint;
    final thisGeoPoint = geoPoint;
    return other.id == id &&
        other.name == name &&
        other.city == city &&
        other.neighborhood == neighborhood &&
        other.address == address &&
        otherGeoPoint == thisGeoPoint &&
        other.createdBy == createdBy &&
        sameCreatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, city, neighborhood, address, geoPoint, createdBy);

  @override
  String toString() => 'StoreModel(id: $id, name: $name, city: $city)';
}

class _Unset {
  const _Unset();
}

const _unset = _Unset();
