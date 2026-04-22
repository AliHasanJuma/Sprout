import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/store_model.dart';
import '../onboarding/handoff_method_page.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';

class EditHandoffMethodPage extends StatelessWidget {
  const EditHandoffMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreModel?>(
      future: SellerService().getMyStore(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            appBar: SellerAppBar(title: 'Edit handoff method'),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return HandoffMethodPage(draft: snapshot.data!, isEditing: true);
      },
    );
  }
}
