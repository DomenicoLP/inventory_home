class ShoppingItem {
  final int? id;
  final String name;
  final double? quantity;
  final String? unit;
  final bool purchased;
  final String? notes;

  const ShoppingItem({
    this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.purchased = false,
    this.notes,
  });

  ShoppingItem copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unit,
    bool? purchased,
    String? notes,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchased: purchased ?? this.purchased,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'purchased': purchased ? 1 : 0,
      'notes': notes,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] != null
          ? (map['quantity'] as num).toDouble()
          : null,
      unit: map['unit'] as String?,
      purchased: map['purchased'] == 1,
      notes: map['notes'] as String?,
    );
  }
}