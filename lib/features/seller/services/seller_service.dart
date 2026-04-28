import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/store_model.dart';

class SellerService {
  SellerService._internal();
  static final SellerService _instance = SellerService._internal();
  factory SellerService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── 1. CREATE STORE ──
  Future<void> createStore(StoreModel store) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    // Upload images to Firebase Storage first
    String logoUrl = '';
    String bannerUrl = '';

    if (store.logoPath != null) {
      logoUrl = await uploadImage(File(store.logoPath!), 'logos');
    }
    if (store.bannerPath != null) {
      bannerUrl = await uploadImage(File(store.bannerPath!), 'banners');
    }

    // Save to Firestore
    final docRef = await _db.collection('stores').add({
      'ownerId': uid,
      'name': store.name,
      'description': store.bio,
      'category': store.category,
      'logoUrl': logoUrl,
      'imageUrl': bannerUrl,
      'latitude': store.location?.lat ?? 0.0,
      'longitude': store.location?.lng ?? 0.0,
      'address': store.location?.address ?? '',
      'handoffMethods': store.handoffMethods.map((e) => e.toString().split('.').last).toList(),
      'rating': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Upgrade User to Seller status
    await _db.collection('users').doc(uid).update({
      'role': 'seller',
      'storeId': docRef.id,
    });
  }

  // ── 2. GET MY STORE ──
  Future<StoreModel?> getMyStore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    // Find the store that belongs to this user
    final snap = await _db.collection('stores').where('ownerId', isEqualTo: uid).limit(1).get();
    
    if (snap.docs.isEmpty) return null;

    final data = snap.docs.first.data();
    final docId = snap.docs.first.id;

    // We map the Firebase data back into your teammate's StoreModel format.
    // (Note: You may need to tweak this slightly depending on exactly how 
    // your teammate wrote the StoreModel file).
    return StoreModel(
      id: docId,
      name: data['name'] ?? '',
      bio: data['description'] ?? '',
      category: data['category'] ?? '',
      logoPath: data['logoUrl'],
      bannerPath: data['imageUrl'],
      // location & handoffMethods can be mapped here too based on your StoreModel structure
    );
  }

  // ── 3. UPDATE STORE ──
  Future<void> updateStore(StoreModel store) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || store.id == null) return;

    // Check if paths are local files or already Firebase URLs
    String logoUrl = store.logoPath ?? '';
    if (logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
      logoUrl = await uploadImage(File(logoUrl), 'logos');
    }

    String bannerUrl = store.bannerPath ?? '';
    if (bannerUrl.isNotEmpty && !bannerUrl.startsWith('http')) {
      bannerUrl = await uploadImage(File(bannerUrl), 'banners');
    }

    await _db.collection('stores').doc(store.id).update({
      'name': store.name,
      'description': store.bio,
      'category': store.category,
      if (logoUrl.isNotEmpty) 'logoUrl': logoUrl,
      if (bannerUrl.isNotEmpty) 'imageUrl': bannerUrl,
      'latitude': store.location?.lat ?? 0.0,
      'longitude': store.location?.lng ?? 0.0,
      'address': store.location?.address ?? '',
      'handoffMethods': store.handoffMethods.map((e) => e.toString().split('.').last).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── 4. DELETE STORE ──
  Future<void> deleteStore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snap = await _db.collection('stores').where('ownerId', isEqualTo: uid).limit(1).get();
    if (snap.docs.isEmpty) return;

    // Delete the store document
    await _db.collection('stores').doc(snap.docs.first.id).delete();

    // Downgrade the user back to a normal buyer
    await _db.collection('users').doc(uid).update({
      'role': 'buyer',
      'storeId': FieldValue.delete(),
    });
  }

  // ── 5. UPLOAD IMAGE TO FIREBASE STORAGE ──
  Future<String> uploadImage(File file, String folderName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('stores/$uid/$folderName/$fileName');
    
    await ref.putFile(file);
    return await ref.getDownloadURL(); // Returns the public https:// link
  }
}