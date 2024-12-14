import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/base_seller.dart';
import 'package:oleh_bali_mobile/models/profile_buyer_entry.dart';
import 'package:oleh_bali_mobile/models/profile_seller_entry.dart';
import 'package:oleh_bali_mobile/screens/user_profile/edit_profile.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  _ProfileDetailState createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  dynamic profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final request = context.read<CookieRequest>();
    try {
      // Try buyer endpoint
      try {
        final buyerResponse = await request.get('http://localhost:8000/profile/api/buyer/');
        if (buyerResponse['profile_type'] == 'buyer') {
          profile = ProfileBuyerEntry.fromJson(buyerResponse).profile;
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        // If buyer endpoint fails, continue to try seller endpoint
      }

      // Try seller endpoint
      try {
        final sellerResponse = await request.get('http://localhost:8000/profile/api/seller/');
        if (sellerResponse['profile_type'] == 'seller') {
          profile = ProfileSellerEntry.fromJson(sellerResponse).profile;
        }
      } catch (e) {
        // Handle seller endpoint error
      }
    } catch (e) {
      // Handle any other errors
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return profile is ProfileSeller
        ? BaseSeller(
            appBar: AppBar(
              title: const Text('Profile Detail'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updatedProfile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(profile: profile),
                      ),
                    );
                    if (updatedProfile != null) {
                      setState(() {
                        profile = updatedProfile;
                      });
                    }
                  },
                ),
              ],
            ),
            currentIndex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profile.profilePicture),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      profile.userName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Store Name: ${profile.storeName}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
                  // Add more fields as necessary
                ],
              ),
            ),
          )
        : profile is ProfileBuyer
            ? BaseBuyer(
                appBar: AppBar(
                  title: const Text('Profile Detail'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updatedProfile = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(profile: profile),
                          ),
                        );
                        if (updatedProfile != null) {
                          setState(() {
                            profile = updatedProfile;
                          });
                        }
                      },
                    ),
                  ],
                ),
                currentIndex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profile.profilePicture),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          profile.userName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Store Name: ${profile.storeName}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nationality: ${profile.nationality}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      // Add more fields as necessary
                    ],
                  ),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: const Text('Profile Detail'),
                ),
                body: const Center(
                  child: Text('Unknown profile type'),
                ),
              );
  }
}
