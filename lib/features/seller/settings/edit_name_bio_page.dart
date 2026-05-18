import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ── ADDED CLOUD FIRESTORE ──

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../models/store_model.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';

class EditNameBioPage extends StatelessWidget {
  const EditNameBioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreModel?>(
      future: SellerService().getMyStore(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            appBar: SellerAppBar(title: 'Edit name and bio'),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return _EditNameBioForm(store: snapshot.data!);
      },
    );
  }
}

class _EditNameBioForm extends StatefulWidget {
  final StoreModel store;
  const _EditNameBioForm({required this.store});

  @override
  State<_EditNameBioForm> createState() => _EditNameBioFormState();
}

class _EditNameBioFormState extends State<_EditNameBioForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store.name);
    _bioController = TextEditingController(text: widget.store.bio);
    _nameController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _bioController.text.trim().isNotEmpty &&
      !_submitting;

  Future<void> _save() async {
    if (!_canSave) return;
    
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();
    
    setState(() => _submitting = true);

    // ── 1. ONLY CHECK DB IF THEY LOGICALLY CHANGED THEIR SHOP NAME ──
    if (newName.toLowerCase() != widget.store.name.toLowerCase()) {
      try {
        final nameCheck = await FirebaseFirestore.instance
            .collection('stores')
            .where('name', isEqualTo: newName)
            .limit(1)
            .get();

        if (nameCheck.docs.isNotEmpty) {
          setState(() => _submitting = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('The shop name "$newName" is already taken. Please choose another!'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return; // 🛑 Halt execution here
        }
      } catch (e) {
        setState(() => _submitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking name availability: $e')),
          );
        }
        return;
      }
    }

    // ── 2. PROCEED TO UPDATE RECORD IF UNIQUE OR UNCHANGED ──
    try {
      final updated = widget.store.copyWith(
        name: newName,
        bio: newBio,
      );
      await SellerService().updateStore(updated);
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update shop changes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SellerAppBar(title: 'Edit name and bio'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: AbsorbPointer(
            absorbing: _submitting, // ── CRASH PROTECTION: Freezes text fields while validation query runs ──
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Shop Name',
                  hintText: 'Enter your shop name',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Short Bio',
                  hintText: 'Enter a short and catchy Bio',
                  controller: _bioController,
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: _submitting ? 'Checking availability...' : 'Save changes',
                  onPressed: _canSave ? _save : null,
                  backgroundColor: _canSave
                      ? AppColors.primary
                      : const Color(0xFFE5E5E5),
                  textColor: Colors.black,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}