import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/store_model.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_select_card.dart';
import 'seller_success_page.dart';

class HandoffMethodPage extends StatefulWidget {
  final StoreModel draft;
  final bool isEditing;

  const HandoffMethodPage({
    super.key,
    required this.draft,
    this.isEditing = false,
  });

  @override
  State<HandoffMethodPage> createState() => _HandoffMethodPageState();
}

class _HandoffMethodPageState extends State<HandoffMethodPage> {
  late final Set<HandoffMethod> _selected;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.draft.handoffMethods.toSet();
  }

  void _toggle(HandoffMethod method) {
    setState(() {
      if (_selected.contains(method)) {
        _selected.remove(method);
      } else {
        _selected.add(method);
      }
    });
  }

  // ── UPDATED: ADDED TRY/CATCH TO PREVENT SILENT CRASHES ──
  Future<void> _handleContinue() async {
    if (_selected.isEmpty || _submitting) return;

    final updated = widget.draft.copyWith(handoffMethods: _selected.toList());

    setState(() => _submitting = true);

    try {
      if (widget.isEditing) {
        await SellerService().updateStore(updated);
        if (!mounted) return;
        Navigator.pop(context, updated);
        return;
      }

      await SellerService().createStore(updated);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerSuccessPage()),
      );
    } catch (e) {
      // ── THIS CATCHES FIREBASE PERMISSION OR NETWORK ERRORS ──
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.isNotEmpty && !_submitting;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        title: widget.isEditing ? 'Edit handoff method' : 'Finalizing your Store',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Pick a handoff method',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'These Settings can be updated anytime and you can also coordinate custom handoffs via chat.',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9F9F9F),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SellerSelectCard(
                iconAsset: 'assets/Becpme a seller icons/Customer Pickup.svg',
                title: 'Customer Pickup',
                description: 'Buyers collect their orders directly from your location.',
                selected: _selected.contains(HandoffMethod.customerPickup),
                onTap: () => _toggle(HandoffMethod.customerPickup),
              ),
              const SizedBox(height: 14),
              SellerSelectCard(
                iconAsset: 'assets/Becpme a seller icons/Local Delivery.svg',
                title: 'Local Delivery',
                description: 'You personally drop off orders to buyers in your area.',
                selected: _selected.contains(HandoffMethod.localDelivery),
                onTap: () => _toggle(HandoffMethod.localDelivery),
              ),
              const SizedBox(height: 14),
              SellerSelectCard(
                iconAsset: 'assets/Becpme a seller icons/Public Meetup.svg',
                title: 'Public Meetup',
                description: 'Meet in a safe, public place to exchange the order.',
                selected: _selected.contains(HandoffMethod.publicMeetup),
                onTap: () => _toggle(HandoffMethod.publicMeetup),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: widget.isEditing
                    ? 'Save changes'
                    : (_submitting ? 'Creating...' : 'Continue'),
                onPressed: canContinue ? _handleContinue : null,
                backgroundColor: canContinue
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