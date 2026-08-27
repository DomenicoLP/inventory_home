class FoodProduct {
  final int? id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String location;
  final DateTime? expirationDate;
  final double? minimumStock;
  final String? notes;

  const FoodProduct({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.location,
    this.expirationDate,
    this.minimumStock,
    this.notes,
  });

  FoodProduct copyWith({
    int? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? location,
    DateTime? expirationDate,
    double? minimumStock,
    String? notes,
  }) {
    return FoodProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      expirationDate: expirationDate ?? this.expirationDate,
      minimumStock: minimumStock ?? this.minimumStock,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'expirationDate': expirationDate?.toIso8601String(),
      'minimumStock': minimumStock,
      'notes': notes,
    };
  }

  factory FoodProduct.fromMap(Map<String, dynamic> map) {
    return FoodProduct(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      location: map['location'] as String,
      expirationDate: map['expirationDate'] != null
          ? DateTime.parse(map['expirationDate'] as String)
          : null,
      minimumStock: map['minimumStock'] != null
          ? (map['minimumStock'] as num).toDouble()
          : null,
      notes: map['notes'] as String?,
    );
  }
}