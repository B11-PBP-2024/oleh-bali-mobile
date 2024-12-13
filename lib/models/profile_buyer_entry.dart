// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ProfileBuyerEntry welcomeBuyerFromJson(String str) => ProfileBuyerEntry.fromJson(json.decode(str));

String welcomeBuyerToJson(ProfileBuyerEntry data) => json.encode(data.toJson());

class ProfileBuyerEntry {
    String profileType;
    ProfileBuyer profile;

    ProfileBuyerEntry({
        required this.profileType,
        required this.profile,
    });

    factory ProfileBuyerEntry.fromJson(Map<String, dynamic> json) => ProfileBuyerEntry(
        profileType: json["profile_type"],
        profile: ProfileBuyer.fromJson(json["profile"]),
    );

    Map<String, dynamic> toJson() => {
        "profile_type": profileType,
        "profile": profile.toJson(),
    };
}

class ProfileBuyer {
    String storeName;
    String nationality;
    String profilePicture;

    ProfileBuyer({
        required this.storeName,
        required this.nationality,
        required this.profilePicture,
    });

    factory ProfileBuyer.fromJson(Map<String, dynamic> json) => ProfileBuyer(
        storeName: json["store_name"],
        nationality: json["nationality"],
        profilePicture: json["profile_picture"],
    );

    Map<String, dynamic> toJson() => {
        "store_name": storeName,
        "nationality": nationality,
        "profile_picture": profilePicture,
    };
}
