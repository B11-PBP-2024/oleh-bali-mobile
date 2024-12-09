// To parse this JSON data, do
//
//     final productEntry = productEntryFromJson(jsonString);

import 'dart:convert';

List<ProductEntry> productEntryFromJson(String str) => List<ProductEntry>.from(json.decode(str).map((x) => ProductEntry.fromJson(x)));

String productEntryToJson(List<ProductEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductEntry {
    String pk;
    Model model;
    Fields fields;

    ProductEntry({
        required this.pk,
        required this.model,
        required this.fields,
    });

    factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        pk: json["pk"],
        model: modelValues.map[json["model"]]!,
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "model": modelValues.reverse[model],
        "fields": fields.toJson(),
    };
}

class Fields {
    String description;
    String productName;
    String productImage;
    String productCategory;
    Price price;
    bool isWishlist;
    bool isLike;
    int likeCount;

    Fields({
        required this.description,
        required this.productName,
        required this.productImage,
        required this.productCategory,
        required this.price,
        required this.isWishlist,
        required this.isLike,
        required this.likeCount,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        description: json["description"],
        productName: json["product_name"],
        productImage: json["product_image"],
        productCategory: json["product_category"],
        price: priceValues.map[json["price"]]!,
        isWishlist: json["is_wishlist"],
        isLike: json["is_like"],
        likeCount: json["like_count"],
    );

    Map<String, dynamic> toJson() => {
        "description": description,
        "product_name": productName,
        "product_image": productImage,
        "product_category": productCategory,
        "price": priceValues.reverse[price],
        "is_wishlist": isWishlist,
        "is_like": isLike,
        "like_count": likeCount,
    };
}

enum Price {
    PRICE_NOT_AVAILABLE,
    RP200000,
    RP2000000,
    RP300000,
    RP35000
}

final priceValues = EnumValues({
    "Price not available": Price.PRICE_NOT_AVAILABLE,
    "Rp200000": Price.RP200000,
    "Rp2000000": Price.RP2000000,
    "Rp300000": Price.RP300000,
    "Rp35000": Price.RP35000
});

enum Model {
    SELLER_PRODUCTENTRY
}

final modelValues = EnumValues({
    "seller.productentry": Model.SELLER_PRODUCTENTRY
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
