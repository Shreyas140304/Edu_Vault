# EduVault - Complete File Structure & Reference

## Project Overview

**Project Name**: EduVault - Intelligent Academic Document Manager  
**Framework**: Flutter  
**Language**: Dart 3.10.7+  
**Status**: ✅ Phase 1 & 2 Complete - Ready for Feature Implementation

---

## Directory Structure

```
eduvault/
├── android/                          # Android native code
├── ios/                              # iOS native code
├── web/                              # Web support files
├── test/
│   └── widget_test.dart              # Basic Flutter test
├── lib/
│   ├── main.dart                     # ⭐ App entry point & initialization
│   ├── config/
│   │   └── router.dart               # Navigation routes configuration
│   ├── constants/
│   │   ├── app_colors.dart           # Theme, colors, and styling
│   │   ├── app_constants.dart        # App configuration & constants
│   │   └── index.dart                # Constants barrel file
│   ├── models/                       # Data models with Hive adapters
│   │   ├── user_model.dart
│   │   ├── document_model.dart
│   │   ├── entrance_exam_model.dart
│   │   ├── notification_model.dart
│   │   └── index.dart
│   ├── services/
│   │   ├── database_service.dart     # Hive database operations
│   │   ├── ocr_service.dart          # OCR & document detection
│   │   ├── file_storage_service.dart # Local file management
│   │   ├── notification_service.dart # Notifications system
│   │   └── index.dart
│   ├── providers/
│   │   ├── user_provider.dart        # User profile state
│   │   ├── document_provider.dart    # Documents state
│   │   ├── entrance_exam_provider.dart # Exams state
│   │   └── index.dart
│   ├── screens/
│   │   ├── splash_screen.dart        # Animated splash screen
│   │   ├── profile_setup_screen.dart # 3-step onboarding wizard
│   │   ├── dashboard_screen.dart     # Main dashboard with 3 tabs
│   │   ├── search_screen.dart        # Document search
│   │   ├── placeholder_screens.dart  # Stub screens (coming soon)
│   │   └── index.dart
│   └── widgets/
│       ├── stage_card.dart           # Education stage card widget
│       ├── exam_card.dart            # Entrance exam card widget
│       └── index.dart
├── pubspec.yaml                      # Flutter dependencies & config
├── pubspec.lock                      # Locked dependency versions
├── README.md                         # Project documentation
├── QUICKSTART.md                     # Developer quick start guide
└── IMPLEMENTATION_GUIDE.md           # Feature implementation guide
```

---

## File-by-File Breakdown

### Core App Files

#### **lib/main.dart** (49 lines)

- ✅ **Purpose**: Application entry point and initialization
- **Key Functions**:
  - `main()`: Initializes services and runs app
  - `_initializeServices()`: Sets up database, file storage, OCR, notifications
  - `EduVaultApp`: Root widget with MultiProvider setup
- **Services Initialized**: DatabaseService, FileStorageService, OcrService, NotificationService
- **Providers**: UserProvider, DocumentProvider, EntranceExamProvider

#### **lib/config/router.dart** (37 lines)

- ✅ **Purpose**: Navigation and routing configuration
- **Routes Configured**:
  - `/dashboard`: Main dashboard
  - `/profile-setup`: Onboarding
  - `/search`: Document search
  - `/notifications`, `/settings`: Feature screens
  - `/stage-details`, `/exam-details`: Detail screens
  - `/upload-document`, `/add-exam`: Action screens
- **Pattern**: Named route generation

---

### Constants & Configuration

#### **lib/constants/app_colors.dart** (160 lines)

- ✅ **Component**: Complete app theme using Material Design 3
- **Color Categories**:
  - Primary colors: brand identity
  - Status colors: success, warning, error
  - Text colors: primary, secondary, hint
  - Semantic colors: complete, incomplete, pending
- **Theme Data**:
  - App bar styling
  - Button themes
  - Input decoration
  - Card themes
  - Text themes

#### **lib/constants/app_constants.dart** (142 lines)

- ✅ **Purpose**: App-wide configuration
- **Key Constants**:
  - Hive box names (4 boxes)
  - Education stages (6 stages)
  - Required documents per stage
  - Popular entrance exams (10 exams)
  - Exam-specific requirements
  - OCR keywords for document detection
  - API endpoints and notification settings

