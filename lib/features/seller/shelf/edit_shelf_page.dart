import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/shelf_model.dart';
import '../services/shelf_service.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_tag_chip.dart';

class EditShelfPage extends StatefulWidget {
  final ShelfModel shelf;

  const EditShelfPage({super.key, required this.shelf});

  @override
  State<EditShelfPage> createState() => _EditShelfPageState();
}

class _EditShelfPageState extends State<EditShelfPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<File> _photos = [];
  final List<String> _existingPhotoPaths = [];
  PriceType _priceType = PriceType.fixed;

  late List<String> _ingredients;
  late List<_SizeRow> _sizeRows;
  late List<_AddOnRow> _addOnRows;
  bool _addingIngredient = false;
  final TextEditingController _newIngredientController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final shelf = widget.shelf;
    _nameController.text = shelf.name;
    _descriptionController.text = shelf.description;
    _priceController.text = shelf.price.toString();
    _priceType = shelf.priceType;
    _existingPhotoPaths.addAll(shelf.photoPaths);

    _ingredients = List.from(shelf.ingredients);
    _sizeRows = shelf.sizes
        .map((s) => _SizeRow(size: s.size, price: s.priceModifier.toString()))
        .toList();
    _addOnRows = shelf.addOns
        .map((a) => _AddOnRow(name: a.name, price: a.priceModifier.toString()))
        .toList();

    _nameController.addListener(_onChange);
    _descriptionController.addListener(_onChange);
    _priceController.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _newIngredientController.dispose();
    for (final r in _sizeRows) {
      r.dispose();
    }
    for (final r in _addOnRows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photos.add(File(image.path)));
    }
  }

  bool get _canSave {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();
    final hasPhoto = _photos.isNotEmpty || _existingPhotoPaths.isNotEmpty;
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);
    return name.isNotEmpty &&
        desc.isNotEmpty &&
        hasPhoto &&
        price != null &&
        price > 0;
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

  Future<void> _handleSave() async {
    if (!_canSave || _submitting) return;

    final paths = [
      ..._existingPhotoPaths,
      ..._photos.map((f) => f.path),
    ];

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

    final updated = widget.shelf.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      photoPaths: paths,
      priceType: _priceType,
      price: double.parse(_priceController.text.trim()),
      ingredients: _ingredients,
      sizes: sizes,
      addOns: addOns,
    );

    setState(() => _submitting = true);

    await ShelfService().updateShelf(updated);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SellerAppBar(title: 'Shelf settings'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const _FieldLabel('Product name'),
              const SizedBox(height: 8),
              _TextInput(
                controller: _nameController,
                hint: 'Enter your Product name',
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Product description'),
              const SizedBox(height: 8),
              _TextInput(
                controller: _descriptionController,
                hint: 'Enter a Product Description',
              ),
              const SizedBox(height: 24),
              const _FieldLabel('product photos'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 153,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/UI icons package/PNG/Black/File/File_Upload.png',
                        width: 20,
                        height: 20,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload a photo',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_photos.isNotEmpty || _existingPhotoPaths.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final path in _existingPhotoPaths)
                        _PhotoThumb(file: File(path)),
                      for (final file in _photos) _PhotoThumb(file: file),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const _FieldLabel('Set a price'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PriceRadio(
                      selected: _priceType == PriceType.fixed,
                      label: 'Fixed price',
                      onTap: () => setState(() => _priceType = PriceType.fixed),
                    ),
                  ),
                  Expanded(
                    child: _PriceRadio(
                      selected: _priceType == PriceType.startingAt,
                      label: 'Starting at',
                      onTap: () =>
                          setState(() => _priceType = PriceType.startingAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PriceInput(controller: _priceController),
              const SizedBox(height: 28),
              const _FieldLabel('ingredients'),
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
                              borderSide:
                                  const BorderSide(color: Color(0xFFDEDEDE)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _addIngredient,
                        child: const Icon(Icons.check,
                            color: AppColors.secondary),
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
              const _FieldLabel('Product Sizes'),
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
              const _FieldLabel('Product Add-ons'),
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
                text: _submitting ? 'Saving...' : 'Save changes',
                onPressed: (_canSave && !_submitting) ? _handleSave : null,
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _TextInput({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          color: Color(0xFFC3C3C3),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final File file;
  const _PhotoThumb({required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, width: 64, height: 64, fit: BoxFit.cover),
      ),
    );
  }
}

class _PriceRadio extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _PriceRadio({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFC3C3C3),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.black : const Color(0xFF9F9F9F),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceInput extends StatelessWidget {
  final TextEditingController controller;
  const _PriceInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Enter a number',
        hintStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          color: Color(0xFFC3C3C3),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0,
            child: Text(
              'BD',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
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
            style:
                const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14),
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
