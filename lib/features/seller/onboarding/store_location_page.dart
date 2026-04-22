import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/store_model.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';
import 'handoff_method_page.dart';

class StoreLocationPage extends StatefulWidget {
  final StoreModel draft;
  final bool isEditing;

  const StoreLocationPage({
    super.key,
    required this.draft,
    this.isEditing = false,
  });

  @override
  State<StoreLocationPage> createState() => _StoreLocationPageState();
}

class _StoreLocationPageState extends State<StoreLocationPage> {
  final TextEditingController _locationController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _prefillLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _prefillLocation() async {
    final existing = widget.draft.location;
    if (existing != null && existing.address.isNotEmpty) {
      _locationController.text = existing.address;
      _latitude = existing.lat;
      _longitude = existing.lng;
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data();
      if (data == null) return;
      final address = data['location'] as String?;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (address != null && address.isNotEmpty && mounted) {
        setState(() {
          _locationController.text = address;
          _latitude = lat;
          _longitude = lng;
        });
      }
    } catch (_) {
      // Silent — user can still type or tap the crosshair.
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
            'Location permission permanently denied. Please enable it in Settings.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea ?? '';
        final country = place.country ?? '';
        final locationText =
            [city, country].where((s) => s.isNotEmpty).join(', ');
        _locationController.text = locationText;
      }
    } catch (e) {
      _showError('Could not detect location. Please enter manually.');
    }

    if (mounted) setState(() => _isLoadingLocation = false);
  }

  Future<void> _handleContinue() async {
    final address = _locationController.text.trim();
    if (address.isEmpty) {
      _showError('Please enter your store location');
      return;
    }

    final updated = widget.draft.copyWith(
      location: StoreLocation(
        lat: _latitude ?? 0,
        lng: _longitude ?? 0,
        address: address,
      ),
    );

    if (widget.isEditing) {
      await SellerService().updateStore(updated);
      if (mounted) Navigator.pop(context, updated);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HandoffMethodPage(draft: updated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SellerAppBar(title: 'store Location'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                'Confirm your location',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDEDEDE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Choose your location',
                          hintStyle: TextStyle(color: Color(0xFFC3C3C3)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoadingLocation ? null : _detectLocation,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _isLoadingLocation
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF003E3B),
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: Color(0xFF003E3B),
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),

              CustomButton(
                text: 'Continue',
                onPressed: _handleContinue,
                backgroundColor: AppColors.primary,
                textColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
