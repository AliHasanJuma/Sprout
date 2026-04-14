import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroqOrderService {
  // GROQ API KEY
  static const String _apiKey = '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';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  static Future<Map<String, dynamic>> extractOrderFromChat({
    required String chatId,
    required String storeName,
    required List<Map<String, dynamic>> storeProducts,
  }) async {
    try {
      // Get chat messages from Firestore
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
      
      // Build conversation string
      String conversation = '';
      for (var doc in messagesSnapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        final senderName = senderId == currentUser?.uid ? 'Buyer' : storeName;
        final text = data['text'] as String? ?? '';
        conversation += '$senderName: $text\n';
      }
      
      // Build products list
      String productsList = '';
      for (var product in storeProducts) {
        final name = product['name'] ?? 'Unknown';
        final price = product['price'] ?? 0;
        productsList += '- $name: $price BHD\n';
      }
      
      print('=== CONVERSATION ===');
      print(conversation);
      print('====================');
      
      // Make API call to Groq
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // Free, fast, reliable
          'messages': [
            {
              'role': 'system',
              'content': 'Extract order details from conversation and pay attention while checking for discounts(important) and notes. Return ONLY valid JSON. No other text. Format: {"has_order": true/false, "items": [{"name": "product", "quantity": number, "price_per_unit": number}], "total_price": number, "delivery_method": "pickup/courier", "delivery_area": "area", "notes": "instructions"}'
            },
            {
              'role': 'user',
              'content': 'STORE: $storeName\nPRODUCTS:\n$productsList\n\nCONVERSATION:\n$conversation\n\nExtract order details as JSON.'
            }
          ],
          'temperature': 0.2,
          'max_tokens': 500,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        print('=== GROQ RESPONSE ===');
        print(content);
        print('=====================');
        
        // Extract JSON from response
        final startIndex = content.indexOf('{');
        final endIndex = content.lastIndexOf('}');
        
        if (startIndex != -1 && endIndex != -1) {
          final jsonStr = content.substring(startIndex, endIndex + 1);
          return jsonDecode(jsonStr);
        }
      }
      
      print('Groq error: ${response.statusCode} - ${response.body}');
      return {'has_order': false, 'error': 'Failed to parse Groq response'};
      
    } catch (e) {
      print('Groq service error: $e');
      return {'has_order': false, 'error': e.toString()};
    }
  }
}