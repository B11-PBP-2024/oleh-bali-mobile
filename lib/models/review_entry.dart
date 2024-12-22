// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
    String id;
    String time;
    String reviewText;
    String product;
    User user;
    String thisUser;

    ReviewEntry({
        required this.id,
        required this.time,
        required this.reviewText,
        required this.product,
        required this.user,
        required this.thisUser,
    });

    factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        id: json["id"],
        time: json["time"],
        reviewText: json["review_text"],
        product: json["product"],
        user: User.fromJson(json["user"]),
        thisUser: json["thisUser"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "time": time,
        "review_text": reviewText,
        "product": product,
        "user": user.toJson(),
        "thisUser": thisUser,
    };
}

class User {
    String displayname;
    String profilepicture;
    String nationality;

    User({
        required this.displayname,
        required this.profilepicture,
        required this.nationality,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        displayname: json["displayname"],
        profilepicture: json["profilepicture"],
        nationality: json["nationality"],
    );

    Map<String, dynamic> toJson() => {
        "displayname": displayname,
        "profilepicture": profilepicture,
        "nationality": nationality,
    };
}
