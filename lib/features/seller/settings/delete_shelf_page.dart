import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/shelf_model.dart';
import '../services/shelf_service.dart';
import '../widgets/seller_app_bar.dart';

class DeleteShelfPage extends StatefulWidget {
  const DeleteShelfPage({super.key});

  @override
  State<DeleteShelfPage> createState() => _DeleteShelfPageState();
}

class _DeleteShelfPageState extends State<DeleteShelfPage> {
  List<ShelfModel> _shelves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shelves = await ShelfService().getMyShelves();
    if (!mounted) return;
    setState(() {
      _shelves = shelves;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(ShelfModel shelf) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete this shelf?',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        content: Text(
          'This will permanently remove "${shelf.name}" from your store. This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 14,
            color: Color(0xFF6B6B6B),
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              overlayColor: const Color.fromARGB(255, 182, 182, 182),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(
              overlayColor: const Color.fromARGB(255, 190, 190, 190),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD64545),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || shelf.id == null) return;

    await ShelfService().deleteShelf(shelf.id!);
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SellerAppBar(title: 'Delete a shelf'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _shelves.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'You have no shelves to delete.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 14,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  itemCount: _shelves.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _DeleteShelfRow(
                    shelf: _shelves[i],
                    onDelete: () => _confirmDelete(_shelves[i]),
                  ),
                ),
    );
  }
}

class _DeleteShelfRow extends StatelessWidget {
  final ShelfModel shelf;
  final VoidCallback onDelete;

  const _DeleteShelfRow({required this.shelf, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = shelf.photoPaths.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? (shelf.photoPaths.first.startsWith('http')
                    ? Image.network(
                        shelf.photoPaths.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const SizedBox.shrink(),
                      )
                    : Image.file(
                        File(shelf.photoPaths.first),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const SizedBox.shrink(),
                      ))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelf.name,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shelf.price.toStringAsFixed(shelf.price.truncateToDouble() == shelf.price ? 1 : 2)} BD',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/UI icons package/PNG/Black/Interface/Trash_Empty.png',
                width: 18,
                height: 18,
                color: const Color(0xFFD64545),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
