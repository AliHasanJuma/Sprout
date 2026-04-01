# Sprout — Full Project Context
_Last updated: 2026-03-31. Branch: `building-UI-ameer`_

---

## What Is Sprout?

Sprout is a Flutter mobile app for **Bahrain** that connects buyers with local home-based sellers (crafts, baked goods, perfumes, gifts, home cooking, fashion, home decor). Think of it as a local marketplace where community sellers list their products and buyers can browse, search, favourite stores, and chat with sellers. The app is buyer-facing only at this stage — there is no seller UI yet.

Target platforms: **iOS and Android** (simulator-tested on both).

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK `^3.9.2`) |
| Auth | Firebase Auth `^6.2.0` (email/password + phone OTP) |
| Firebase | `firebase_core ^4.5.0`, `firebase_ui_auth ^3.0.1` |
| SVG rendering | `flutter_svg ^2.0.10+1` |
| State management | Plain `setState` — no external state manager yet |
| Navigation | `Navigator.push` / `pushReplacement` / `pushAndRemoveUntil` (no go_router) |
| Data | `lib/data/temp_data.dart` — all in-memory, marked `// TODO: Replace with Firebase` |
| Font | `SF Pro Display` throughout (declared in pubspec) |
| Splash screen | `flutter_native_splash ^2.4.0` |

Firebase project ID: `sprout-c5452`. Bundle ID: `com.example.myApp`.

---

## Color Palette (AppColors)

Defined in `lib/core/constants/app_colors.dart`:

| Name | Hex | Usage |
|---|---|---|
| `primary` | `#DAF64F` | Buttons, active borders, unread badges, input focus |
| `secondary` | `#003E3B` | Dark teal — text, headers, icons |
| `tertiary` | `#EFF8C5` | Light lime (rarely used) |
| `background` | `#FFFFFF` | Scaffold backgrounds |

Additional colors used inline:
- Lime green wave: `#CDEB45` (home/store/profile header background)
- Grey inactive: `#9F9F9F` (nav icons, placeholder text)
- Search hint: `#C3C3C3`
- Light border: `#DEDEDE`

---

## Asset Structure

```
assets/
  logo/
    logoBlack.png              ← used in SplashScreen (320×320)
    logoBlack_fullsize.png     ← used in HomePage header (100×40)
    logodark_green.png         ← used in WelcomeScreen (200×40)
  icons/
    Profile_picture.png        ← circular avatar (home header + profile page)
    Search_Local.png           ← AllSetScreen illustration
    MG_favourite_list.png      ← FavouritePage empty state
  images/
    category/
      Baking.png
      Crafts.png
      fastion.png              ← Fashion (filename typo — use as-is)
      gift.png
      home-cooking.png
      perfume.png
    home page widgets/
      0001.png                 ← used for store images, banner, product images (placeholder)
  Essentials/
    bowdesign.svg              ← Figma-exported wave shape (currently unused — replaced by _BowClipper)
    Added/
      star.svg                 ← AI sparkle icon (InnerChatPage + AiSummarisePage)
      delivery.svg             ← delivery icon (AiSummarisePage)
  UI icons package/PNG/Black/
    Arrow/Arrow_Left_MD.png    ← back button in auth screens
    Navigation/House_01.png    ← navbar Home icon
    Communication/Chat_Circle_Dots.png ← navbar Chat icon
    Interface/Heart_01.png     ← navbar Favourite icon
    Edit/Rows.png              ← navbar Shelves icon
```

The `assets/Essentials/bowdesign.svg` was exported from Figma but the wave header is now rendered with a pure-Dart `_BowClipper` (see below). `flutter_svg` is still needed for `star.svg` and `delivery.svg`.

---

## The Bow / Wave Shape (_BowClipper)

A shared `CustomClipper<Path>` used in `home_page.dart`, `store_page.dart`, and `profile_page.dart` headers. It is defined locally in each file (copy-paste — not yet extracted to a shared widget).

The shape is derived from the Figma SVG (`viewBox="0 0 570.4 274"`, peak depth 51.8px):

```dart
class _BowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double svgHeight = 274.0;
    const double svgPeakDepth = 51.8;
    final double controlY =
        size.height - (size.height * (svgPeakDepth / svgHeight) * 2);

    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, controlY, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_BowClipper oldClipper) => false;
}
```

