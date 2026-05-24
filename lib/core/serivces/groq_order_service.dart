import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroqOrderService {
  static const String _vercelUrl = 'https://groq-proxy-kappa.vercel.app/api/chat';
  
  static Future<Map<String, dynamic>> extractOrderFromChat({
    required String chatId,
    required String storeName,
    required List<Map<String, dynamic>> storeProducts,
  }) async {
    try {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();
      
      if (messagesSnapshot.docs.isEmpty) {
        return {'has_order': false, 'error': 'No messages found'};
      }
      
      final currentUser = FirebaseAuth.instance.currentUser;
      
      String conversation = '';
      for (var doc in messagesSnapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        final senderName = senderId == currentUser?.uid ? 'Buyer' : storeName;
        final text = data['text'] as String? ?? '';
        conversation += '$senderName: $text\n';
      }
      
      // Build products list with sizes and addOns
      String productsList = '';
      for (var product in storeProducts) {
        final name = product['name'] ?? 'Unknown';
        final price = product['price'] ?? 0;
        final priceType = product['priceType'] ?? 'fixed';
        
        productsList += '- $name: Base price $price BHD ($priceType)\n';
        
        // Add sizes if available
        final sizes = product['sizes'] as List<dynamic>?;
        if (sizes != null && sizes.isNotEmpty) {
          productsList += '  Sizes available:\n';
          for (var size in sizes) {
            final sizeName = size['size'] ?? 'unknown';
            final modifier = size['priceModifier'] ?? 0;
            productsList += '    - $sizeName: +${modifier} BHD\n';
          }
        }
        
        // Add addOns if available
        final addOns = product['addOns'] as List<dynamic>?;
        if (addOns != null && addOns.isNotEmpty) {
          productsList += '  Add-ons available:\n';
          for (var addon in addOns) {
            final addonName = addon['name'] ?? 'unknown';
            final modifier = addon['priceModifier'] ?? 0;
            productsList += '    - $addonName: +${modifier} BHD\n';
          }
        }
      }
      
      print('=== CONVERSATION ===');
      print(conversation);
      print('====================');
      
      // Make request to Vercel endpoint
      final response = await http.post(
        Uri.parse(_vercelUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an order extraction assistant for "Sprout", a local marketplace app in Bahrain.

RULES:
1. Extract order details when the seller has agreed to provide the items.
2. Seller agreement includes: "yes", "okay", "alright", "deal", "confirmed", "fine", "go ahead", "I will give you", "I can do that", etc.
3. If the buyer asks for a discount and the seller offers a different discount, use the seller's offered discount.
4. If the seller hasn't responded yet or says "no", set has_order = false.
5. Extract each item mentioned by the buyer that the seller agrees to.
6. Include any selected size and add-ons in the order details.
7. Calculate final price by: base price + size modifier + add-on modifiers, then multiply by quantity.

Return ONLY valid JSON. No other text. Format: 
{
  "has_order": true/false, 
  "items": [
    {
      "name": "product", 
      "quantity": number, 
      "base_price": number,
      "selected_size": "size name or null",
      "selected_addons": ["addon1", "addon2"],
      "price_per_unit": number (final price after modifiers)
    }
  ], 
  "total_price": number, 
  "delivery_method": "customerPickup/localDelivery/publicMeetup", 
  "delivery_area": "area", 
  "notes": "instructions"
}''',
            },
            {
              'role': 'user',
              'content': 'STORE: $storeName\nAVAILABLE PRODUCTS WITH SIZES AND ADD-ONS:\n$productsList\n\nCONVERSATION:\n$conversation\n\nExtract order details including any selected sizes and add-ons. Calculate final prices correctly.',
            }
          ],
          'temperature': 0.2,
          'max_tokens': 800,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        print('=== GROQ RESPONSE ===');
        print(content);
        print('=====================');
        
        final startIndex = content.indexOf('{');
        final endIndex = content.lastIndexOf('}');
        
        if (startIndex != -1 && endIndex != -1) {
          final jsonStr = content.substring(startIndex, endIndex + 1);
          return jsonDecode(jsonStr);
        }
      }
      
      print('Vercel/Groq error: ${response.statusCode} - ${response.body}');
      return {'has_order': false, 'error': 'Failed to parse response'};
      
    } catch (e) {
      print('Groq service error: $e');
      return {'has_order': false, 'error': e.toString()};
    }
  }
}