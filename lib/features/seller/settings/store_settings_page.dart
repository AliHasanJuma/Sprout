import 'package:flutter/material.dart';

import '../widgets/seller_app_bar.dart';
import '../widgets/seller_settings_row.dart';
import 'delete_shelf_page.dart';
import 'delete_store_dialog.dart';
import 'edit_category_page.dart';
import 'edit_handoff_method_page.dart';
import 'edit_location_page.dart';
import 'edit_logo_banner_page.dart';
import 'edit_name_bio_page.dart';
import '../shelf/create_shelf_page.dart';

class StoreSettingsPage extends StatelessWidget {
  const StoreSettingsPage({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SellerAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Store settings',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              const _GroupLabel('Store management'),
              const SizedBox(height: 10),
              _Group(
                children: [
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Edit/Edit_Pencil_01.png',
                    label: 'Name and bio',
                    isFirst: true,
                    onTap: () => _go(context, const EditNameBioPage()),
                  ),
                  const _RowDivider(),
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Media/Image_01.png',
                    label: 'Store logo and banner',
                    onTap: () => _go(context, const EditLogoBannerPage()),
                  ),
                  const _RowDivider(),
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Interface/Tag.png',
                    label: 'Category',
                    onTap: () => _go(context, const EditCategoryPage()),
                  ),
                  const _RowDivider(),
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Navigation/Map_Pin.png',
                    label: 'Store Location',
                    onTap: () => _go(context, const EditLocationPage()),
                  ),
                  const _RowDivider(),
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Interface/Shopping_Bag_01.png',
                    label: 'Handoff method',
                    isLast: true,
                    onTap: () => _go(context, const EditHandoffMethodPage()),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _GroupLabel('Shelves management'),
              const SizedBox(height: 10),
              _Group(
                children: [
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Edit/Add_Plus_Square.png',
                    label: 'Add a new shelf',
                    isFirst: true,
                    onTap: () => _go(context, const CreateShelfPage()),
                  ),
                  const _RowDivider(),
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Interface/Trash_Empty.png',
                    label: 'Delete a shelf',
                    labelColor: const Color(0xFFE08A3C),
                    chevronColor: const Color(0xFFE08A3C),
                    isLast: true,
                    onTap: () => _go(context, const DeleteShelfPage()),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _GroupLabel('Danger zone'),
              const SizedBox(height: 10),
              _Group(
                children: [
                  SellerSettingsRow(
                    iconAsset:
                        'assets/UI icons package/PNG/Black/Interface/Trash_Full.png',
                    label: 'Delete Store',
                    labelColor: const Color(0xFFD64545),
                    chevronColor: const Color(0xFFD64545),
                    isFirst: true,
                    isLast: true,
                    onTap: () => showDeleteStoreDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9F9F9F),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 52),
      child: Divider(height: 1, color: Color(0xFFEDEDED)),
    );
  }
}
