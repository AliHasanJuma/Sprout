import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/store_model.dart';
import '../onboarding/customize_store_page.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';

class EditLogoBannerPage extends StatelessWidget {
  const EditLogoBannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreModel?>(
      future: SellerService().getMyStore(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            appBar: SellerAppBar(title: 'Edit store logo and banner'),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return CustomizeStorePage(draft: snapshot.data!, isEditing: true);
      },
    );
  }
}
