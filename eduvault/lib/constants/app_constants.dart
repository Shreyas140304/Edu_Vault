/// App-wide constants and configuration
class AppConstants {
  // App Info
  static const String appName = 'EduVault';
  static const String appVersion = '1.0.0';

  // Database
  static const String hiveBoxUser = 'user_profile';
  static const String hiveBoxDocuments = 'documents';
  static const String hiveBoxExams = 'entrance_exams';
  static const String hiveBoxRequirements = 'requirements';
  static const String hiveBoxNotifications = 'notifications';

  // File Paths
  static const String documentsFolder = 'eduvault_docs';

  // Education Stages
  static const List<String> educationStages = [
    'Class 10',
    'Class 12',
    'Graduation',
    'Post Graduation',
    'Entrance Exams',
    'Other Documents',
  ];

  // Default Required Documents by Stage
  static const Map<String, List<String>> requiredDocuments = {
    'Class 10': [
      'Marksheet',
      'Passing Certificate',
      'School Leaving Certificate',
    ],
    'Class 12': [
      'Marksheet',
      'Passing Certificate',
      'Migration Certificate',
      'Transfer Certificate',
    ],
    'Graduation': [
      'Semester Marksheets',
      'Degree Certificate',
      'Character Certificate',
      'Provisional Certificate',
    ],
    'Post Graduation': ['Semester Marksheets', 'Degree Certificate'],
    'Entrance Exams': [],
    'Other Documents': [],
  };

  // Popular Entrance Exams
  static const List<String> popularExams = [
    'GATE',
    'CAT',
    'NEET',
    'IIT JEE',
    'UPSC',
    'CLAT',
    'MAT',
    'XAT',
    'GMAT',
    'GRE',
  ];

  // Entrance Exam Requirements
  static const Map<String, List<String>> examRequirements = {
    'GATE': [
      'Degree Certificate',
      'Category Certificate',
      'ID Proof',
      'Passport Photograph',
      'Signature',
    ],
    'CAT': [
      'Bachelor\'s Degree Certificate',
      'Category Certificate',
      'PAN Card',
      'Passport Photograph',
    ],
    'NEET': [
      'Class 12 Marks',
      'Category Certificate',
      'ID Proof',
      'Passport Photograph',
    ],
    'IIT JEE': [
      'Class 12 Marksheet',
      'Class 12 Passing Certificate',
      'Category Certificate',
      'ID Proof',
    ],
    'UPSC': [
      'Degree Certificate',
      'Category Certificate',
      'Character Certificate',
      'Medical Certificate',
    ],
    'CLAT': [
      'Bachelor\'s Degree Certificate',
      'Class 12 Marksheet',
      'Category Certificate',
      'ID Proof',
    ],
  };

  // OCR Keywords for Document Detection
  static const Map<String, List<String>> documentKeywords = {
    'Marksheet': ['marksheet', 'marks', 'total marks', 'grade', 'result'],
    'Degree Certificate': [
      'degree',
      'certificate',
      'conferred',
      'bachelor',
      'master',
    ],
    'Passing Certificate': ['passing', 'certificate', 'passed', 'examination'],
    'Category Certificate': ['category', 'caste', 'obc', 'sc', 'st'],
    'ID Proof': ['id', 'identity', 'aadhar', 'pan', 'passport', 'voter'],
    'Passport Photograph': ['photograph', 'photo', 'passport', 'image'],
    'Character Certificate': ['character', 'conduct', 'character certificate'],
  };

  // API Endpoints for Requirement Updates
  static const String requirementUpdateUrl =
      'https://api.example.com/requirements';

  // Notification Settings
  static const int notificationCheckInterval = 3600; // 1 hour in seconds
  static const int deadlineAlertDays = 3; // Alert 3 days before deadline
}
