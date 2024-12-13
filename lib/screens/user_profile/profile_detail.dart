import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/profile_buyer_entry.dart';
import 'package:oleh_bali_mobile/models/profile_seller_entry.dart';

class ProfileDetail extends StatelessWidget {
  final dynamic profile;

  const ProfileDetail({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profile.profilePicture),
            ),
            const SizedBox(height: 16),
            if (profile is ProfileBuyer) ...[
              Text(
                'Store Name: ${profile.storeName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Nationality: ${profile.nationality}',
                style: const TextStyle(fontSize: 16),
              ),
            ] else if (profile is ProfileSeller) ...[
              Text(
                'Store Name: ${profile.storeName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'City: ${profile.city}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Subdistrict: ${profile.subdistrict}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Village: ${profile.village}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Address: ${profile.address}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Maps: ${profile.maps}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            // Add more fields as necessary
          ],
        ),
      ),
    );
  }
}