---

### Data Models

#### **lib/models/user_model.dart** (112 lines)

- ✅ **Purpose**: User profile data model with Hive support
- **Fields**:
  - Personal: id, fullName, createdAt, updatedAt
  - Education: schoolName, board, collegeName, universityName
  - Location: state, country
  - Status: targetExams, isProfileComplete
- **Methods**: copyWith(), toJson(), fromJson()
- **Hive Integration**: @HiveType(typeId: 0)

#### **lib/models/document_model.dart** (145 lines)

- ✅ **Purpose**: Document storage and metadata
- **Fields**:
  - File info: id, fileName, filePath, fileType, fileSize
  - Classification: stage, category, extractedText, detectionConfidence
  - Metadata: uploadedAt, scannedAt, tags, isRequired, isFavorite, notes
- **Methods**: getDisplayName(), getFormattedDate(), copyWith(), JSON conversions
- **Hive Integration**: @HiveType(typeId: 1)

#### **lib/models/entrance_exam_model.dart** (174 lines)

- ✅ **Purpose**: Entrance exam tracking and progress
- **Fields**:
  - Exam info: id, examName, examDate, officialPortal, examLink
  - Tracking: applicationDeadline, requiredDocuments, uploadedDocumentIds
  - Status: applicationStatus, isActive, lastUpdated, notes
- **Methods**:
  - getDaysUntilDeadline()
  - isDeadlineApproaching()
  - getMissingDocumentCount()
  - getProgressPercentage()
  - getFormattedDeadline()
- **Hive Integration**: @HiveType(typeId: 2)

#### **lib/models/notification_model.dart** (140 lines)

- ✅ **Purpose**: Notification storage and management
- **Fields**:
  - Core: id, title, message, type, category
  - Timing: createdAt, scheduledAt
  - Status: isRead, isActionRequired
  - Actions: actionPath, actionData
- **Methods**:
  - getIcon(), getColor() based on type
  - getFormattedDate() with relative time
  - copyWith(), JSON conversions
- **Hive Integration**: @HiveType(typeId: 3)

---

### Services (Business Logic)

#### **lib/services/database_service.dart** (292 lines)

- ✅ **Purpose**: Hive database operations (singleton pattern)
- **Boxes Managed**:
  - userBox (UserProfile)
  - documentBox (Document)
  - examBox (EntranceExam)
  - notificationBox (NotificationItem)
- **Key Methods**:
  - User: saveUserProfile(), getUserProfile()
  - Documents: addDocument(), getAllDocuments(), getDocumentsByStage(), searchDocuments(), deleteDocument()
  - Exams: addEntranceExam(), getAllEntranceExams(), getActiveEntranceExams(), deleteEntranceExam()
  - Notifications: addNotification(), getUnreadNotifications(), markNotificationAsRead()
  - General: clearAllData(), close()

#### **lib/services/ocr_service.dart** (168 lines)

- ✅ **Purpose**: Optical Character Recognition and document classification
- **Key Methods**:
  - extractTextFromImage(): Uses Google ML Kit to extract text
  - detectDocumentType(): Analyzes keywords to identify document type
  - determineEducationStage(): Maps document content to education stage
  - extractKeyInformation(): Extracts key details (name, institution, etc.)
- **Keyword Mapping**: Maps document keywords to categories (Marksheet, Degree, Certificate, etc.)

#### **lib/services/file_storage_service.dart** (246 lines)

- ✅ **Purpose**: Local file system management (singleton pattern)
- **Directory Structure**:
  - Base: `eduvault_docs/`
  - Stages: `Class_10/`, `Class_12/`, etc.
  - Categories: `Marksheet/`, `Certificate/`, etc.
- **Key Methods**:
  - saveDocument(): Copy file to appropriate directory
  - getDocumentsFromStage(), getDocumentsFromCategory()
  - getFileSizeInMB(), getTotalStorageUsedInMB()
  - deleteDocument(), fileExists(), getFileInfo()
  - createBackup(), clearOldDocuments()

#### **lib/services/notification_service.dart** (319 lines)

