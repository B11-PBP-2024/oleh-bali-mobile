import 'dart:convert';

List<ProductSellerEntry> productSellerEntryFromJson(String str) => 
    List<ProductSellerEntry>.from(json.decode(str).map((x) => ProductSellerEntry.fromJson(x)));

String productSellerEntryToJson(List<ProductSellerEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductSellerEntry {
  String id;  
  String name;
  String description;
  String image;
  String category; 
  double price;

  ProductSellerEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.price,
  });

  factory ProductSellerEntry.fromJson(Map<String, dynamic> json) => ProductSellerEntry(
    id: json["id"],
    name: json["name"],
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    category: json["category"] ?? "No Category",
    price: double.tryParse(json["price"].toString()) ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name, 
    "description": description,
    "image": image,
    "category": category,
    "price": price,
  };
}