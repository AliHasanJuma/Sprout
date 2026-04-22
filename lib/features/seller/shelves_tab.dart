import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'models/store_model.dart';
import 'onboarding/become_a_seller_page.dart';
import 'services/seller_service.dart';
import 'store/seller_store_page.dart';

class SellerReloadNotification extends Notification {}

class ShelvesTab extends StatefulWidget {
  const ShelvesTab({super.key});

  @override
  State<ShelvesTab> createState() => _ShelvesTabState();
}

class _ShelvesTabState extends State<ShelvesTab> {
  late Future<StoreModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = SellerService().getMyStore();
  }

  void _reload() {
    setState(() {
      _future = SellerService().getMyStore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SellerReloadNotification>(
      onNotification: (_) {
        _reload();
        return true;
      },
      child: FutureBuilder<StoreModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final store = snapshot.data;
          if (store == null) {
            return const BecomeASellerPage();
          }
          return SellerStorePage(store: store);
        },
      ),
    );
  }
}
