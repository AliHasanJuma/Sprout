// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/temp_data.dart';
import '../features/auth/welcome_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  void _signOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
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

            const SizedBox(height: 60), // space for overlapping avatar

            // ── Form fields ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First name
                  _buildLabel('First name'),
                  const SizedBox(height: 8),
                  _buildTextField(_firstNameCtrl),

                  const SizedBox(height: 20),

                  // Last name
                  _buildLabel('Last name'),
                  const SizedBox(height: 8),
                  _buildTextField(_lastNameCtrl),

                  const SizedBox(height: 20),

                  // Gender
                  _buildLabel('Gender'),
                  const SizedBox(height: 8),
                  _buildGenderToggle(),

                  const SizedBox(height: 20),

                  // Phone number
                  _buildLabel('phone number'),
                  const SizedBox(height: 8),
                  _buildPhoneField(),

                  const SizedBox(height: 20),

                  // Email
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildTextField(_emailCtrl, readOnly: true),

                  const SizedBox(height: 40),

                  // Sign Out
                  Center(
                    child: GestureDetector(
                      onTap: _signOut,
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Bow-shaped lime green background ──
          ClipPath(
            clipper: _BowClipper(),
            child: Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFFCDEB45),
            ),
          ),

          // ── Back button ──
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

          // ── Profile avatar (centered, overlapping) ──
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
          // Country code
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
          // Vertical divider
          Container(
            width: 1,
            height: 28,
            color: const Color(0xFFDEDEDE),
          ),
          // Phone number
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

// ── Bow clipper (same as home_page.dart) ────────────────────────────────────
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
      size.width / 2, controlY,
      size.width, size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BowClipper oldClipper) => false;
}