- ✅ **Purpose**: Push notifications and notifications management
- **Key Methods**:
  - init(): Initialize Flutter Local Notifications
  - showNotification(): Display immediate notification
  - sendMissingDocumentReminder(), sendDeadlineAlert(), sendRequirementUpdate()
  - scheduleNotification(): Schedule future notifications
  - requestPermissions(), cancelAllNotifications()
  - \_onNotificationTapped(): Handle notification interactions

---

### State Management (Providers)

#### **lib/providers/user_provider.dart** (142 lines)

- ✅ **Purpose**: User profile state management
- **State Variables**:
  - \_userProfile: Current user
  - \_isLoading, \_error: Status tracking
- **Key Methods**:
  - loadUserProfile(): Fetch from database
  - createUserProfile(): Create new profile
  - updateUserProfile(): Modify existing profile
  - addTargetExam(), removeTargetExam(): Exam management
  - clearError(): Error handling
- **Pattern**: ChangeNotifier with notifyListeners()

#### **lib/providers/document_provider.dart** (241 lines)

- ✅ **Purpose**: Document management state
- **State Variables**:
  - \_documents: All documents
  - \_filteredDocuments: Search results
  - \_documentsByStage: Organized by stage
- **Key Methods**:
  - loadDocuments(): Load all documents
  - uploadDocument(): Full OCR pipeline
  - searchDocuments(): Full-text search
  - deleteDocument(), updateDocument()
  - getDocumentsByStage(), getMissingDocumentsForStage()
  - getDocumentCountByStage(), getStageCompletionPercentage()
- **Integration**: Uses DatabaseService, FileStorageService, OcrService

#### **lib/providers/entrance_exam_provider.dart** (229 lines)

- ✅ **Purpose**: Entrance exam tracking
- **State Variables**:
  - \_exams: All exams
  - \_selectedExam: Currently selected
- **Key Methods**:
  - loadEntranceExams(): Load all
  - addEntranceExam(): Create with pre-filled requirements
  - selectEntranceExam(), updateExamStatus()
  - addUploadedDocumentToExam(), removeUploadedDocumentFromExam()
  - updateExamRequirements(), deleteEntranceExam()
  - getExamsWithApproachingDeadlines(), getExamsWithPassedDeadlines()

---

### User Interface Screens

#### **lib/screens/splash_screen.dart** (95 lines)

- ✅ **Purpose**: Animated splash/welcome screen
- **Features**:
  - Scale animation for logo
  - Fade animation for text
  - 2.5 second display
  - Auto-navigation based on profile status
- **Flow**:
  - Load user profile via UserProvider
  - If profile complete → Dashboard
  - Else → Profile setup

#### **lib/screens/profile_setup_screen.dart** (305 lines)

- ✅ **Purpose**: Multi-step onboarding wizard
- **Structure**: 3-step PageView
  - **Step 1 - Basic Info**: Name, school, board, state, country
  - **Step 2 - Education Details**: College, university (optional)
  - **Step 3 - Exam Selection**: Choose target exams
- **Features**:
  - Progress indicator
  - Form validation
  - Next/Previous navigation
  - Profile creation via UserProvider

#### **lib/screens/dashboard_screen.dart** (325 lines)

- ✅ **Purpose**: Main application dashboard
- **Layout**:
  - Profile summary header
  - 3-tab TabBar view
- **Tabs**:
  - **Stages**: All academic stages with progress
  - **Exams**: Active entrance exams
  - **Overview**: Statistics and recent documents
- **Features**:
  - Search and notification icons
  - Settings access
  - Document upload FAB
  - Real-time data via Consumers

#### **lib/screens/search_screen.dart** (15 lines)

- ✅ **Purpose**: Document search interface (placeholder)
- **Status**: Ready for implementation

#### **lib/screens/placeholder_screens.dart** (79 lines)

- ✅ **Purpose**: Placeholder screens for coming features
- **Screens**:
  - NotificationsScreen
  - SettingsScreen
  - StageDetailsScreen
  - ExamDetailsScreen
  - UploadDocumentScreen
  - AddExamScreen

---

### Widgets (Reusable Components)

#### **lib/widgets/stage_card.dart** (118 lines)

