import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
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
  User? get _user => FirebaseAuth.instance.currentUser;

  // ── Sign Out Bottom Sheet (Unchanged) ──
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
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                  child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 28),
                ),
                const SizedBox(height: 16),
                const Text('Sign Out', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 14, color: Color(0xFF9F9F9F))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text('Sign Out', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDEDEDE)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete Account Bottom Sheet (Unchanged) ──
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_forever, color: Color(0xFFEF4444), size: 28),
                ),
                const SizedBox(height: 16),
                const Text('Delete Account', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('This action cannot be undone.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 14, color: Color(0xFF9F9F9F))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await FirebaseFirestore.instance.collection('users').doc(_user?.uid).delete();
                        await FirebaseAuth.instance.currentUser?.delete();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${e.toString()}')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                    child: const Text('Delete Account', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFDEDEDE)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('Cancel', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Coming Soon Sheet (Unchanged) ──
  void _showComingSoonSheet({required String feature, required IconData icon}) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFF0F7FF), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF003E3B), size: 28)),
                const SizedBox(height: 16),
                Text('$feature Coming Soon', style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('This feature will be available in a future update.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 14, color: Color(0xFF9F9F9F))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
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
      // ── DYNAMIC USER STREAM ──
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          String firstName = userData['firstName'] ?? 'User';
          String lastName = userData['lastName'] ?? '';
          String email = _user?.email ?? userData['email'] ?? '';
          String location = userData['location'] ?? 'Location not set';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text("$firstName $lastName", style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14, color: Color(0xFF9F9F9F))),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildSectionTitle('Account'),
                _buildSettingsCard([
                  _buildSettingsRow(
                    icon: Icons.person_outline,
                    title: 'Personal details',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _PersonalDetailsPage(userData: userData))),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    trailing: location,
                    onTap: () => _showComingSoonSheet(feature: 'Location Update', icon: Icons.location_on_outlined),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionTitle('Preferences'),
                _buildSettingsCard([
                  _buildSettingsRow(icon: Icons.language, title: 'Language', trailing: 'English', onTap: () {}),
                  _buildDivider(),
                  _buildSettingsRow(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () => _showComingSoonSheet(feature: 'Notifications', icon: Icons.notifications_outlined)),
                ]),
                const SizedBox(height: 20),
                _buildSectionTitle('Danger Zone'),
                _buildSettingsCard([
                  _buildSettingsRow(icon: Icons.delete_outline, title: 'Delete account', titleColor: const Color(0xFFEF4444), iconColor: const Color(0xFFEF4444), onTap: _showDeleteAccountSheet),
                  _buildDivider(),
                  _buildSettingsRow(icon: Icons.logout, title: 'Logout', titleColor: const Color(0xFFEF4444), iconColor: const Color(0xFFEF4444), onTap: _showSignOutSheet),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(clipper: _BowClipper(), child: Container(width: double.infinity, height: 220, color: const Color(0xFFCDEB45))),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, left: 16,
            child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Color(0xFF003E3B), size: 20))),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: Center(child: Container(width: 120, height: 120, decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/icons/Profile_picture.png'), fit: BoxFit.cover))))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(left: 24, bottom: 8), child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF9F9F9F))));
  Widget _buildSettingsCard(List<Widget> children) => Container(margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12)), child: Column(children: children));
  Widget _buildSettingsRow({required IconData icon, required String title, String? trailing, Color? titleColor, Color? iconColor, required VoidCallback onTap}) => GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [Icon(icon, color: iconColor ?? const Color(0xFF003E3B), size: 22), const SizedBox(width: 14), Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor ?? Colors.black))), if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 14, color: Color(0xFF9F9F9F))), const SizedBox(width: 4), Icon(Icons.chevron_right, color: titleColor ?? const Color(0xFF9F9F9F), size: 20)])));
  Widget _buildDivider() => const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: Color(0xFFEEEEEE)));
}

// ── PERSONAL DETAILS PAGE (WITH FIRESTORE SAVE) ──
class _PersonalDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const _PersonalDetailsPage({required this.userData});

  @override
  State<_PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<_PersonalDetailsPage> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late String _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.userData['firstName'] ?? '');
    _lastNameCtrl = TextEditingController(text: widget.userData['lastName'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.userData['phoneNumber'] ?? '');
    _selectedGender = widget.userData['gender'] ?? 'Male';
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'gender': _selectedGender,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B)), onPressed: () => Navigator.pop(context)),
        title: const Text('Personal Details', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save', style: TextStyle(color: Color(0xFF003E3B), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildLabel('First name'),
            _buildTextField(_firstNameCtrl),
            const SizedBox(height: 20),
            _buildLabel('Last name'),
            _buildTextField(_lastNameCtrl),
            const SizedBox(height: 20),
            _buildLabel('Gender'),
            _buildGenderToggle(),
            const SizedBox(height: 20),
            _buildLabel('Phone number'),
            _buildTextField(_phoneCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF003E3B))));
  Widget _buildTextField(TextEditingController controller) => Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFDEDEDE))), child: TextField(controller: controller, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16))));
  Widget _buildGenderToggle() => Row(children: [ _buildGenderButton('Male'), const SizedBox(width: 16), _buildGenderButton('Female')]);
  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedGender = gender), child: Container(height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: isSelected ? const Color(0xFFCDEB45) : const Color(0xFFDEDEDE), width: isSelected ? 2 : 1)), child: Center(child: Text(gender, style: TextStyle(color: isSelected ? Colors.black : const Color(0xFF9F9F9F)))))));
  }
}

class _BowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double svgHeight = 274.0;
    const double svgPeakDepth = 51.8;
    final double controlY = size.height - (size.height * (svgPeakDepth / svgHeight) * 2);
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, controlY, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_BowClipper oldClipper) => false;
}