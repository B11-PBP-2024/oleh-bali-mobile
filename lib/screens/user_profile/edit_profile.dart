import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/profile_buyer_entry.dart';
import 'package:oleh_bali_mobile/models/profile_seller_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final dynamic profile;

  const EditProfile({super.key, required this.profile});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _cityController;
  late TextEditingController _subdistrictController;
  late TextEditingController _villageController;
  late TextEditingController _addressController;
  late TextEditingController _mapsController;
  late TextEditingController _nationalityController;
  late TextEditingController _profilePictureController;

  @override
  void initState() {
    super.initState();
    _profilePictureController =
        TextEditingController(text: widget.profile.profilePicture);
    _storeNameController =
        TextEditingController(text: widget.profile.storeName);
    if (widget.profile is ProfileBuyer) {
      _nationalityController =
          TextEditingController(text: widget.profile.nationality);
    } else if (widget.profile is ProfileSeller) {
      _cityController = TextEditingController(text: widget.profile.city);
      _subdistrictController =
          TextEditingController(text: widget.profile.subdistrict);
      _villageController = TextEditingController(text: widget.profile.village);
      _addressController = TextEditingController(text: widget.profile.address);
      _mapsController = TextEditingController(text: widget.profile.maps);
    }
  }

  @override
  void dispose() {
    _profilePictureController.dispose();
    _storeNameController.dispose();
    if (widget.profile is ProfileBuyer) {
      _nationalityController.dispose();
    } else if (widget.profile is ProfileSeller) {
      _cityController.dispose();
      _subdistrictController.dispose();
      _villageController.dispose();
      _addressController.dispose();
      _mapsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _profilePictureController,
                decoration:
                    const InputDecoration(labelText: 'Profile Picture URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your profile picture URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.profile is ProfileBuyer) ...[
                TextFormField(
                  controller: _nationalityController,
                  decoration: const InputDecoration(labelText: 'Nationality'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your nationality';
                    }
                    return null;
                  },
                ),
              ] else if (widget.profile is ProfileSeller) ...[
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subdistrictController,
                  decoration: const InputDecoration(labelText: 'Subdistrict'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your subdistrict';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _villageController,
                  decoration: const InputDecoration(labelText: 'Village'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your village';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mapsController,
                  decoration: const InputDecoration(labelText: 'Maps'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maps link';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save profile changes
                    final response = await request.postJson(
                      widget.profile is ProfileBuyer
                          ? 'http://localhost:8000/profile/api/buyer/'
                          : 'http://localhost:8000/profile/api/seller/',
                      jsonEncode(
                        {
                          'profile_picture': _profilePictureController.text,
                          'store_name': _storeNameController.text,
                          if (widget.profile is ProfileBuyer)
                            'nationality': _nationalityController.text,
                          if (widget.profile is ProfileSeller) ...{
                            'city': _cityController.text,
                            'subdistrict': _subdistrictController.text,
                            'village': _villageController.text,
                            'address': _addressController.text,
                            'maps': _mapsController.text,
                          },
                        },
                      ),
                    );

                    if (response['statusCode'] == 200) {
                      // Parse the response into a new profile object
                      if (response['profile_type'] == 'buyer') {
                        final newProfile = ProfileBuyer(
                          storeName: response['profile']['store_name'],
                          userName: response['profile']['username'],
                          nationality: response['profile']['nationality'],
                          profilePicture: response['profile']['profile_picture'],
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Profile updated successfully'),
                        ));
                        Navigator.of(context).pop(newProfile);
                      } else if (response['profile_type'] == 'seller') {
                        // Handle seller profile similarly
                        final newProfile = ProfileSeller(
                          storeName: response['profile']['store_name'],
                          userName: response['profile']['username'],
                          city: response['profile']['city'],
                          subdistrict: response['profile']['subdistrict'],
                          village: response['profile']['village'],
                          address: response['profile']['address'],
                          maps: response['profile']['maps'],
                          profilePicture: response['profile']['profile_picture'],
                        );
                        Navigator.of(context).pop(newProfile);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Failed to update profile'),
                      ));
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