The lime green container is 220px tall; the full `SizedBox` is 260px so the circular avatar/logo overlaps the wave by 40px.

---

## Full Screen Map & Navigation Flow

### Auth Flow (one-time, cleared from stack on completion)

```
SplashScreen (2 sec, checks Firebase auth state)
  ├── already logged in → MainScreen
  └── not logged in → WelcomeScreen
        ├── Sign Up → SignUpScreen
        │     └── Continue → PhoneNumberScreen (passes firstName, lastName, email, gender)
        │           └── Continue → VerificationScreen (passes verificationId + user data)
        │                 └── Continue (OTP ok) → AllSetScreen
        │                       └── All set! → MainScreen (stack cleared)
        └── Log In → LoginScreen
              └── Log In (success) → MainScreen (pushReplacement)
```

`WelcomeScreen` has a post-frame guard: if a logged-in user somehow lands there, they are immediately redirected to `MainScreen`.

### Main App (MainScreen — bottom nav shell)

`MainScreen` (`lib/features/buyer_ui/Mainscreen.dart`) holds 4 pages in a list. The navbar index controls which is shown:

| Index | Tab | File | State |
|---|---|---|---|
| 0 | Home | `lib/features/buyer_ui/home_page.dart` | Stateful |
| 1 | Chat | `lib/screens/chats_page.dart` | Stateless |
| 2 | Favourite | `lib/screens/favourite_page.dart` | Stateful (GlobalKey for refresh) |
| 3 | Shelves | inline `Center(child: Text('Shelves Page'))` | Placeholder |

`FavouritePage` has a public `refresh()` method called via `GlobalKey` whenever the user switches to tab 2 (so a heart-toggle in `StorePage` is reflected immediately).

### Pages Reachable from HomePage

```
HomePage
  ├── Search bar (button) → SearchPage
  │     ├── typing → live filtered results (tempStores)
  │     └── submit → SearchResultPage(query)
  │           └── store row tap → StorePage(store)
  ├── Category item tap → CategoryPage (placeholder)
  ├── Banner tap → CategoryPage (placeholder)
  ├── Store card tap → StorePage(store)
  └── Profile avatar → ProfilePage
```

### StorePage sub-navigation

```
StorePage
  ├── Back button → Navigator.pop
  ├── Heart button → toggles tempFavourites (in-memory)
  ├── Product "Chat" button → InnerChatPage(chatThread matching storeId)
  └── Product "Order now" button → SnackBar "Order placed!" (placeholder)
```

### InnerChatPage sub-navigation

```
InnerChatPage
  ├── Back button → Navigator.pop
  └── AI sparkle button → AiSummarisePage(store)
        ├── quantity +/- controls (in-memory, up to 2 products shown)
        ├── "Send" button → SnackBar "Order sent successfully!" (placeholder)
        └── "Go back" → Navigator.pop
```

---

## Screen-by-Screen Details

### SplashScreen (`lib/features/auth/splash_screen.dart`)
- Lime green background (`AppColors.primary`), `logoBlack.png` centered, `CircularProgressIndicator`
- Uses `FirebaseAuth.instance.authStateChanges().first` (NOT `currentUser`) to reliably restore persisted session on cold start across all platforms

### WelcomeScreen (`lib/features/auth/welcome_screen.dart`)
- White background, `logodark_green.png`, "Connect,\nCraft & Share." headline
- Two buttons: Sign Up (dark teal bg, white text) | Log In (lime green bg, dark text)
- Has `initState` guard redirecting authenticated users to `MainScreen`

### SignUpScreen (`lib/features/auth/sign_up_screen.dart`)
- Collects: First Name, Last Name, Gender (Male/Female toggle), Email, Password
- Validation: name (letters/spaces, max 30), email regex, password (8+ chars, letter + number + special char)
- Firebase: `createUserWithEmailAndPassword` — creates the email/password account first, then pushes to `PhoneNumberScreen`
- **Note:** account is created before phone is verified — phone verification is additive

