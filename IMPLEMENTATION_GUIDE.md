# EduVault - Implementation Guide

This guide provides step-by-step instructions for implementing the remaining features of EduVault.

## Phase 3: Core Feature Implementation

### 1. Document Upload Screen

**File**: `lib/screens/upload_document_screen.dart`

**Key Features**:

- Bottom sheet for upload method selection (Gallery, Camera, Files)
- Image/PDF picker integration
- OCR processing with progress indicator
- Auto-classification display
- Confirmation before saving

**Implementation Steps**:

1. Create image_picker integration
2. Call OCR service with selected file
3. Display detection results
4. Allow user to confirm or manually select category/stage
5. Save document via DocumentProvider

**Dependencies Already Added**:

- `image_picker`: For file/image selection
- `google_mlkit_text_recognition`: For OCR
- `pdfx`: For PDF handling

### 2. Document Scanner Screen

**File**: `lib/screens/document_scanner_screen.dart`

**Key Features**:

- Camera preview with document overlay
- Auto-capture when document detected
- Image processing and cropping
- OCR on captured image

**Implementation Steps**:

1. Use camera package for preview
2. Implement edge detection algorithm
3. Auto-trigger capture when document fills frame
4. Pass to OCR service
5. Show confirmation and save

### 3. Stage Details Screen

**File**: `lib/screens/stage_details_screen.dart`

**Key Features**:

- List of required documents for stage
- List of uploaded documents
- Progress tracking
- Upload/delete options

**Implementation Steps**:

1. Fetch documents by stage from DocumentProvider
2. Display required vs uploaded comparison
3. Add card items for each document
4. Show edit/delete options
5. Link to upload screen

### 4. Search Functionality

**File**: `lib/screens/search_screen.dart`

**Key Features**:

- Real-time search input
- Filter by stage/category/exam
- Display search results
- Open document on tap

**Implementation Steps**:

1. Create search field with debounce
2. Call DocumentProvider.searchDocuments()
3. Display results in grid/list
4. Add filters sidebar
5. Implement result selection

### 5. Settings Screen

**File**: `lib/screens/settings_screen.dart`

**Key Features**:

- Profile editing
- Notification preferences
- Data backup/restore
- About section

**Implementation Steps**:

1. Add Edit Profile option
2. Notification permission controls
3. Backup to cloud/export option
4. App version and info

### 6. Exam Details Screen

**Enhancement** to existing placeholder

**Key Features**:

- Required documents list
- Uploaded documents with status
- Add new documents shortcut
- Edit exam details
- Delete exam option

**Implementation Steps**:

1. Fetch exam details from EntranceExamProvider
2. Show requirement checklist
3. Show uploaded docs with checkmarks
4. Add quick upload button
5. Edit exam deadline/details

## Phase 4: Advanced Features

### 1. Requirement Monitoring

**File**: `lib/services/requirement_update_service.dart`

**How It Works**:

1. Periodically fetch requirements from official sources
2. Compare with local cached requirements
3. Detect changes
4. Send notifications for updates

**Implementation**:

```dart
// Pseudo-code
Future<void> checkForUpdates() async {
  final onlineReqs = await fetchFromOfficialSources();
  final localReqs = getCachedRequirements();
  final diff = compareRequirements(onlineReqs, localReqs);

  if (diff.isNotEmpty) {
    // Send notification and update local cache
    await sendUpdateNotification(diff);
    await updateCache(onlineReqs);
  }
}
```

### 2. Advanced Notifications

**Deadline Alerts**:

- 7 days before deadline
- 3 days before deadline
- 1 day before deadline
- On deadline day

**Missing Document Reminders**:

- Daily for critical stages
- Weekly for less important stages

### 3. Document Viewer Enhancement

**Include**:

- Zoom functionality
- Annotation tools
- Text highlighting
- Note-taking

### 4. Cloud Integration (Optional)

**Firebase Integration**:

- Cloud backup
- Cross-device sync
- Share documents

## Code Examples

### Example 1: OCR Workflow

```dart
// In document_provider.dart
Future<bool> uploadDocument(File sourceFile, String stage) async {
  try {
    // 1. Extract text
    final extractedText = await _ocrService.extractTextFromImage(
      sourceFile.path
    );

    // 2. Detect type
    final detection = _ocrService.detectDocumentType(extractedText);

    // 3. Create document record
    final document = Document(
      id: Uuid().v4(),
      fileName: sourceFile.path.split('/').last,
      extractedText: extractedText,
      category: detection['category'],
      stage: stage,
    );

    // 4. Save to database
    await _dbService.addDocument(document);

    return true;
  } catch (e) {
    _error = e.toString();
    return false;
  }
}
```

### Example 2: Notification Trigger

```dart
// In entrance_exam_provider.dart
Future<void> checkDeadlines() async {
  for (var exam in _exams) {
    if (exam.isDeadlineApproaching()) {
      await _notificationService.sendDeadlineAlert(
        exam.examName ?? '',
        exam.getDaysUntilDeadline() ?? 0,
      );
    }
  }
}
```

### Example 3: Search Implementation

```dart
// In search_screen.dart
void _handleSearch(String query) {
  if (query.isEmpty) {
    _filteredResults = [];
  } else {
    _filteredResults = context
        .read<DocumentProvider>()
        .searchDocuments(query);
  }
  setState(() {});
}
```

## Testing Checklist

- [ ] Upload document from gallery
- [ ] Capture document with camera
- [ ] Verify OCR extraction
- [ ] Test document classification
- [ ] Verify document storage
- [ ] Test search functionality
- [ ] Check notification delivery
- [ ] Verify deadline alerts
- [ ] Test batch operations
- [ ] Check database persistence

## Performance Optimization Tips

1. **OCR Processing**: Run on background isolate
2. **Database Queries**: Add indexes for frequently searched fields
3. **Image Loading**: Implement lazy loading for document lists
4. **Notifications**: Schedule background processing efficiently
5. **Storage**: Clean old documents periodically

## Future Enhancements

1. **AI-Powered Insights**: Suggest missing documents based on profile
2. **Batch Processing**: Upload multiple documents at once
3. **Collaboration**: Share documents with mentors/advisors
4. **Templates**: Pre-filled forms for common applications
5. **Analytics**: Track document management patterns
6. **Integration**: Connect with university portals
7. **Reminders**: Smart deadline calculations based on processing time

## Debug Tips

1. Enable logging in services:

   ```dart
   logger.level = Level.debug;
   ```

2. Monitor database:

   ```dart
   // View Hive box contents
   DevTools → App → Hive Inspector
   ```

3. Check notifications:

   ```dart
   // View notification payload
   ```

4. Performance profiling:
   ```dart
   // Use Flutter DevTools Profiler
   flutter run --profile
   ```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Google ML Kit](https://developers.google.com/ml-kit)
- [Hive Database](https://pub.dev/packages/hive)
- [Flutter Best Practices](https://flutter.dev/docs/testing)

## Support

Refer to the main README.md for project structure and overview.

---

**Last Updated**: April 2026
**Status**: Implementation Guide Complete
