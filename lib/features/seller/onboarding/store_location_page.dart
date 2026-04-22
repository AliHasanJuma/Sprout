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
  bool _loadingProfile = true;
  bool _detecting = false;

  @override
  void initState() {
    super.initState();
    _locationController.addListener(() => setState(() {}));
    _bootstrapLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapLocation() async {
    // If a store already has a location (edit mode / draft already has one), use that.
    final existing = widget.draft.location;
    if (existing != null && existing.address.isNotEmpty) {
      _locationController.text = existing.address;
      _latitude = existing.lat;
      _longitude = existing.lng;
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }

    // Otherwise fall back to the buyer profile written at sign-up.
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = snap.data();
        if (data != null) {
          final address = data['location'] as String?;
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();
          if (address != null && address.isNotEmpty) {
            _locationController.text = address;
            _latitude = lat;
            _longitude = lng;
          }
        }
      }
    } catch (_) {
      // Silent fallback — user can still tap the crosshair or type manually.
    }

    if (mounted) setState(() => _loadingProfile = false);
  }

  Future<void> _detectLocation() async {
    setState(() => _detecting = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack('Location permission denied');
          if (mounted) setState(() => _detecting = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Location permission permanently denied. Enable it in Settings.');
        if (mounted) setState(() => _detecting = false);
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
        final text = [city, country].where((s) => s.isNotEmpty).join(', ');
        _locationController.text = text;
      }
    } catch (_) {
      _snack('Could not detect location. Please enter it manually.');
    }

    if (mounted) setState(() => _detecting = false);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _canContinue => _locationController.text.trim().isNotEmpty;

  Future<void> _handleContinue() async {
    final address = _locationController.text.trim();
    if (address.isEmpty) return;

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
      appBar: SellerAppBar(
        title: widget.isEditing ? 'Edit store location' : 'store Location',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
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
              // TODO: replace with real map (Google Maps / Mapbox) integration.
              _MapPlaceholder(hasPin: _latitude != null && _longitude != null),
              const SizedBox(height: 24),
              _LocationInput(
                controller: _locationController,
                onCrosshairTap: _detecting ? null : _detectLocation,
                detecting: _detecting,
                loading: _loadingProfile,
              ),
              const SizedBox(height: 72),
              CustomButton(
                text: widget.isEditing ? 'Save changes' : 'Continue',
                onPressed: _canContinue ? _handleContinue : null,
                backgroundColor: _canContinue
                    ? AppColors.primary
                    : const Color(0xFFE5E5E5),
                textColor: Colors.black,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final bool hasPin;
  const _MapPlaceholder({required this.hasPin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _FakeStreetsPainter()),
          ),
          if (hasPin)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 22,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB7D9B5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FakeStreetsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.15),
      Offset(size.width * 0.95, size.height * 0.15),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.0, size.height * 0.45),
      Offset(size.width * 1.0, size.height * 0.50),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.0, size.height * 0.80),
      Offset(size.width * 1.0, size.height * 0.75),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.0),
      Offset(size.width * 0.20, size.height * 1.0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.0),
      Offset(size.width * 0.65, size.height * 1.0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.0),
      Offset(size.width * 0.88, size.height * 1.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onCrosshairTap;
  final bool detecting;
  final bool loading;

  const _LocationInput({
    required this.controller,
    required this.onCrosshairTap,
    required this.detecting,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: !loading,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: loading ? 'Loading your location...' : 'Choose your location',
        hintStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          color: Color(0xFFC3C3C3),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: GestureDetector(
          onTap: onCrosshairTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: detecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  )
                : Image.asset(
                    'assets/UI icons package/PNG/Black/Navigation/Navigation.png',
                    width: 20,
                    height: 20,
                    color: AppColors.secondary,
                  ),
          ),
        ),
      ),
    );
  }
}