### PhoneNumberScreen (`lib/features/auth/phone_number_screen.dart`)
- Bahrain country code `+973` is hard-coded and non-editable
- 8-digit phone number input with auto-format (space after 4 digits): `XXXX XXXX`
- Uses `FirebaseAuth.instance.verifyPhoneNumber()`
- **IMPORTANT — simulator workaround:** `appVerificationDisabledForTesting: true` is set before calling `verifyPhoneNumber`. **Remove this before production release.** This bypasses reCAPTCHA/APNs so the iOS simulator does not crash.
- The `_handleContinue` is `void` (not async) — callbacks capture `context` directly. This is a known issue; the async-safe version captures `messenger`/`nav` before the call (done in `VerificationScreen` but not yet in this file).

### VerificationScreen (`lib/features/auth/verification_screen.dart`)
- 6 OTP boxes with auto-focus advance and backspace-to-previous
- On correct code: signs in with `PhoneAuthCredential`, then calls `user?.updateDisplayName('$firstName $lastName')` so `HomePage` can greet the user by name
- Navigates to `AllSetScreen` (uses `pushReplacement` to kill the OTP screen)
- Context safety: `messenger` and `nav` captured before `await`

### AllSetScreen (`lib/features/auth/all_set.dart`)
- Success screen after phone OTP — shown only during sign-up
- `Search_Local.png` illustration, "Welcome to the family!" title, subtitle text
- "All set!" button uses `Navigator.pushAndRemoveUntil` → `MainScreen`, clearing the entire auth stack (user cannot go back)
- Accepts `firstName` and `lastName` parameters but currently does not display them

### LoginScreen (`lib/features/auth/login_screen.dart`)
- Email + password, `signInWithEmailAndPassword`, navigates to `MainScreen` on success
- "Forgot Password?" button exists but has no implementation
- "Don't have an account? Sign Up" uses `TapGestureRecognizer` with `pushReplacement`

### MainScreen (`lib/features/buyer_ui/Mainscreen.dart`)
- Thin shell: `Scaffold` with `body: _pages[_currentIndex]` and `bottomNavigationBar: CustomNavBar`
- Pages are instantiated once in `initState` and reused

### HomePage (`lib/features/buyer_ui/home_page.dart`)
- **Header:** `SizedBox(height: 200)` → `Stack` → `ClipPath(_BowClipper)` lime green background + `SafeArea` content (logo + welcome text + profile avatar) + `Positioned` floating search bar at `bottom: -8`
- **Welcome text:** reads `FirebaseAuth.instance.currentUser?.displayName`, splits on space to get first name, falls back to `'there'`
- **Search bar:** `GestureDetector` → `SearchPage` with `AbsorbPointer` on the inner `CustomSearchBar` (so it acts as a button, not a text field)
- **Categories:** 6 items — Sweet & Baking, Gifts, Perfumes, Home Cooking, Crafts & Home Decor, Fashion. Each taps to `CategoryPage`. `errorBuilder` shows grey box if image missing.
- **Banner:** `PageView` (3 pages), `PageController`, `setState` for dot indicator. Each card shows `0001.png` full-bleed, taps to `CategoryPage`
- **Near Me:** uses `_Store` model (local to file), 4 stores with `imagePath`, `name`, `rating`. Each taps to `StorePage` — BUT the `StorePage` expects a `Store` from `temp_data.dart`, while `_buildStoreCard` passes a simplified `_Store`. **This is inconsistent — the near-me cards on home don't pass a full `Store` object.**

### CustomNavBar (`lib/shared/widgets/navbar.dart`)
- White background, height 86 inside `SafeArea`
- Shadow: `BoxShadow(color: Color(0x26000000), offset: Offset(0, -2), blurRadius: 8, spreadRadius: 0)` — upward soft shadow
- 4 items: Home, Chat, Favourite, Shelves — all use `Image.asset` with `colorBlendMode: BlendMode.srcIn`
- Active: `Colors.black`, inactive: `Color(0xFF9F9F9F)`

### CustomSearchBar (`lib/shared/widgets/search_bar.dart`)
- Visual-only pill bar (48px height, borderRadius 70, white, shadow)
- `IgnorePointer` is NOT in this widget — it's applied at the call site in `HomePage`
- Has optional `hintText` parameter (default `'Search for anything'`)

### SearchPage (`lib/screens/search_page.dart`)
- Auto-focuses text field on open
- Live filtering of `tempStores` by name + description as user types
- Recent searches shown as chips (using `tempRecentSearches` from temp_data)
- Submit pushes to `SearchResultPage(query: ...)`
- Clear button removes all recent searches

