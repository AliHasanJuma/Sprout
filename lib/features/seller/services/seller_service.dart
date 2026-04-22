import 'dart:io';

import '../models/store_model.dart';

class SellerService {
  SellerService._internal();
  static final SellerService _instance = SellerService._internal();
  factory SellerService() => _instance;

  StoreModel? _store;

  Future<void> createStore(StoreModel store) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store = store.copyWith(id: store.id ?? 'local-${DateTime.now().millisecondsSinceEpoch}');
    // TODO: replace with Firestore write (users/{uid}/store).
  }

  Future<StoreModel?> getMyStore() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store;
    // TODO: replace with Firestore read.
  }

  Future<void> updateStore(StoreModel store) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store = store;
    // TODO: replace with Firestore update.
  }

  Future<void> deleteStore() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store = null;
    // TODO: replace with Firestore delete + Storage cleanup.
  }

  Future<String> uploadImage(File file) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return file.path;
    // TODO: replace with Firebase Storage upload, returning downloadUrl.
  }
}