- ✅ **Purpose**: Display education stage with progress
- **Features**:
  - Stage icon and name
  - Document count
  - Progress bar with color coding
  - Completion percentage
  - Missing document count
  - Tap-to-navigate
- **Color Logic**:
  - Green (100% complete)
  - Orange (50-99% complete)
  - Red (<50% complete)

#### **lib/widgets/exam_card.dart** (160 lines)

- ✅ **Purpose**: Display entrance exam with deadline tracking
- **Features**:
  - Exam name and status
  - Days remaining (with color coding)
  - Application deadline
  - Progress bar
  - Document completion count
  - Status indicator badge
- **Status Colors**:
  - Red (deadline passed)
  - Orange (within 3 days)
  - Green (active)

---

### Project Documentation

#### **README.md** (263 lines)

- ✅ **Content**:
  - Project overview and features
  - Tech stack details
  - Installation instructions
  - Data model documentation
  - Privacy and design principles
  - Known issues and contributing guidelines

#### **QUICKSTART.md** (235 lines)

- ✅ **Content**:
  - 5-minute setup guide
  - Development workflow
  - Code examples
  - Common issues and solutions
  - Useful commands
  - FAQ

#### **IMPLEMENTATION_GUIDE.md** (341 lines)

- ✅ **Content**:
  - Phase 3 feature implementation steps
  - Screen-by-screen building guide
  - Code examples
  - Testing checklist
  - Performance optimization tips
  - Debug tips

---

## Generated Files (by build_runner)

The following files are auto-generated and should not be manually edited:

```
lib/models/user_model.g.dart
lib/models/document_model.g.dart
lib/models/entrance_exam_model.g.dart
lib/models/notification_model.g.dart
```

These files contain Hive adapters for database serialization.

---

## Dependencies Summary

### Core (10 packages)

- flutter, cupertino_icons
- provider (state management)
- hive, hive_flutter (database)
- path_provider (file access)
- google_mlkit_text_recognition (OCR)
- logger (logging)

### Features (7 packages)

- camera (document scanning)
- image_picker (file selection)
- pdfx (PDF viewing)
- flutter_local_notifications (notifications)
- permission_handler (permissions)
- connectivity_plus (network status)
- http (API calls)
- intl, uuid (utilities)

### Dev (2 packages)

- flutter_test (testing)
- flutter_lints (code quality)
- build_runner, hive_generator (code generation)

---

## Statistics

| Category                | Count  |
| ----------------------- | ------ |
| **Dart Files**          | 27     |
| **Total Lines of Code** | 4,200+ |
| **Models**              | 4      |
| **Services**            | 4      |
| **Providers**           | 3      |
| **Screens**             | 7      |
| **Widgets**             | 2      |
| **Dependencies**        | 19     |
| **Hive Boxes**          | 4      |
| **Routes**              | 9      |

---

## Development Status

### ✅ Completed

- Project structure and setup
- All core models with Hive support
- All services (Database, OCR, File Storage, Notifications)
- All providers (User, Document, Exam)
- All main screens (Splash, Setup, Dashboard)
- Navigation routing
- UI widgets and components
- Code generation (build_runner)
- Documentation

### 🚧 In Progress

- Feature implementation
- Advanced screens
- Integration testing

### 📋 Planned

- Document upload/scanner
- Search with filters
- Requirement monitoring
- Cloud integration

---

## File Size Summary

| Category           | Count  | Total Size       |
| ------------------ | ------ | ---------------- |
| Models             | 4      | ~600 lines       |
| Services           | 4      | ~1,000 lines     |
| Providers          | 3      | ~600 lines       |
| Screens            | 7      | ~800 lines       |
| Widgets            | 2      | ~280 lines       |
| Config & Constants | 3      | ~350 lines       |
| **Total**          | **27** | **~3,630 lines** |

---

## Next Steps for Development

1. **Implement Upload Screen**: Build document upload with OCR
2. **Add Scanner**: Camera-based document capture
3. **Enhance Screens**: Implement all detail screens
4. **Add Search**: Full-text document search
5. **Backend Ready**: APIs can be integrated via services

---

**Project Version**: 1.0.0  
**Last Updated**: April 2026  
**Documentation Status**: ✅ Complete
