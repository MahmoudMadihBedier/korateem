# كورة تيم - Firebase Configuration Guide

## ✅ App Status
- **Compilation:** ✅ FIXED (0 hard errors)
- **Login/Signup UI:** ✅ MODERNIZED (Egyptian football themed)
- **Google Sign-in:** ⚠️ REQUIRES Firebase Setup
- **Email/Password Auth:** ⚠️ REQUIRES Firebase Setup

## 🔴 Current Issues & Solutions

### Issue 1: Google Sign-in Error (API Exception 10)
**Error from logs:**
```
com.google.android.gms.common.api.ApiException: 10:
```

**Root Cause:** Google Sign-in configuration issue or SHA-1 fingerprint mismatch

**Solution:**
1. Get your app's SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. Copy the SHA-1 hash (looks like: `AA:BB:CC:DD...`)

3. In Firebase Console:
   - Go to Project Settings → Your Apps → Select Android app
   - Add the SHA-1 fingerprint to "SHA certificate fingerprints"
   - Download `google-services.json` again
   - Replace file at: `android/app/google-services.json`

4. Sync Gradle:
   ```bash
   cd android && ./gradlew clean
   ```

### Issue 2: "Operation Not Allowed" - Firebase Email/Password Auth Not Enabled
**Error from logs:**
```
This operation is not allowed. This may be because the given sign-in provider 
is disabled for this Firebase project. Enable it in the Firebase console
```

**Solution:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to: **Authentication → Sign-in method**
4. Enable **Email/Password** auth provider:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

5. Also enable **Google** provider:
   - Click on "Google"
   - Toggle "Enable"
   - Select project support email
   - Click "Save"

### Issue 3: Missing Google Logo Asset
**Error from logs:**
```
Unable to load asset: "assets/google_logo.png"
```

**Status:** ✅ FIXED
- Removed asset dependency
- Now using emoji icon (🔵) as placeholder

## 🔧 Firebase Setup Checklist

### Step 1: Firebase Project Setup
- [ ] Create Firebase project at [firebase.google.com](https://firebase.google.com)
- [ ] Create Android app in Firebase console
- [ ] Create iOS app in Firebase console (if testing on iOS)
- [ ] Download `google-services.json` for Android
- [ ] Place `google-services.json` in `android/app/` directory

### Step 2: Enable Authentication Methods
- [ ] Email/Password authentication enabled
- [ ] Google Sign-in enabled
- [ ] Set app verification method (SMS or silent verification)

### Step 3: Update Firebase Configuration
- [ ] Android SHA-1 fingerprint added
- [ ] iOS bundle ID configured
- [ ] Web domain added (if deploying web version)

### Step 4: Create Firestore Database
- [ ] Go to Firestore Database
- [ ] Click "Create database"
- [ ] Start in Test Mode (for development)
- [ ] Choose region (e.g., us-central1)
- [ ] Create

### Step 5: Set Firestore Security Rules
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - read own, write own
    match /users/{uid} {
      allow read: if request.auth.uid == uid;
      allow write: if request.auth.uid == uid;
    }
    
    // Fields collection - read all, write owner
    match /fields/{fieldId} {
      allow read: if true;
      allow write: if request.auth.uid == resource.data.ownerId;
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if request.auth.uid == resource.data.userId;
    }
    
    // Teams collection
    match /teams/{teamId} {
      allow read: if true;
      allow write: if request.auth.uid == resource.data.captainId;
    }
  }
}
```

## 🛠️ Android Configuration

### AndroidManifest.xml Changes
The `android/app/src/main/AndroidManifest.xml` should already have:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### build.gradle.kts Setup
Should already be configured with:
```gradle
plugins {
    id "com.google.gms.google-services" version "4.3.14"
}
```

## 📱 Testing the App

### Manual Test Steps

**1. Email/Password Registration:**
```
1. Open app → Click "إنشاء حساب جديد"
2. Fill form:
   - Name: أحمد علي
   - Email: test@example.com
   - Phone: +201012345678
   - Password: Password123
   - Confirm: Password123
3. Accept terms
4. Click "إنشاء الحساب"
Expected: Account created, auto-login, redirect to home
```

**2. Email/Password Login:**
```
1. Open app → Login Screen
2. Enter email & password from step 1
3. Click "تسجيل الدخول"
Expected: Login success, redirect to home
```

**3. Google Sign-in:**
```
1. Open app → Click Google button
2. Select Google account
3. Authorize app
Expected: Auto-login, user data populated, redirect to home
```

## 🐛 Troubleshooting

### Problem: "Unable to find Google Account"
**Solution:**
- Add Google account to device
- Settings → Accounts → Add Google Account
- Restart app

### Problem: SHA-1 fingerprint wrong
**Solution:**
```bash
cd android
./gradlew signingReport
# Copy debug SHA-1, add to Firebase console
# In Firebase: Project Settings → Apps → SHA certificates
```

### Problem: "google-services.json not found"
**Solution:**
```bash
# Verify file exists
ls -la android/app/google-services.json

# If missing, download from Firebase Console:
# 1. Firebase Console → Project Settings
# 2. Click "google-services.json" download button
# 3. Place in android/app/
```

### Problem: "Cannot connect to Firebase"
**Solution:**
- Check internet connection
- Verify Firebase database is created
- Check Firestore security rules allow reads

## 📊 Expected Data Flow

### Registration Flow
```
User Input → Validation → Firebase Auth → Create User Profile
         ↓
    Success → Save to Firestore → Navigate to Home
         ↓
    Error → Show Arabic Error Message
```

### Login Flow
```
Email + Password Input → Firebase Auth → Validate Credentials
         ↓
    Success → Load User Profile → Navigate to Home
         ↓
    Error → Show Arabic Error Message
```

### Google Sign-in Flow
```
User Clicks Google → Google Account Selection → Firebase Auth
         ↓
    Success → Create/Link Firebase User → Navigate to Home
         ↓
    Error → Show Arabic Error Message
```

## 🔐 Current Auth State Management

### AuthService Changes Made
✅ Enhanced Google Sign-in with proper error handling
✅ Added errorMessage property for UI display
✅ Improved error messages in Arabic:
- "operation-not-allowed" → "هذه الطريقة غير مفعلة..."
- "too-many-requests" → "محاولات كثيرة جداً..."
- "network-request-failed" → "خطأ في الاتصال بالإنترنت"

### UI Changes Made
✅ Responsive Egyptian football-themed login screen
✅ Responsive sign-up screen with validation
✅ Better error/success feedback with icons
✅ Removed asset dependencies (using emojis instead)

## ✅ Next Steps After Firebase Setup

```bash
# 1. Run app with Firebase configured
flutter run

# 2. Test all auth flows:
- Email registration
- Email login
- Google sign-in
- Error messages

# 3. Verify data in Firestore:
- Firebase Console → Firestore → users collection
- Check if user profiles created correctly

# 4. Test other features:
- Field discovery
- Booking system
- Team management
```

## 📞 Support

If you encounter issues:
1. Check Firebase console for error details
2. Verify all auth methods are enabled
3. Check SHA-1 fingerprint in Firebase
4. Ensure google-services.json is in correct location
5. Check internet connectivity
6. Clear app cache: `adb shell pm clear com.korateem.app`

---

**Status: Ready for Firebase Integration** ✅

The app now has:
- Modern Egyptian football-themed UI
- Responsive design for all screen sizes
- Improved error handling and messages
- Proper form validation
- Zero compilation errors

Just complete the Firebase setup and the app will be fully functional!
