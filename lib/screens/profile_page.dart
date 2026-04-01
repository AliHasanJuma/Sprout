import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../data/temp_data.dart';
import '../features/auth/welcome_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _location = '';
  double? _latitude;
  double? _longitude;

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _displayName => _user?.displayName ?? 'User';
  String get _email => _user?.email ?? tempUserProfile.email;

  // ── Sign Out Bottom Sheet ──
  void _showSignOutSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to sign out?',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Out button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDEDEDE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete Account Bottom Sheet ──
  void _showDeleteAccountSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await FirebaseAuth.instance.currentUser?.delete();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to delete account: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDEDEDE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Location Bottom Sheet ──
  void _showLocationSheet() {
    final locationCtrl = TextEditingController(text: _location);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.location_on,
                      color: Color(0xFF003E3B), size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'Update Location',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Location text field
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
                            controller: locationCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter city or tap to detect',
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
                          onTap: isLoading
                              ? null
                              : () async {
                                  setSheetState(() => isLoading = true);
                                  try {
                                    LocationPermission permission =
                                        await Geolocator.checkPermission();
                                    if (permission ==
                                        LocationPermission.denied) {
                                      permission =
                                          await Geolocator.requestPermission();
                                    }
                                    if (permission ==
                                            LocationPermission.denied ||
                                        permission ==
                                            LocationPermission
                                                .deniedForever) {
                                      setSheetState(() => isLoading = false);
                                      return;
                                    }
                                    final position =
                                        await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.high,
                                    );
                                    _latitude = position.latitude;
                                    _longitude = position.longitude;
                                    final placemarks =
                                        await placemarkFromCoordinates(
                                      position.latitude,
                                      position.longitude,
                                    );
                                    if (placemarks.isNotEmpty) {
                                      final place = placemarks.first;
                                      final city = place.locality ??
                                          place.subAdministrativeArea ??
                                          '';
                                      final country = place.country ?? '';
                                      locationCtrl.text = [city, country]
                                          .where((s) => s.isNotEmpty)
                                          .join(', ');
                                    }
                                  } catch (_) {}
                                  setSheetState(() => isLoading = false);
                                },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF003E3B),
                                    ),
                                  )
                                : const Icon(Icons.my_location,
                                    color: Color(0xFF003E3B), size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _location = locationCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Language Bottom Sheet ──
  void _showLanguageSheet() {
    final languages = ['English', 'العربية'];
    String selected = 'English';

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...languages.map((lang) => ListTile(
                        title: Text(
                          lang,
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 16,
                          ),
                        ),
                        trailing: lang == 'العربية'
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Soon',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 12,
                                    color: Color(0xFF9F9F9F),
                                  ),
                                ),
                              )
                            : selected == lang
                                ? const Icon(Icons.check_circle,
                                    color: Color(0xFF003E3B))
                                : null,
                        onTap: () {
                          if (lang == 'العربية') {
                            Navigator.pop(ctx);
                            _showArabicNotSupportedSheet();
                          } else {
                            setSheetState(() => selected = lang);
                            Navigator.pop(ctx);
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Coming Soon Sheet ──
  void _showComingSoonSheet({required String feature, required IconData icon}) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F7FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF003E3B), size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  '$feature Coming Soon',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$feature is not available yet. Stay tuned — it\'s on its way in a future update.',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Arabic Not Supported Sheet ──
  void _showArabicNotSupportedSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F7FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.language,
                      color: Color(0xFF003E3B), size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Arabic Coming Soon',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arabic is not supported yet. We\'re working on it and it will be available in a future update.',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Feedback Bottom Sheet ──
  void _showFeedbackSheet() {
    final feedbackCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Feedback',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'d love to hear your thoughts!',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                  ),
                  child: TextField(
                    controller: feedbackCtrl,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Type your feedback here...',
                      hintStyle: TextStyle(color: Color(0xFFC3C3C3)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Thank you for your feedback!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Wave header with avatar ──
            _buildHeader(),

            const SizedBox(height: 16),

            // ── Display name + email ──
            Center(
              child: Column(
                children: [
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 14,
                      color: Color(0xFF9F9F9F),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Section: Account ──
            _buildSectionTitle('Account'),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.person_outline,
                title: 'Personal details',
                onTap: () => _openPersonalDetails(),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.location_on_outlined,
                title: 'Location',
                trailing: _location.isNotEmpty ? _location : null,
                onTap: _showLocationSheet,
              ),
            ]),

            const SizedBox(height: 20),

            // ── Section: Preferences ──
            _buildSectionTitle('Preferences'),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.language,
                title: 'Language',
                trailing: 'English',
                onTap: _showLanguageSheet,
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => _showComingSoonSheet(
                    feature: 'Notifications',
                    icon: Icons.notifications_outlined),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Section: Support & Legal ──
            _buildSectionTitle('Support & Legal'),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.star_outline,
                title: 'Rate us',
                onTap: () => _showComingSoonSheet(
                    feature: 'Rate us', icon: Icons.star_outline),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.verified_user_outlined,
                title: 'Privacy Policy',
                onTap: () => _showComingSoonSheet(
                    feature: 'Privacy Policy',
                    icon: Icons.verified_user_outlined),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.description_outlined,
                title: 'Terms of Use',
                onTap: () => _showComingSoonSheet(
                    feature: 'Terms of Use',
                    icon: Icons.description_outlined),
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.mail_outline,
                title: 'Feedback',
                onTap: _showFeedbackSheet,
              ),
            ]),

            const SizedBox(height: 20),

            // ── Section: Danger Zone ──
            _buildSectionTitle('Danger Zone'),
            _buildSettingsCard([
              _buildSettingsRow(
                icon: Icons.delete_outline,
                title: 'Delete account',
                titleColor: const Color(0xFFEF4444),
                iconColor: const Color(0xFFEF4444),
                onTap: _showDeleteAccountSheet,
              ),
              _buildDivider(),
              _buildSettingsRow(
                icon: Icons.logout,
                title: 'Logout',
                titleColor: const Color(0xFFEF4444),
                iconColor: const Color(0xFFEF4444),
                onTap: _showSignOutSheet,
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _openPersonalDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PersonalDetailsPage()),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _BowClipper(),
            child: Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFFCDEB45),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Color(0xFF003E3B), size: 20),
              ),
            ),
          ),
          // Bigger, centered profile avatar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/icons/Profile_picture.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9F9F9F),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    String? trailing,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF003E3B), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                color: titleColor ?? const Color(0xFF9F9F9F), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
    );
  }
}

