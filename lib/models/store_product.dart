// To parse this JSON data, do
//
//     final storesProduct = storesProductFromJson(jsonString);

import 'dart:convert';

StoresProduct storesProductFromJson(String str) =>
    StoresProduct.fromJson(json.decode(str));

String storesProductToJson(StoresProduct data) => json.encode(data.toJson());

class StoresProduct {
  Product product;
  List<SellersWithPrice> sellersWithPrices;

  StoresProduct({
    required this.product,
    required this.sellersWithPrices,
  });

  factory StoresProduct.fromJson(Map<String, dynamic> json) => StoresProduct(
        product: Product.fromJson(json["product"]),
        sellersWithPrices: List<SellersWithPrice>.from(
            json["sellers_with_prices"]
                .map((x) => SellersWithPrice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "product": product.toJson(),
        "sellers_with_prices":
            List<dynamic>.from(sellersWithPrices.map((x) => x.toJson())),
      };
}

class Product {
  String id;
  String productName;
  String productCategory;
  String description;
  String productImage;

  Product({
    required this.id,
    required this.productName,
    required this.productCategory,
    required this.description,
    required this.productImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productName: json["product_name"],
        productCategory: json["product_category"],
        description: json["description"],
        productImage: json["product_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "product_category": productCategory,
        "description": description,
        "product_image": productImage,
      };
}

class SellersWithPrice {
  Seller seller;
  int price;

  SellersWithPrice({
    required this.seller,
    required this.price,
  });

  factory SellersWithPrice.fromJson(Map<String, dynamic> json) =>
      SellersWithPrice(
        seller: Seller.fromJson(json["seller"]),
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "seller": seller.toJson(),
        "price": price,
      };
}

class Seller {
  int id;
  String storeName;
  String profilePicture;
  String city;
  String subdistrict;
  String village;
  String address;
  String maps;

  Seller({
    required this.id,
    required this.storeName,
    required this.profilePicture,
    required this.city,
    required this.subdistrict,
    required this.village,
    required this.address,
    required this.maps,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
        id: json["id"],
        storeName: json["store_name"],
        profilePicture: json["profile_picture"],
        city: json["city"],
        subdistrict: json["subdistrict"],
        village: json["village"],
        address: json["address"],
        maps: json["maps"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "store_name": storeName,
        "profile_picture": profilePicture,
        "city": city,
        "subdistrict": subdistrict,
        "village": village,
        "address": address,
        "maps": maps,
      };
}