### SearchResultPage (`lib/screens/search_result_page.dart`)
- Stateless; filters `tempStores` at build time
- Tapping a result pushes `StorePage(store: store)`

### StorePage (`lib/screens/store_page.dart`)
- Bow-shaped lime green header (220px), back button + heart button (top corners), store logo (100×100, rounded 12, dark teal bg) centered overlapping the wave
- Tabs not used — single scroll with: store name/description → divider → Rating | Category | Distance row → divider → product cards
- Products: image (94×112) + name, description, price in BD, "Chat" button → `InnerChatPage`, "Order now" → SnackBar
- Favourite toggle writes to/reads from `tempFavourites` list in memory
- Has its own copy of `_BowClipper`

### ChatsPage (`lib/screens/chats_page.dart`)
- List of `tempChatThreads` with avatar (lime green `CircleAvatar` with initials), name, last message preview, time, unread count badge
- Online dot shown if `thread.isOnline`
- Taps to `InnerChatPage(chatThread: thread)`

### InnerChatPage (`lib/screens/inner_chat_page.dart`)
- Local `_messages` list (copy of `chatThread.messages`) — new messages appended in-memory only
- Sent messages: `#CDEB45` bubble (right), received: `#EBEBEB` (left)
- Input row: AI sparkle button (dark teal circle with `star.svg`) → `AiSummarisePage`, text field, send icon
- Auto-scrolls to bottom on send

### AiSummarisePage (`lib/screens/ai_summarise_page.dart`)
- "AI order summary" concept screen — shows up to 2 products from the store
- Each product has quantity +/- (trash icon at qty 1 hides the row)
- Delivery details row (placeholder text), total price calculated live
- "Send" → SnackBar "Order sent successfully!" (no real order logic)
- Uses `star.svg` and `delivery.svg` via `flutter_svg`

### FavouritePage (`lib/screens/favourite_page.dart`)
- Empty state: `MG_favourite_list.png` illustration + text
- Filled state: list rows of `tempFavourites`, tapping opens `StorePage`
- Heart icon in list removes from `tempFavourites`
- Public `FavouritePageState.refresh()` called by `MainScreen` via `GlobalKey` on tab switch

### ProfilePage (`lib/screens/profile_page.dart`)
- Full profile edit form: First Name, Last Name, Gender toggle, Phone Number, Email (read-only)
- Data populated from `tempUserProfile` (static temp data — NOT from Firebase)
- Bow-shaped green header (220px), back button (top-left), profile avatar centered overlapping
- "Sign Out" text button (red) at bottom → `AlertDialog` confirm → `FirebaseAuth.instance.signOut()` → `pushAndRemoveUntil` to `WelcomeScreen`
- Has its own copy of `_BowClipper`

### CategoryPage (`lib/screens/category_page.dart`)
- Placeholder only: `AppBar` with back button + title "Category", body "Category Page - Coming Soon"

---

## Data Layer (`lib/data/temp_data.dart`)

All marked `// TODO: Replace with Firebase`. Everything is in-memory constants/variables.

**Models:**
- `Store` — id, name, description, category, imagePath, logoPath, rating (double), distanceKm (double), products (List\<Product\>)
- `Product` — id, name, description, imagePath, price (double, in BD)
- `ChatThread` — id, contactName, initials, lastMessage, timeAgo, unreadCount, isOnline, messages, storeId
- `ChatMessage` — text, isSentByMe, timeAgo
- `UserProfile` — firstName, lastName, email, phoneCountryCode, phoneNumber, gender
- `FavouriteItem` — storeId, storeName, imagePath, rating

**Data:**
- `tempStores` (const List\<Store\>, 5 stores): Honey & Thyme (baking), Sweet Bloom (perfumes), Craft Corner (crafts), Aroma Studio (cooking), Gift Galaxy (gifts). Each has 3 products.
- `tempChatThreads` (const, 5 threads) — linked to stores via `storeId`
- `tempUserProfile` (const) — Abdulla Yusuf, example@gmail.com, +973, 3333 3333, Male
- `tempFavourites` (mutable `List<FavouriteItem>`, starts empty) — toggled by `StorePage` and `FavouritePage`
- `tempRecentSearches` (mutable `List<String>`) — 5 seed entries, updated by `SearchPage`

