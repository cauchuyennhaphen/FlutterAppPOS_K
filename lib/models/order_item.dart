enum ItemCategory { food, drink, other }

class OrderItem {
  final String id;
  final String name;
  final int unitPrice; // stored in smallest currency unit (e.g., cents or VND)
  int quantity;
  final ItemCategory category;

  OrderItem({required this.id, required this.name, required this.unitPrice, this.quantity = 1, this.category = ItemCategory.other});

  int get subtotal => unitPrice * quantity;

  // helper to get localized label
  String categoryLabel() {
    switch (category) {
      case ItemCategory.food:
        return 'Thức ăn';
      case ItemCategory.drink:
        return 'Nước uống';
      case ItemCategory.other:
        return 'Khác';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'category': category.name,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] ?? 'other').toString();
    ItemCategory cat;
    switch (catStr) {
      case 'food':
        cat = ItemCategory.food;
        break;
      case 'drink':
        cat = ItemCategory.drink;
        break;
      default:
        cat = ItemCategory.other;
    }

    return OrderItem(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? '',
      unitPrice: (json['unitPrice'] is int) ? json['unitPrice'] as int : int.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
      quantity: (json['quantity'] is int) ? json['quantity'] as int : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      category: cat,
    );
  }
}