// ── Personal Details Page ──
class _PersonalDetailsPage extends StatefulWidget {
  const _PersonalDetailsPage();

  @override
  State<_PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<_PersonalDetailsPage> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCodeCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  String _selectedGender = tempUserProfile.gender;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: tempUserProfile.firstName);
    _lastNameCtrl = TextEditingController(text: tempUserProfile.lastName);
    _phoneCodeCtrl =
        TextEditingController(text: tempUserProfile.phoneCountryCode);
    _phoneCtrl = TextEditingController(text: tempUserProfile.phoneNumber);
    _emailCtrl = TextEditingController(text: tempUserProfile.email);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildLabel('First name'),
              const SizedBox(height: 8),
              _buildTextField(_firstNameCtrl),
              const SizedBox(height: 20),
              _buildLabel('Last name'),
              const SizedBox(height: 8),
              _buildTextField(_lastNameCtrl),
              const SizedBox(height: 20),
              _buildLabel('Gender'),
              const SizedBox(height: 8),
              _buildGenderToggle(),
              const SizedBox(height: 20),
              _buildLabel('Phone number'),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(_emailCtrl, readOnly: true),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: Color(0xFF003E3B),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {bool readOnly = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF0F0F0) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 16,
          color: readOnly ? const Color(0xFF9F9F9F) : Colors.black,
        ),
      ),
    );
  }

  Widget _buildGenderToggle() {
    return Row(
      children: [
        _buildGenderButton('Male'),
        const SizedBox(width: 16),
        _buildGenderButton('Female'),
      ],
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFCDEB45)
                  : const Color(0xFFDEDEDE),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              gender,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                color: isSelected ? Colors.black : const Color(0xFF9F9F9F),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: TextField(
              controller: _phoneCodeCtrl,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFDEDEDE)),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bow clipper ──
class _BowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double svgHeight = 274.0;
    const double svgPeakDepth = 51.8;
    final double controlY =
        size.height - (size.height * (svgPeakDepth / svgHeight) * 2);

    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      controlY,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BowClipper oldClipper) => false;
}
