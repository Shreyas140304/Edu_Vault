# EduVault - Quick Start Guide

Get up and running with EduVault development in 5 minutes!

## 📦 Prerequisites

Before starting, ensure you have:

- Flutter SDK 3.10.7 or higher
- Chrome (for web), Android emulator, or iOS simulator
- Git (for version control)

## ⚡ 5-Minute Setup

### 1. Install Dependencies (2 minutes)

```bash
cd eduvault
flutter pub get
```

### 2. Generate Code (1 minute)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App (2 minutes)

```bash
# For Android
flutter run

# For iOS
flutter run -d iPhone

# For Web
flutter run -d chrome
```

## 📱 First Run

When you first run the app:

1. **Splash Screen** appears with animation
2. **Profile Setup** wizard launches
3. Fill in your details (name, school, board, college, university, state, country)
4. Select target entrance exams
5. Complete setup
6. **Dashboard** opens showing your academic stages

## 🎯 Key Features to Explore

### Dashboard

- **Stages Tab**: See all education stages with progress
- **Exams Tab**: Manage entrance exams and deadlines
- **Overview Tab**: Quick statistics and recent documents

### Upload Documents

- Tap the **floating action button** (+ button) to upload documents
- Select from gallery, camera, or files
- OCR automatically detects document type
- Save to the correct stage

### Search Documents

- Use the **search icon** in the header
- Find documents by name or content
- Filter by stage and category

## 🔧 Development Workflow

### Adding a New Feature

1. **Create the screen**:

   ```bash
   touch lib/screens/my_feature_screen.dart
   ```

2. **Add to router**:

   ```dart
   // In lib/config/router.dart
   case '/my-feature':
     return MaterialPageRoute(builder: (_) => const MyFeatureScreen());
   ```

3. **Navigate to it**:
   ```dart
   Navigator.of(context).pushNamed('/my-feature');
   ```

### Modifying Models

1. **Update the model** (e.g., `document_model.dart`)
2. **Run code generation**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. **The adapter files are auto-generated**

### Using Provider

All state management uses Provider pattern:

```dart
// Read state
final documents = context.read<DocumentProvider>().documents;

// Listen for changes
Consumer<DocumentProvider>(
  builder: (context, provider, _) {
    return ListView(
      children: provider.documents
        .map((doc) => DocumentCard(doc: doc))
        .toList(),
    );
  },
)

// Trigger action
await context.read<DocumentProvider>().uploadDocument(file, stage);
```

### Database Operations

```dart
// Get database service
final dbService = DatabaseService();

// Save user profile
await dbService.saveUserProfile(userProfile);

// Get all documents
final documents = dbService.getAllDocuments();

// Search documents
final results = dbService.searchDocuments('marksheet');

// Delete document
await dbService.deleteDocument(documentId);
```

## 🎨 UI/UX Patterns

### Colors

```dart
// Use AppColors constants
AppColors.primary           // Main brand color
AppColors.secondary         // Success/secondary
AppColors.error            // Error/warning
AppColors.textPrimary      // Main text
AppColors.textSecondary    // Secondary text
```

### Text Styles

```dart
// Use theme text styles
Theme.of(context).textTheme.headlineSmall
Theme.of(context).textTheme.bodyLarge
Theme.of(context).textTheme.labelSmall
```

### Cards and Widgets

```dart
// Standard card
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Your content'),
  ),
)

// Use provided widgets
StageCard(...)
ExamCard(...)
```

## 🐛 Common Issues & Solutions

### Issue: Hive Box not found

**Solution**: Run build_runner again

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Module import errors

**Solution**: Clean and rebuild

```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

### Issue: Emulator not starting

**Solution**: Start emulator first

```bash
emulator -avd Pixel_4_API_31
```

## 📊 Project Structure at a Glance

```
lib/
├── main.dart              ← App entry point
├── config/router.dart     ← Navigation routes
├── constants/             ← Colors, strings, config
├── models/                ← Data models (with Hive adapters)
├── services/              ← Business logic (Database, OCR, Storage)
├── providers/             ← State management
├── screens/               ← UI screens
└── widgets/               ← Reusable components
```

## 🚀 Next Steps

1. **Understand Models**: Check `lib/models/` for data structures
2. **Explore Providers**: See `lib/providers/` for state management
3. **Browse Screens**: Look at `lib/screens/` for UI patterns
4. **Check Services**: Review `lib/services/` for business logic
5. **Read Implementation Guide**: See `IMPLEMENTATION_GUIDE.md` for feature details

## 📚 Useful Commands

```bash
# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release

# Build Web
flutter build web --release

# View widget tree
flutter run --devtools
```

## 🤔 Frequently Asked Questions

**Q: How do I add a new screen?**
A: Create file in `screens/`, add to router, navigate with `Navigator.pushNamed()`

**Q: How do I trigger a provider update?**
A: Call provider method and it auto-notifies listeners via `notifyListeners()`

**Q: Where do I store app constants?**
A: Use `lib/constants/app_constants.dart` for config and `app_colors.dart` for theme

**Q: How do I make API calls in future?**
A: Services in `lib/services/` handle all business logic

**Q: How is data persisted?**
A: Hive database stores all data locally in `lib/services/database_service.dart`

## 📞 Need Help?

- **Errors**: Check `flutter analyze` output
- **Packages**: Check `pubspec.yaml` for versions
- **Logic**: Trace through Provider → Service → Database
- **UI**: Check constants and existing screens for patterns

## Happy Coding! 🎉

Remember: Read the code, understand the patterns, follow the conventions!

---

**Version**: 1.0.0
**Last Updated**: April 2026