All images use `assets/images/home page widgets/0001.png` as a placeholder.

---

## Known Issues / TODOs

1. **PhoneNumberScreen `_handleContinue` is not async** — `verifyPhoneNumber` callbacks use `context` directly without `mounted` checks. If the widget is disposed before `codeSent` fires, this could crash. The fix is to convert to `async`, capture `messenger`/`nav` before the call, and add `if (!mounted) return;` in callbacks.

2. **`appVerificationDisabledForTesting: true`** is active in `PhoneNumberScreen`. Must be removed before App Store / Play Store release.

3. **`GoogleService-Info.plist` is missing `CLIENT_ID` and `REVERSED_CLIENT_ID`**. This means the proper reCAPTCHA fallback for iOS phone auth is not configured. For real device testing or production, the plist must be re-downloaded from Firebase Console after setting up an OAuth 2.0 client, and `REVERSED_CLIENT_ID` must be added to `ios/Runner/Info.plist` as a `CFBundleURLTypes` URL scheme. The `Info.plist` has a placeholder `YOUR_REVERSED_CLIENT_ID` entry for this.

4. **Near Me cards in `HomePage` pass a simplified `_Store` to `StorePage`**, but `StorePage` expects the richer `Store` model from `temp_data.dart`. When a user taps a near-me card, `StorePage` receives a stub object. This should be wired to `tempStores` by matching store name or ID.

5. **`AllSetScreen`** receives `firstName` and `lastName` but does not display the name anywhere on screen.

6. **`ProfilePage` reads from `tempUserProfile`** — it does not read Firebase `currentUser` fields (except sign-out). The profile form is not wired to save changes.

7. **Shelves tab** is a placeholder `Center(child: Text('Shelves Page'))`.

8. **`CategoryPage`** is a placeholder "Coming Soon" screen.

9. **"Order now"** and **"Send"** buttons are SnackBar placeholders — no order system exists yet.

10. **`_BowClipper` is duplicated** in `home_page.dart`, `store_page.dart`, and `profile_page.dart`. Should be extracted to `lib/shared/widgets/bow_clipper.dart`.

11. **Login with email/password** works but phone auth is only in the sign-up flow — existing users who log in via email don't go through phone verification again.

---

## Shared Widgets

| Widget | File | Description |
|---|---|---|
| `CustomNavBar` | `lib/shared/widgets/navbar.dart` | 4-tab bottom nav, white + upward shadow |
| `CustomSearchBar` | `lib/shared/widgets/search_bar.dart` | Visual pill search bar, `hintText` param |
| `CustomButton` | `lib/shared/widgets/custom_button.dart` | Full-width rounded button |
| `CustomTextField` | `lib/shared/widgets/custom_textfield.dart` | Labeled text field with focus border |

---

## Firebase Configuration

- **Project:** `sprout-c5452`
- **Auth methods enabled:** Email/Password, Phone
- **Android:** `android/app/google-services.json` present
- **iOS:** `ios/Runner/GoogleService-Info.plist` present but **missing `CLIENT_ID` / `REVERSED_CLIENT_ID`** (see Known Issues #3)
- **macOS:** `macos/Runner/GoogleService-Info.plist` present

---

## Design Conventions

- Font everywhere: `fontFamily: 'SF Pro Display'`
- All screens: `backgroundColor: Colors.white`
- Navigation pattern: `Navigator.push` (stack-based, no named routes)
- Back buttons in auth screens: `Arrow_Left_MD.png` asset tinted `#003E3B`
- Back buttons in content screens (StorePage, ProfilePage): white circle with `Icons.arrow_back`
- Star ratings: `Icons.star` / `Icons.star_half` / `Icons.star_border`, `Colors.amber`, size 12–13
- Prices denominated in **BD** (Bahraini Dinar)

---

## Git

- Repo: `https://github.com/AliHasanJuma/Sprout.git`
- Working branch: `building-UI-ameer`
- Main branch: `main`
- Recent commits (latest first):
  - `1ffdf20` — Fix auth flow, bow clipper, and profile sign-out
  - `a274f19` — Update home page and navbar UI to match Figma design
  - `5815de2` — link the system and remove testfiles

---

## Figma Reference

Design file: `https://www.figma.com/design/E4ujFj3lh00asFDrfYjQO4/Sprout?node-id=6-487`
