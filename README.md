cd "d:\SPIT MCA DOCS ONLY\MP_FLUTTER\project1\MP_PROJECT\eduvault"

# Clean and reset
flutter clean
flutter pub get

# Try building again
flutter run# EduVault - Intelligent Academic Document Manager

A comprehensive Flutter mobile application that allows students to store, organize, analyze, and track academic documents throughout their educational journey.

## ✨ Features Implemented

### ✅ Core Functionality

- **Smart Document Organization**: Automatically organize documents by education stage (Class 10, 12, Graduation, Post-Graduation)
- **OCR-Based Classification**: Extract text from documents using Google ML Kit for AI-powered classification
- **Intelligent Document Detection**: Automatically detect document types based on extracted text
- **Missing Document Alerts**: Track and notify users about missing required documents

### ✅ User Management

- **Profile Setup Wizard**: Multi-step onboarding with personal and education details
- **Target Exam Tracking**: Users can select and track multiple entrance exams (GATE, CAT, NEET, IIT JEE, etc.)
- **Local Database**: All data stored locally using Hive for offline access

### ✅ Document Management

- **File Storage**: Secure local storage of all documents
- **Document Metadata**: Stores file details, extraction text, confidence levels, tags
- **Search Functionality**: Quick search by filename, category, or extracted text
- **Document Viewer**: Built-in PDF and image viewer support

### ✅ Entrance Exam Tracking

- **Pre-configured Exam Requirements**: GATE, CAT, NEET, IIT JEE, UPSC, CLAT with standard document requirements
- **Progress Tracking**: Visual progress indicators showing document completion
- **Deadline Management**: Track application deadlines and get alerts when approaching
- **Status Management**: Track application status (Not Started, In Progress, Submitted)

### ✅ Notification System

- **Local Notifications**: Real-time alerts for missing documents and approaching deadlines
- **Notification Types**: Categorized notifications (deadline, missing_doc, requirement_update)
- **Notification History**: All notifications stored and accessible

### ✅ UI/UX

- **Professional Design**: Material Design 3 with custom color scheme
- **Card-Based Dashboard**: Visual progress indicators and completion status
- **Multi-Tab Interface**: Organized navigation between Stages, Exams, and Overview
- **Responsive Layout**: Works on various screen sizes
- **State Management**: Provider architecture for clean state management

## 📁 Project Structure

```
lib/
├── main.dart                 # App initialization and configuration
├── config/
│   └── router.dart          # Navigation routes configuration
├── constants/
│   ├── app_colors.dart      # App theme and colors
│   └── app_constants.dart   # App configuration constants
├── models/
│   ├── user_model.dart
│   ├── document_model.dart
│   ├── entrance_exam_model.dart
│   ├── notification_model.dart
│   └── index.dart
├── services/
│   ├── database_service.dart        # Hive database operations
│   ├── ocr_service.dart             # OCR and document detection
│   ├── file_storage_service.dart    # Local file management
│   ├── notification_service.dart    # Notifications
│   └── index.dart
├── providers/
│   ├── user_provider.dart           # User state management
│   ├── document_provider.dart       # Document state management
│   ├── entrance_exam_provider.dart  # Exam state management
│   └── index.dart
├── screens/
│   ├── splash_screen.dart
│   ├── profile_setup_screen.dart
│   ├── dashboard_screen.dart
│   ├── search_screen.dart
│   ├── placeholder_screens.dart     # Screens coming soon
│   └── index.dart
└── widgets/
    ├── stage_card.dart
    ├── exam_card.dart
    └── index.dart
```

## 🛠️ Technology Stack

### Frontend

- **Flutter**: Modern cross-platform framework
- **Provider**: State management solution

### Local Storage

- **Hive**: Lightweight embedded database
- **Path Provider**: File system access

### Machine Learning

- **Google ML Kit**: On-device OCR for text recognition

### Notifications

- **Flutter Local Notifications**: Local push notifications

### Additional

- **Camera**: Document scanning support
- **Image Picker**: Image/file selection
- **HTTP**: For future API integrations
- **Logger**: Debugging and logging

## 📋 Data Models

### UserProfile

- Personal information (name, school, board, college, university)
- Location details
- Target entrance exams
- Profile completion status

### Document

- File information (name, path, type, size)
- Classification (stage, category, OCR text)
- Detection confidence level
- Metadata (tags, upload date, favorite status)
- Exam association

### EntranceExam

- Exam details (name, portal link)
- Application deadline and exam date
- Required documents list
- Uploaded documents tracking
- Application status

### NotificationItem

- Notification type and message
- Associated category
- Read/unread status
- Action routing

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Android SDK / iOS deployment setup
- Google ML Kit compatible device

### Installation

```bash
# Navigate to project directory
cd eduvault

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build

# Run the app
flutter run
```

## 📱 Screens Overview

### Splash Screen

- Beautiful animated splash with app branding
- Initializes services and loads user data
- Routes to onboarding or dashboard

### Profile Setup Screen

- 3-step multi-page form
- Basic info, Education details, Exam selection
- Profile persistence to local database

### Dashboard Screen

- 3 tabs: Stages, Exams, Overview
- Real-time progress tracking
- Quick access to all features
- Document upload button

### Education Stages Tab

- List of all academic stages
- Progress indicators for each stage
- Missing document count
- Navigation to stage details

### Entrance Exams Tab

- Active exams with deadlines
- Progress bars for document completion
- Days remaining indicators
- Quick status access

### Overview Tab

- Statistics cards (documents, exams, approaching deadlines)
- Recent document list
- Quick stats summary

## 🔮 Features Coming Soon

- Document scanning with camera
- Full document uploader with OCR processing
- Advanced search with filters
- Settings and preferences
- Requirement update monitoring from official sources
- Deadline extension tracking
- Document viewer with annotations
- Export and backup features
- Cloud sync option

## 🔐 Privacy & Security

- **Local Storage Only**: All data stored on device
- **No Cloud Integration**: Complete offline functionality
- **Open Source**: Transparent and auditable code
- **File Encryption**: Future implementation for sensitive docs

## 📊 Database Schema

### User Profile Box

- Stores single user profile per device
- Includes all personal and educational information

### Documents Box

- Key-value storage with document ID as key
- Supports filtering by stage, category, exam

### Exams Box

- Entrance exam records with deadline tracking
- Pre-configured requirements per exam

### Notifications Box

- Chronological notification history
- Read/unread status tracking

## 🎨 Design Principles

- **Clean UI**: Minimal, professional design
- **User-Centric**: Focus on ease of use
- **Visual Hierarchy**: Clear information hierarchy
- **Accessibility**: WCAG compliant colors and text sizes
- **Performance**: Optimized for smooth animations

## 📝 Code Quality

- Clean architecture with separation of concerns
- Provider pattern for state management
- Comprehensive logging and error handling
- Type-safe Dart code
- Flutter best practices

## 🐛 Known Issues & Workarounds

- PDF viewer uses simplified implementation (pdfx)
- Document scanning requires camera permissions
- OCR performance depends on document quality

## 🤝 Contributing

This is an educational project. Contributions and improvements are welcome!

## 📄 License

This project is created for educational purposes.

## 📞 Support

For issues or feature requests, please refer to the project documentation or reach out to the development team.

---

**Status**: ✅ Project Structure Complete | 🚧 Feature Implementation In Progress | ✅ Ready for Testing

**Version**: 1.0.0
**Last Updated**: April 2026
