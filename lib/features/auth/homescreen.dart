import 'package:flutter/material.dart';
import 'package:my_app/features/auth/welcome_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              String displayName = "User";

              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                String first = data['firstName'] ?? '';
                String last = data['lastName'] ?? '';
                displayName = "$first $last".trim();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  // ── Logo Section ──
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    child: Image.asset(
                      'assets/logo/logoDark_green.png',
                      width: 150, // Slightly smaller to make room for the list
                      height: 150,
                    ),
                  ),

                  // ── Greeting Section ──
                  Text(
                    'Welcome back,\n$displayName',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── NEW: Near Me Section ──
                  const Text(
                    'Near me',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 140, // Height for the horizontal shop cards
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('stores').snapshots(),
                      builder: (context, storeSnapshot) {
                        if (storeSnapshot.hasError) return const Text('Error loading stores');
                        if (storeSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final docs = storeSnapshot.data!.docs;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var storeData = docs[index].data() as Map<String, dynamic>;
                            return _buildStoreCard(storeData);
                          },
                        );
                      },
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // ── Sign Out Section ──
                  Column(
                    children: [
                      CustomButton(
                        text: 'Sign Out',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                              (route) => false,
                            );
                          }
                        },
                        backgroundColor: AppColors.secondary,
                        textColor: Colors.white,
                        isOutlined: false,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper widget to build each shop card from database data
  Widget _buildStoreCard(Map<String, dynamic> data) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              data['imageUrl'] ?? 'https://via.placeholder.com/80',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80, height: 80, color: Colors.grey[300],
                child: const Icon(Icons.store, color: AppColors.secondary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['name'] ?? 'Shop',
            style: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                (data['rating'] ?? 0.0).toString(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}