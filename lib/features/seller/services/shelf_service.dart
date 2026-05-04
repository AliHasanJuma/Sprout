import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/shelf_model.dart';

class ShelfService {
  ShelfService._internal();
  static final ShelfService _instance = ShelfService._internal();
  factory ShelfService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── 1. CREATE SHELF ITEM ──
  Future<void> createShelf(ShelfModel shelf) async {
    if (shelf.storeId.isEmpty) throw Exception("Shelf must belong to a store");
    await _db.collection('shelves').add(shelf.toMap());
  }

  // ── 2. GET MY SHELVES ──
  // Changed back to a Future with 0 arguments to match your UI perfectly!
  Future<List<ShelfModel>> getMyShelves() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      // 1. Automatically find the user's store
      final storeSnap = await _db
          .collection('stores')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();

      if (storeSnap.docs.isEmpty) return [];
      final storeId = storeSnap.docs.first.id;

      // 2. Fetch all shelves belonging to that store
      final shelfSnap = await _db
          .collection('shelves')
          .where('storeId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .get();

      return shelfSnap.docs
          .map((doc) => ShelfModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching shelves: $e");
      return [];
    }
  }

  // ── 3. GET SINGLE SHELF ITEM ──
  Future<ShelfModel?> getShelf(String shelfId) async {
    final doc = await _db.collection('shelves').doc(shelfId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ShelfModel.fromMap(doc.data()!, doc.id);
  }

  // ── 4. UPDATE SHELF ITEM ──
  Future<void> updateShelf(ShelfModel shelf) async {
    if (shelf.id == null) return;
    
    final data = shelf.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp(); 
    
    await _db.collection('shelves').doc(shelf.id).update(data);
  }

  // ── 5. DELETE SHELF ITEM ──
  Future<void> deleteShelf(String shelfId) async {
    final doc = await _db.collection('shelves').doc(shelfId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final List<dynamic> photoPaths = data['photoPaths'] ?? [];

    await _db.collection('shelves').doc(shelfId).delete();

    for (String url in photoPaths) {
      if (url.startsWith('http')) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (e) {
          // Ignore if image is already gone
        }
      }
    }
  }

  // ── 6. UPLOAD SINGLE IMAGE ──
  Future<String> uploadShelfImage(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('shelves/$uid/$fileName');
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}