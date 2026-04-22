import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/shelf_model.dart';
import '../services/shelf_service.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_tag_chip.dart';
import 'shelf_success_page.dart';

class RefineShelfPage extends StatefulWidget {
  final ShelfModel draft;
  final bool isEditing;

  const RefineShelfPage({super.key, required this.draft, this.isEditing = false});

  @override
  State<RefineShelfPage> createState() => _RefineShelfPageState();
}

class _RefineShelfPageState extends State<RefineShelfPage> {
  late List<String> _ingredients;
  late List<_SizeRow> _sizeRows;
  late List<_AddOnRow> _addOnRows;
  bool _addingIngredient = false;
  final TextEditingController _newIngredientController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.draft.ingredients);
    _sizeRows = widget.draft.sizes
        .map((s) => _SizeRow(size: s.size, price: s.priceModifier.toString()))
        .toList();
    _addOnRows = widget.draft.addOns
        .map((a) => _AddOnRow(name: a.name, price: a.priceModifier.toString()))
        .toList();
  }

  @override
  void dispose() {
    _newIngredientController.dispose();
    for (final r in _sizeRows) {
      r.sizeController.dispose();
      r.priceController.dispose();
    }
    for (final r in _addOnRows) {
      r.nameController.dispose();
      r.priceController.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    final v = _newIngredientController.text.trim();
    if (v.isEmpty) {
      setState(() => _addingIngredient = false);
      return;
    }
    setState(() {
      _ingredients.add(v);
      _newIngredientController.clear();
      _addingIngredient = false;
    });
  }

  Future<void> _handleContinue() async {
    if (_submitting) return;

    final sizes = _sizeRows
        .where((r) =>
            r.sizeController.text.trim().isNotEmpty &&
            double.tryParse(r.priceController.text.trim()) != null)
        .map((r) => SizeOption(
              size: r.sizeController.text.trim(),
              priceModifier: double.parse(r.priceController.text.trim()),
            ))
        .toList();

    final addOns = _addOnRows
        .where((r) =>
            r.nameController.text.trim().isNotEmpty &&
            double.tryParse(r.priceController.text.trim()) != null)
        .map((r) => AddOnOption(
              name: r.nameController.text.trim(),
              priceModifier: double.parse(r.priceController.text.trim()),
            ))
        .toList();

    final finalShelf = widget.draft.copyWith(
      ingredients: _ingredients,
      sizes: sizes,
      addOns: addOns,
    );

    setState(() => _submitting = true);

    if (widget.isEditing) {
      await ShelfService().updateShelf(finalShelf);
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    await ShelfService().createShelf(finalShelf);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ShelfSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        title: widget.isEditing ? 'Refine your shelf' : 'Refine your shelf',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'ingredients',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < _ingredients.length; i++)
                    SellerTagChip(
                      label: _ingredients[i],
                      onRemove: () {
                        setState(() => _ingredients.removeAt(i));
                      },
                    ),
                ],
              ),
              if (_ingredients.isNotEmpty) const SizedBox(height: 12),
              if (_addingIngredient)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newIngredientController,
                          autofocus: true,
                          onSubmitted: (_) => _addIngredient(),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter an ingredient',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _addIngredient,
                        child: const Icon(Icons.check, color: AppColors.secondary),
                      ),
                    ],
                  ),
                )
              else
                _AddAction(
                  label: 'Add an ingredient',
                  onTap: () => setState(() => _addingIngredient = true),
                ),
              const SizedBox(height: 28),
              const Text(
                'Product Sizes',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < _sizeRows.length; i++) ...[
                _PairedRow(
                  leftController: _sizeRows[i].sizeController,
                  leftHint: 'Enter a size',
                  rightController: _sizeRows[i].priceController,
                  rightHint: 'Price',
                  showPricePrefix: true,
                  onRemove: () {
                    setState(() {
                      _sizeRows[i].dispose();
                      _sizeRows.removeAt(i);
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
              _AddAction(
                label: 'Add a new size',
                onTap: () => setState(() => _sizeRows.add(_SizeRow())),
              ),
              const SizedBox(height: 28),
              const Text(
                'Product Add-ons',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < _addOnRows.length; i++) ...[
                _PairedRow(
                  leftController: _addOnRows[i].nameController,
                  leftHint: 'Enter Add-on name',
                  rightController: _addOnRows[i].priceController,
                  rightHint: 'Price',
                  showPricePrefix: true,
                  onRemove: () {
                    setState(() {
                      _addOnRows[i].dispose();
                      _addOnRows.removeAt(i);
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
              _AddAction(
                label: 'Add a new add-on',
                onTap: () => setState(() => _addOnRows.add(_AddOnRow())),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: widget.isEditing
                    ? (_submitting ? 'Saving...' : 'Save changes')
                    : (_submitting ? 'Publishing...' : 'Continue'),
                onPressed: _submitting ? null : _handleContinue,
                backgroundColor: AppColors.primary,
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

class _SizeRow {
  final TextEditingController sizeController;
  final TextEditingController priceController;

  _SizeRow({String size = '', String price = ''})
      : sizeController = TextEditingController(text: size),
        priceController = TextEditingController(text: price);

  void dispose() {
    sizeController.dispose();
    priceController.dispose();
  }
}

class _AddOnRow {
  final TextEditingController nameController;
  final TextEditingController priceController;

  _AddOnRow({String name = '', String price = ''})
      : nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price);

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class _PairedRow extends StatelessWidget {
  final TextEditingController leftController;
  final String leftHint;
  final TextEditingController rightController;
  final String rightHint;
  final bool showPricePrefix;
  final VoidCallback onRemove;

  const _PairedRow({
    required this.leftController,
    required this.leftHint,
    required this.rightController,
    required this.rightHint,
    required this.showPricePrefix,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = InputDecoration(
      hintStyle: const TextStyle(
        fontFamily: 'SF Pro Display',
        color: Color(0xFFC3C3C3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: leftController,
            style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14),
            decoration: fieldDecoration.copyWith(hintText: leftHint),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: rightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14),
            decoration: fieldDecoration.copyWith(
              hintText: rightHint,
              prefixIcon: showPricePrefix
                  ? const Padding(
                      padding: EdgeInsets.only(left: 14, right: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0,
                        child: Text(
                          '+ BD',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    )
                  : null,
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 0),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, color: Color(0xFF9F9F9F), size: 20),
        ),
      ],
    );
  }
}

class _AddAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Image.asset(
            'assets/UI icons package/PNG/Black/Edit/Add_Plus_Square.png',
            width: 22,
            height: 22,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
