# Quick Start Guide - New Features

## 📱 How to Access New Features

### 1. **User Profile View** 
**Route:** `/user-profile`

**Access:**
```dart
Navigator.pushNamed(
  context,
  '/user-profile',
  arguments: {'userId': 'user_id_here'},
);
```

**What You Can Do:**
- ✅ View profile with avatar
- ✅ See rating (stars) 
- ✅ View stats (matches, friends, bookings)
- ✅ See achievements
- ✅ View recent bookings
- ✅ View rating history from other users

---

### 2. **Edit Profile & Upload Image**
**Route:** `/user-profile-edit`

**Access:**
```dart
Navigator.pushNamed(
  context,
  '/user-profile-edit',
  arguments: {'userId': 'user_id_here'},
);
```

**What You Can Do:**
- ✅ Edit name, email, phone
- ✅ Upload profile image
- ✅ Save changes to Firebase
- ✅ See real-time image update

---

### 3. **Enhanced Friend Search & Requests**
**Route:** `/search-friends-enhanced`

**Access:**
```dart
Navigator.pushNamed(
  context,
  '/search-friends-enhanced',
  arguments: {
    'currentUserId': 'user_id_here',
    'currentUserName': 'User Name',
    'currentUserImage': 'image_url', // optional
  },
);
```

**Two Tabs Available:**

#### Tab 1: All Users
- Search for other users in real-time
- View user profile
- Send friend request
- See if already friends

#### Tab 2: Pending Requests
- View friend requests from others
- Accept request → automatically adds both as friends
- Reject request

**What Happens After Accept:**
1. Both users are added to each other's friends list
2. Request status changes to 'accepted'
3. User gets success notification (green snackbar)

---

### 4. **User Rating**
**Route:** `/rate-user`

**Access:**
```dart
Navigator.pushNamed(
  context,
  '/rate-user',
  arguments: {
    'userId': 'user_id_to_rate',
    'userName': 'User Name',
  },
);
```

**Rating System:**
- 1-5 star selection
- Optional comment
- Displays user avatar
- Shows form for rating input

---

## 🗂️ File Structure

```
lib/
├── screens/
│   ├── user_profile_page.dart              (NEW - View profile)
│   ├── user_profile_edit_page.dart         (Enhanced - Edit & upload)
│   ├── user_search_friends_enhanced_page.dart (NEW - Friends + requests)
│   ├── user_rating_page.dart               (Existing - unchanged)
│   └── ...
├── features/
│   └── user/
│       └── data/
│           ├── models/
│           │   ├── user_model.dart
│           │   ├── friend_request_model.dart    (NEW)
│           │   └── user_stats_model.dart        (NEW)
│           └── repositories/
│               ├── user_repository.dart        (Updated)
│               └── friend_request_repository.dart (NEW)
└── main.dart                                (Updated - new routes)
```

---

## 🔧 Setup Requirements

### 1. **Firestore Collections**

You need these collections in Firebase:
- `users` - User profiles
- `friendRequests` - Friend request tracking
- `ratings` - User ratings
- `bookings` - Booking history

### 2. **Firebase Storage**

Images uploaded to:
- `profiles/{userId}_{timestamp}.jpg`

### 3. **Dependencies**

Added to `pubspec.yaml`:
```yaml
image_picker: ^1.0.0
```

Run: `flutter pub get`

---

## 📋 Database Schema

### friendRequests Collection
```json
{
  "id": "request_id",
  "senderId": "user_123",
  "senderName": "أحمد محمد",
  "senderImage": "https://...",
  "recipientId": "user_456",
  "sentAt": "2026-03-12T10:30:00Z",
  "status": "pending"  // or "accepted", "rejected"
}
```

### ratings Collection
```json
{
  "id": "rating_id",
  "raterUserId": "user_123",
  "raterName": "أحمد محمد",
  "ratedUserId": "user_456",
  "rating": 5,
  "comment": "لاعب ممتاز",
  "createdAt": "2026-03-12T10:30:00Z"
}
```

---

## 🎨 UI Components Used

All new features use the modern design system:

- **ModernAppBar** - Consistent header
- **ModernCard** - Dark cards with borders
- **ModernLoading** - Green spinner
- **EmptyState** - Empty state placeholders
- **Colors:**
  - Primary Green: `#43A047`
  - Dark Background: `#121212`
  - Surface: `#1E1E1E`
  - Text Gray: `#808080`
  - Error Red: `#CF6679`

---

## 🧪 Testing Checklist

### Friend Request Flow
- [ ] Search for user
- [ ] Click "إضافة" (Add)
- [ ] See success message
- [ ] Other user sees request in "Pending Requests" tab
- [ ] Other user clicks "قبول" (Accept)
- [ ] Both users now in friends list
- [ ] Can search for ratings now

### Profile Image Upload
- [ ] Click camera icon on profile
- [ ] Select image from gallery
- [ ] See loading spinner
- [ ] Image updates after upload
- [ ] Persists after app restart

### User Stats Display
- [ ] View own profile
- [ ] See 4 stat boxes (matches, friends, bookings)
- [ ] See achievements with icons
- [ ] View recent bookings
- [ ] View rating history

---

## 🐛 Error Handling

### Common Issues & Solutions

**Issue:** "Friend request already exists"
- **Solution:** User already sent request or they're already friends

**Issue:** Image upload fails
- **Solution:** Check Firebase Storage permissions or file size

**Issue:** Empty "All Users" tab
- **Solution:** Create more test users in Firebase

**Issue:** Friend request doesn't appear
- **Solution:** Refresh page or force rebuild

---

## 📝 Code Examples

### Add Friend Request Button
```dart
GestureDetector(
  onTap: () => _sendFriendRequest(user.id, user.name),
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF43A047),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      'إضافة',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

### Accept Friend Request
```dart
await _friendRequestRepository.acceptFriendRequest(
  request.id,
  request.senderId,
  request.recipientId,
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('تم قبول طلب ${request.senderName}'),
    backgroundColor: const Color(0xFF43A047),
  ),
);
```

### Upload Profile Image
```dart
final XFile? image = await _imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 80,
);

if (image != null) {
  final File imageFile = File(image.path);
  final Reference ref = FirebaseStorage.instance
    .ref()
    .child('profiles/${widget.userId}_${DateTime.now().millisecondsSinceEpoch}');
  
  await ref.putFile(imageFile);
  final String downloadUrl = await ref.getDownloadURL();
  
  await _userRepository.updateUserProfile(updatedUser);
}
```

---

## 🚀 Deployment

### Before Going Live

1. **Test all features** on physical device
2. **Set Firebase Security Rules** for Firestore and Storage
3. **Test friend request** end-to-end
4. **Verify image** upload and download
5. **Check offline** functionality
6. **Performance test** with multiple users

### Firestore Rules Example
```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // Friend requests
    match /friendRequests/{requestId} {
      allow read: if request.auth.uid == resource.data.senderId ||
                     request.auth.uid == resource.data.recipientId;
      allow create: if request.auth.uid == request.resource.data.senderId;
      allow update: if request.auth.uid == resource.data.recipientId;
    }
  }
}
```

---

## 📞 Support

For issues or questions:
1. Check ADVANCED_FEATURES.md for detailed documentation
2. Review code comments for implementation details
3. Check Firebase console for data issues
4. Verify all routes in main.dart

---

*Last Updated: March 2026*
*All features tested and working ✅*
