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

  // Add new state variables for dropdown data
  Map<String, String> nationalities = {};
  Map<String, String> subdistricts = {};
  Map<String, String> villages = {};

  // Add variables for selected values
  String? selectedNationality;
  String? selectedSubdistrict;
  String? selectedVillage;

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
      selectedNationality = widget.profile.nationality;
    } else if (widget.profile is ProfileSeller) {
      _cityController = TextEditingController(text: widget.profile.city);
      _subdistrictController =
          TextEditingController(text: widget.profile.subdistrict);
      _villageController = TextEditingController(text: widget.profile.village);
      _addressController = TextEditingController(text: widget.profile.address);
      _mapsController = TextEditingController(text: widget.profile.maps);
      selectedSubdistrict = widget.profile.subdistrict;
      selectedVillage = widget.profile.village;
    }

    // Fetch dropdown data
    fetchDataDropdown();
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

  Future<void> fetchDataDropdown() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/profile/api/edit/choices/');

    setState(() {
      nationalities = Map<String, String>.from(response['nationalities']);
      subdistricts = Map<String, String>.from(response['subdistricts']);
      villages = Map<String, String>.from(response['villages']);
    });
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedNationality,
                  decoration: const InputDecoration(labelText: 'Nationality'),
                  items: nationalities.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedNationality = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your nationality';
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
                DropdownButtonFormField<String>(
                  value: selectedSubdistrict,
                  decoration: const InputDecoration(labelText: 'Subdistrict'),
                  items: subdistricts.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedSubdistrict = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your subdistrict';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedVillage,
                  decoration: const InputDecoration(labelText: 'Village'),
                  items: villages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedVillage = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your village';
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
                            'nationality': selectedNationality,
                          if (widget.profile is ProfileSeller) ...{
                            'city': _cityController.text,
                            'subdistrict': selectedSubdistrict,
                            'village': selectedVillage,
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
