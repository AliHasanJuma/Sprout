import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../buyer_ui/Mainscreen.dart';

class AllSetScreen extends StatelessWidget {
  final String firstName;
  final String lastName;

  const AllSetScreen({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0), // padding
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                
                // Main content container with 300px width
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      // Icon
                      Image.asset(
                        'assets/icons/Search_Local.png',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                      
                      
                      
                      const Text(
                        'Welcome to the family!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Explore unique crafts and start connecting with your local community',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 144),
                
                // All set button - with proper padding from parent
                CustomButton(
                  text: 'All set!',
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false,
                    );
                  },
                  backgroundColor: AppColors.primary,
                  textColor: Colors.black,
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}