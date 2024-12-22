// To parse this JSON data, do
//
//     final wishlistEntry = wishlistEntryFromJson(jsonString);

import 'dart:convert';

WishlistEntry wishlistEntryFromJson(String str) =>
    WishlistEntry.fromJson(json.decode(str));

String wishlistEntryToJson(WishlistEntry data) => json.encode(data.toJson());

class WishlistEntry {
  int totalMax;
  int totalMin;
  List<Wishlist> wishlists;

  WishlistEntry({
    required this.totalMax,
    required this.totalMin,
    required this.wishlists,
  });

  factory WishlistEntry.fromJson(Map<String, dynamic> json) => WishlistEntry(
        totalMax: json["total_max"],
        totalMin: json["total_min"],
        wishlists: List<Wishlist>.from(
            json["wishlists"].map((x) => Wishlist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_max": totalMax,
        "total_min": totalMin,
        "wishlists": List<dynamic>.from(wishlists.map((x) => x.toJson())),
      };
}

class Wishlist {
  String name;
  int minPrice;
  int maxPrice;
  List<Product> products;

  Wishlist({
    required this.name,
    required this.minPrice,
    required this.maxPrice,
    required this.products,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        name: json["name"],
        minPrice: json["min_price"],
        maxPrice: json["max_price"],
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "min_price": minPrice,
        "max_price": maxPrice,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

class Product {
  String pk;
  String model;
  Fields fields;

  Product({
    required this.pk,
    required this.model,
    required this.fields,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        pk: json["pk"],
        model: json["model"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "pk": pk,
        "model": model,
        "fields": fields.toJson(),
      };
}

class Fields {
  String description;
  String productName;
  String productImage;
  String productCategory;
  String price;

  Fields({
    required this.description,
    required this.productName,
    required this.productImage,
    required this.productCategory,
    required this.price,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        description: json["description"],
        productName: json["product_name"],
        productImage: json["product_image"],
        productCategory: json["product_category"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "product_name": productName,
        "product_image": productImage,
        "product_category": productCategory,
        "price": price,
      };
}
