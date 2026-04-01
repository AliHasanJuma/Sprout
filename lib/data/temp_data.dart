// TODO: Replace with Firebase
// This file contains all temporary data to power the UI.
// Every class and list will be replaced by Firebase data later.

// ── MODELS ──────────────────────────────────────────────────────────────────

// TODO: Replace with Firebase
class Store {
  final String id, name, description, category, imagePath, logoPath;
  final double rating, distanceKm;
  final List<Product> products;

  const Store({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.logoPath,
    required this.rating,
    required this.distanceKm,
    required this.products,
  });
}

// TODO: Replace with Firebase
class Product {
  final String id, name, description, imagePath;
  final double price;
  final List<String>? ingredients;
  final List<String>? sizes;
  final List<Map<String, dynamic>>? addons; // [{name: String, price: double}]
  final String? allergens;
  final String? nutritionalInfo;
  final String? weight;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    this.ingredients,
    this.sizes,
    this.addons,
    this.allergens,
    this.nutritionalInfo,
    this.weight,
  });
}

// TODO: Replace with Firebase
class ChatThread {
  final String id, contactName, initials, lastMessage, timeAgo;
  final int unreadCount;
  final bool isOnline;
  final List<ChatMessage> messages;
  final String? storeId;

  const ChatThread({
    required this.id,
    required this.contactName,
    required this.initials,
    required this.lastMessage,
    required this.timeAgo,
    required this.unreadCount,
    required this.isOnline,
    required this.messages,
    this.storeId,
  });
}

// TODO: Replace with Firebase
class ChatMessage {
  final String text;
  final bool isSentByMe;
  final String timeAgo;

  const ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timeAgo,
  });
}

// TODO: Replace with Firebase
class UserProfile {
  final String firstName, lastName, email, phoneCountryCode, phoneNumber;
  final String gender;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.gender,
  });
}

// TODO: Replace with Firebase
class FavouriteItem {
  final String storeId, storeName, imagePath;
  final double rating;

  const FavouriteItem({
    required this.storeId,
    required this.storeName,
    required this.imagePath,
    required this.rating,
  });
}

// ── TEMP DATA ───────────────────────────────────────────────────────────────

const String _storeImage = 'assets/images/home page widgets/0001.png';

