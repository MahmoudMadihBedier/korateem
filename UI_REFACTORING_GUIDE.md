# 🎨 MODERN UI REFACTORING GUIDE

## Overview
This guide provides the systematic approach to refactoring all screens to match the modern dark theme with green accents shown in the design screenshots.

## Color Scheme
```dart
// Primary Colors
Primary Green: Color(0xFF43A047)      // Main action color
Light Green: Color(0xFF66BB6A)        // Accents
Dark Surface: Color(0xFF1E1E1E)       // AppBar, surface
Dark Background: Color(0xFF121212)    // Page background
Card Background: Color(0xFF2A2A2A)    // Card color
Border Color: Color(0xFF404040)       // Borders/dividers
Text Primary: Colors.white            // Main text
Text Secondary: Color(0xFFB0B0B0)     // Secondary text
Text Tertiary: Color(0xFF808080)      // Tertiary text
Error Red: Color(0xFFCF6679)          // Error state
Warning Orange: Color(0xFFFF9800)     // Rating/warnings
```

## Architecture Principles (CLAUDE.md)

### 1. Single Responsibility Principle
- Each screen has ONE purpose
- Break complex UIs into reusable components
- Components in `lib/ui/modern_components.dart`

### 2. Open/Closed Principle
- Components are open for extension (parameters)
- Closed for modification (no state changes)

### 3. Dependency Inversion
- Screens depend on repositories (abstraction)
- Not direct Firebase calls

### 4. Clean Code
- Meaningful variable names
- Functions stay < 20 lines
- Comments for complex logic

## Reusable Components Available

### ModernCard
```dart
ModernCard(
  padding: EdgeInsets.all(16),
  backgroundColor: Color(0xFF2A2A2A),
  onTap: () {},
  child: YourContent(),
)
```

### PostCard
```dart
PostCard(
  userName: 'أحمد محمد',
  userInitial: 'أ',
  content: 'محتوى المنشور',
  likes: 25,
  comments: 8,
  isLiked: false,
  onLike: () {},
  onComment: () {},
  onShare: () {},
)
```

### StadiumCard
```dart
StadiumCard(
  name: 'ملعب الهدف',
  location: 'المعادي, القاهرة',
  rating: 4.8,
  price: '250 ريال',
  onTap: () {},
)
```

### UserCard
```dart
UserCard(
  name: 'أحمد محمد',
  position: 'لاعب وسط',
  rating: 4.0,
  matches: 12,
  onTap: () {},
)
```

### ModernAppBar
```dart
ModernAppBar(
  title: 'المنشورات',
  showNotification: true,
  onNotificationTap: () {},
)
```

### EmptyState
```dart
EmptyState(
  icon: Icons.feed,
  title: 'لا توجد منشورات',
  subtitle: 'ابدأ بإنشاء أول منشور',
  actionLabel: 'إنشاء منشور',
  onAction: () {},
)
```

## Screen Refactoring Checklist

### For Each Screen:

- [ ] Import modern_components
- [ ] Update AppBar to ModernAppBar
- [ ] Replace all Cards with ModernCard
- [ ] Update colors to match theme
- [ ] Use ModernLoading for loading states
- [ ] Use EmptyState for empty data
- [ ] Remove old styling code
- [ ] Add proper spacing (SizedBox(height: 8/12/16/24))
- [ ] Test on device
- [ ] Verify error handling
- [ ] Run `dart format` for consistency

## Typography System

```dart
// Display Large (32pt, Bold)
Theme.of(context).textTheme.displayLarge

// Display Medium (28pt, Bold)
Theme.of(context).textTheme.displayMedium

// Title Large (20pt, w600)
Theme.of(context).textTheme.titleLarge

// Title Medium (18pt, w600)
Theme.of(context).textTheme.titleMedium

// Title Small (14pt, w600, gray)
Theme.of(context).textTheme.titleSmall

// Body Large (16pt, w500)
Theme.of(context).textTheme.bodyLarge

// Body Medium (14pt, w400, gray)
Theme.of(context).textTheme.bodyMedium

// Body Small (12pt, w400, dark gray)
Theme.of(context).textTheme.bodySmall
```

## Spacing Standards

```dart
// Minimal spacing (between elements)
SizedBox(height: 8)

// Normal spacing (between sections)
SizedBox(height: 12)
SizedBox(height: 16)

// Large spacing (between major sections)
SizedBox(height: 24)
SizedBox(height: 32)
```

## Button Styles (From Theme)

All buttons automatically styled via theme:
- ElevatedButton → Green with white text
- OutlinedButton → Green border with transparent background
- TextButton → Green text only
- FloatingActionButton → Green with white icon

## Dialog Styling

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: Color(0xFF2A2A2A),
    child: YourContent(),
  ),
)
```

## TextField Styling

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'البحث...',
    filled: true,
    fillColor: Color(0xFF2A2A2A),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF404040)),
    ),
  ),
  style: TextStyle(color: Colors.white),
)
```

## Navigation Patterns

### Named Route
```dart
Navigator.pushNamed(
  context,
  '/social-feed',
  arguments: {'userId': userId},
);
```

### Direct Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ScreenName()),
);
```

## State Management Pattern

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // Repositories
  final _repository = MyRepository();
  
  // Controllers
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(title: 'Title'),
      body: StreamBuilder(
        stream: _repository.getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ModernLoading();
          }
          
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error,
              title: 'خطأ',
            );
          }
          
          if (!snapshot.hasData) {
            return EmptyState(
              icon: Icons.inbox,
              title: 'لا توجد بيانات',
            );
          }
          
          return ListView(...);
        },
      ),
    );
  }
}
```

## Error Handling Pattern

```dart
try {
  await _repository.performAction();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('نجح'),
      backgroundColor: Color(0xFF43A047),
    ),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('خطأ: $e'),
      backgroundColor: Color(0xFFCF6679),
    ),
  );
}
```

## Dialog Pattern

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: Color(0xFF2A2A2A),
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Title', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          // Content
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
              ElevatedButton(onPressed: () {}, child: Text('تأكيد')),
            ],
          ),
        ],
      ),
    ),
  ),
);
```

## RTL (Right-to-Left) Handling

```dart
// For text input fields that need RTL
TextField(
  textDirection: TextDirection.rtl,
  textAlign: TextAlign.right,
)

// For row layouts (automatic via Flutter)
Row(
  mainAxisAlignment: MainAxisAlignment.start,  // Will flip for RTL
  children: [...],
)
```

## Performance Optimization

1. Use `const` constructors where possible
2. Avoid rebuilds with `StreamBuilder` instead of `FutureBuilder`
3. Use lazy loading for lists
4. Dispose controllers in `dispose()` method
5. Cache expensive computations

## Quality Checklist Before Commit

- [ ] Code compiles without errors
- [ ] No unused imports
- [ ] No unused variables
- [ ] Proper null safety
- [ ] Error handling present
- [ ] Loading states handled
- [ ] Empty states handled
- [ ] RTL compatible
- [ ] Consistent spacing
- [ ] Follows CLAUDE.md principles
- [ ] Comments on complex logic
- [ ] Tested on device

## Next Steps

1. Create refactored screens using components
2. Test each screen individually
3. Verify navigation between screens
4. Test error scenarios
5. Deploy to device for final testing

---

**Remember**: Clean architecture and SOLID principles make this codebase maintainable for future features!
