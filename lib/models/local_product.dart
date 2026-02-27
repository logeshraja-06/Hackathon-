class LocalProduct {
  final int id;
  final String name;
  final String category;
  final String location;
  final double price;
  final String quantity;

  LocalProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.price,
    required this.quantity,
  });

  factory LocalProduct.fromJson(Map<String, dynamic> json) {
    return LocalProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as String,
    );
  }
}