// TODO: Replace with Firebase
const List<Store> tempStores = [
  Store(
    id: 'store_1',
    name: 'Honey & Thyme',
    description: 'Fresh homemade baked goods and sweet treats',
    category: 'Sweet &\nBaking',
    imagePath: _storeImage,
    logoPath: _storeImage,
    rating: 3.5,
    distanceKm: 5,
    products: [
      Product(
        id: 'p1_1',
        name: 'Chocolate Cake',
        description: 'Rich dark chocolate layered cake with ganache frosting',
        imagePath: _storeImage,
        price: 2.7,
        ingredients: ['Dark chocolate', 'Flour', 'Butter', 'Sugar', 'Eggs', 'Cocoa powder'],
        sizes: ['Small', 'Medium', 'Large'],
        addons: [
          {'name': 'Extra frosting', 'price': 0.5},
          {'name': 'Birthday candles', 'price': 0.3},
          {'name': 'Custom message', 'price': 0.2},
        ],
        allergens: 'Contains gluten, dairy, eggs',
        weight: '1.2 kg',
      ),
      Product(
        id: 'p1_2',
        name: 'Honey Cookies',
        description: 'Crispy golden cookies drizzled with pure honey glaze',
        imagePath: _storeImage,
        price: 1.5,
        ingredients: ['Flour', 'Honey', 'Butter', 'Sugar', 'Vanilla extract'],
        sizes: ['6 pcs', '12 pcs'],
        allergens: 'Contains gluten, dairy',
        weight: '250g',
      ),
      Product(
        id: 'p1_3',
        name: 'Thyme Bread',
        description: 'Freshly baked artisan bread infused with wild thyme',
        imagePath: _storeImage,
        price: 3.0,
        ingredients: ['Flour', 'Wild thyme', 'Olive oil', 'Yeast', 'Salt'],
        allergens: 'Contains gluten',
        weight: '500g',
      ),
    ],
  ),
  Store(
    id: 'store_2',
    name: 'Sweet Bloom',
    description: 'Handcrafted perfumes and scented candles',
    category: 'Perfumes',
    imagePath: _storeImage,
    logoPath: _storeImage,
    rating: 4.0,
    distanceKm: 3,
    products: [
      Product(
        id: 'p2_1',
        name: 'Rose Perfume',
        description: 'Elegant rose-scented eau de parfum for everyday wear',
        imagePath: _storeImage,
        price: 8.5,
        ingredients: ['Rose extract', 'Alcohol', 'Water', 'Fragrance oils'],
        sizes: ['30ml', '50ml', '100ml'],
        addons: [
          {'name': 'Gift wrapping', 'price': 1.0},
          {'name': 'Sample set', 'price': 0.5},
        ],
        weight: '50ml',
      ),
      Product(
        id: 'p2_2',
        name: 'Vanilla Candle',
        description: 'Soy wax candle with a warm and rich vanilla aroma',
        imagePath: _storeImage,
        price: 4.0,
        ingredients: ['Soy wax', 'Vanilla essential oil', 'Cotton wick'],
        sizes: ['Small', 'Large'],
        weight: '200g',
      ),
      Product(
        id: 'p2_3',
        name: 'Oud Mist',
        description: 'Luxurious oud-infused room spray for a royal ambiance',
        imagePath: _storeImage,
        price: 6.0,
        ingredients: ['Oud extract', 'Water', 'Alcohol', 'Essential oils'],
        weight: '150ml',
      ),
    ],
  ),
  Store(
    id: 'store_3',
    name: 'Craft Corner',
    description: 'Unique handmade gifts and home decor items',
    category: 'Crafts &\nHome Decor',
    imagePath: _storeImage,
    logoPath: _storeImage,
    rating: 3.0,
    distanceKm: 7,
    products: [
      Product(
        id: 'p3_1',
        name: 'Wooden Box',
        description: 'Hand-carved wooden keepsake box with floral motif',
        imagePath: _storeImage,
        price: 5.0,
      ),
      Product(
        id: 'p3_2',
        name: 'Macrame Wall Art',
        description: 'Bohemian macrame wall hanging in natural cotton cord',
        imagePath: _storeImage,
        price: 7.5,
      ),
      Product(
        id: 'p3_3',
        name: 'Ceramic Vase',
        description: 'Minimalist ceramic vase perfect for dried flowers',
        imagePath: _storeImage,
        price: 4.5,
      ),
    ],
  ),
  Store(
    id: 'store_4',
    name: 'Aroma Studio',
    description: 'Home cooking essentials and spice blends',
    category: 'Home\nCooking',
    imagePath: _storeImage,
    logoPath: _storeImage,
    rating: 3.5,
    distanceKm: 2,
    products: [
      Product(
        id: 'p4_1',
        name: 'Spice Blend',
        description: 'Signature house blend of seven aromatic spices',
        imagePath: _storeImage,
        price: 2.0,
      ),
      Product(
        id: 'p4_2',
        name: 'Chili Sauce',
        description: 'Homemade fermented chili sauce with a smoky kick',
        imagePath: _storeImage,
        price: 3.5,
      ),
      Product(
        id: 'p4_3',
        name: 'Herb Mix',
        description: 'Dried herb mix of basil, oregano and rosemary',
        imagePath: _storeImage,
        price: 1.8,
      ),
    ],
  ),
  Store(
    id: 'store_5',
    name: 'Gift Galaxy',
    description: 'Curated gift sets for every special occasion',
    category: 'Gifts',
    imagePath: _storeImage,
    logoPath: _storeImage,
    rating: 4.5,
    distanceKm: 4,
    products: [
      Product(
        id: 'p5_1',
        name: 'Blue Gift Set',
        description: 'Premium blue-themed gift box with ribbon and card',
        imagePath: _storeImage,
        price: 12.0,
      ),
      Product(
        id: 'p5_2',
        name: 'Birthday Bundle',
        description: 'Complete birthday celebration package with balloons',
        imagePath: _storeImage,
        price: 9.0,
      ),
      Product(
        id: 'p5_3',
        name: 'Thank You Box',
        description: 'Thoughtful thank you gift box with assorted chocolates',
        imagePath: _storeImage,
        price: 6.5,
      ),
    ],
  ),
];

