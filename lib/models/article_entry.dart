// To parse this JSON data, do
//
//     final articleEntry = articleEntryFromJson(jsonString);

import 'dart:convert';

List<ArticleEntry> articleEntryFromJson(String str) => List<ArticleEntry>.from(json.decode(str).map((x) => ArticleEntry.fromJson(x)));

String articleEntryToJson(List<ArticleEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticleEntry {
    String id;
    String title;
    String img;
    String text;
    String time;
    User user;

    ArticleEntry({
        required this.id,
        required this.title,
        required this.img,
        required this.text,
        required this.time,
        required this.user,
    });

    factory ArticleEntry.fromJson(Map<String, dynamic> json) => ArticleEntry(
        id: json["id"],
        title: json["title"],
        img: json["img"],
        text: json["text"],
        time: json["time"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img": img,
        "text": text,
        "time": time,
        "user": user.toJson(),
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