// TODO: Replace with Firebase
const List<ChatThread> tempChatThreads = [
  ChatThread(
    id: 'chat_1',
    contactName: 'Sptemalla',
    initials: 'SP',
    lastMessage: 'Yes, the color is not very...',
    timeAgo: '5m',
    unreadCount: 6,
    isOnline: true,
    storeId: 'store_1',
    messages: [
      ChatMessage(text: 'Hi, is this available?', isSentByMe: false, timeAgo: '30m'),
      ChatMessage(text: 'Yes it is! Would you like to order?', isSentByMe: true, timeAgo: '28m'),
      ChatMessage(text: 'I was wondering about the color options', isSentByMe: true, timeAgo: '27m'),
      ChatMessage(text: 'Do you have it in blue?', isSentByMe: false, timeAgo: '25m'),
      ChatMessage(text: 'Sure, we have blue and green', isSentByMe: true, timeAgo: '20m'),
      ChatMessage(text: 'Can you send me a picture of the blue one?', isSentByMe: false, timeAgo: '15m'),
      ChatMessage(text: 'Here you go! Let me know what you think', isSentByMe: true, timeAgo: '10m'),
      ChatMessage(text: 'Yes, the color is not very bright though', isSentByMe: false, timeAgo: '5m'),
    ],
  ),
  ChatThread(
    id: 'chat_2',
    contactName: 'Jassmina sofa',
    initials: 'JS',
    lastMessage: 'Can you send it?',
    timeAgo: '1h',
    unreadCount: 0,
    isOnline: false,
    storeId: 'store_2',
    messages: [
      ChatMessage(text: 'Hello, I saw your sofa listing', isSentByMe: true, timeAgo: '3h'),
      ChatMessage(text: 'Hi! Yes, it is still available', isSentByMe: false, timeAgo: '2h'),
      ChatMessage(text: 'What are the dimensions?', isSentByMe: true, timeAgo: '2h'),
      ChatMessage(text: 'It is 2m by 1.5m', isSentByMe: false, timeAgo: '1h'),
      ChatMessage(text: 'Perfect, that fits my living room', isSentByMe: true, timeAgo: '1h'),
      ChatMessage(text: 'Can you send it?', isSentByMe: false, timeAgo: '1h'),
    ],
  ),
  ChatThread(
    id: 'chat_3',
    contactName: 'Ana marhon',
    initials: 'AM',
    lastMessage: 'Thanks for the quick response',
    timeAgo: '2h',
    unreadCount: 0,
    isOnline: false,
    storeId: 'store_3',
    messages: [
      ChatMessage(text: 'Do you deliver to Riffa?', isSentByMe: true, timeAgo: '5h'),
      ChatMessage(text: 'Yes we deliver across Bahrain', isSentByMe: false, timeAgo: '4h'),
      ChatMessage(text: 'Great! How much is delivery?', isSentByMe: true, timeAgo: '4h'),
      ChatMessage(text: 'Delivery is 1 BD for your area', isSentByMe: false, timeAgo: '3h'),
      ChatMessage(text: 'I will place an order now', isSentByMe: true, timeAgo: '3h'),
      ChatMessage(text: 'Thanks for the quick response', isSentByMe: false, timeAgo: '2h'),
    ],
  ),
  ChatThread(
    id: 'chat_4',
    contactName: 'Sptemalla',
    initials: 'SP',
    lastMessage: 'Is it still available',
    timeAgo: '1d',
    unreadCount: 1,
    isOnline: true,
    storeId: 'store_4',
    messages: [
      ChatMessage(text: 'Hey, I ordered the spice blend last week', isSentByMe: true, timeAgo: '3d'),
      ChatMessage(text: 'Yes! How did you like it?', isSentByMe: false, timeAgo: '3d'),
      ChatMessage(text: 'It was amazing, I want to reorder', isSentByMe: true, timeAgo: '2d'),
      ChatMessage(text: 'Thank you! We have a new batch ready', isSentByMe: false, timeAgo: '2d'),
      ChatMessage(text: 'Do you also have the herb mix?', isSentByMe: true, timeAgo: '1d'),
      ChatMessage(text: 'Is it still available', isSentByMe: false, timeAgo: '1d'),
    ],
  ),
  ChatThread(
    id: 'chat_5',
    contactName: 'Play shop',
    initials: 'PS',
    lastMessage: 'no sorry',
    timeAgo: '3d',
    unreadCount: 0,
    isOnline: false,
    storeId: 'store_5',
    messages: [
      ChatMessage(text: 'Hi, do you have gift wrapping?', isSentByMe: true, timeAgo: '5d'),
      ChatMessage(text: 'Yes we offer free gift wrapping', isSentByMe: false, timeAgo: '5d'),
      ChatMessage(text: 'Can I get a custom message card?', isSentByMe: true, timeAgo: '4d'),
      ChatMessage(text: 'Of course! Just tell us what to write', isSentByMe: false, timeAgo: '4d'),
      ChatMessage(text: 'Do you have express delivery?', isSentByMe: true, timeAgo: '3d'),
      ChatMessage(text: 'no sorry', isSentByMe: false, timeAgo: '3d'),
    ],
  ),
];

// TODO: Replace with Firebase
const UserProfile tempUserProfile = UserProfile(
  firstName: 'Abdulla',
  lastName: 'Yusuf',
  email: 'example@gmail.com',
  phoneCountryCode: '+973',
  phoneNumber: '3333 3333',
  gender: 'Male',
);

// TODO: Replace with Firebase
// In-memory favourites list — managed by the app at runtime
List<FavouriteItem> tempFavourites = [];

// TODO: Replace with Firebase
List<String> tempRecentSearches = [
  'chocolate',
  'cake',
  'Biscuits',
  'Wooden box',
  'Blue gift',
];
