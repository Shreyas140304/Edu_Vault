import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:eduvault/constants/app_constants.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  static final Logger _logger = Logger();

  late TextRecognizer _textRecognizer;
  bool _isInitialized = false;
  bool _isSupported = true;

  OcrService._internal();

  factory OcrService() {
    return _instance;
  }

  /// Initialize OCR service
  Future<void> init() async {
    if (kIsWeb) {
      _isSupported = false;
      _logger.w('OCR is not supported on web in this build.');
      return;
    }

    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _isInitialized = true;
      _logger.i('OCR service initialized');
    } catch (e) {
      _logger.e('Error initializing OCR: $e');
      rethrow;
    }
  }

  /// Extract text from image
  Future<String> extractTextFromImage(String imagePath) async {
    if (!_isSupported || !_isInitialized) {
      return '';
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.text;
      _logger.i(
        'Text extracted from image: ${extractedText.length} characters',
      );

      return extractedText;
    } catch (e) {
      _logger.e('Error extracting text from image: $e');
      return '';
    }
  }

  /// Detect document type and category
  Map<String, dynamic> detectDocumentType(String extractedText) {
    try {
      final lowerText = extractedText.toLowerCase();

      // Search for matching document type
      String detectedCategory = 'Unknown';
      String confidence = 'Low';
      int highestMatches = 0;

      AppConstants.documentKeywords.forEach((category, keywords) {
        int matches = 0;
        for (var keyword in keywords) {
          if (lowerText.contains(keyword)) {
            matches++;
          }
        }

        if (matches > highestMatches) {
          highestMatches = matches;
          detectedCategory = category;

          // Determine confidence based on keyword matches
          if (matches >= 3) {
            confidence = 'High';
          } else if (matches >= 2) {
            confidence = 'Medium';
          }
        }
      });

      _logger.i(
        'Document detected: $detectedCategory (Confidence: $confidence)',
      );

      return {
        'category': detectedCategory,
        'confidence': confidence,
        'matchesFound': highestMatches,
      };
    } catch (e) {
      _logger.e('Error detecting document type: $e');
      return {'category': 'Unknown', 'confidence': 'Low', 'matchesFound': 0};
    }
  }

  /// Determine education stage based on extracted text
  String determineEducationStage(String extractedText, String category) {
    try {
      final lowerText = extractedText.toLowerCase();

      // Check for Class 10 indicators
      if (lowerText.contains('class 10') ||
          lowerText.contains('secondary') ||
          lowerText.contains('10th') ||
          lowerText.contains('sslc')) {
        return 'Class 10';
      }

      // Check for Class 12 indicators
      if (lowerText.contains('class 12') ||
          lowerText.contains('higher secondary') ||
          lowerText.contains('12th') ||
          lowerText.contains('hsc')) {
        return 'Class 12';
      }

      // Check for Graduation indicators
      if (lowerText.contains('bachelor') ||
          lowerText.contains('degree') ||
          lowerText.contains('graduation') ||
          lowerText.contains('semester') ||
          lowerText.contains('engineering')) {
        return 'Graduation';
      }

      // Check for Post Graduation indicators
      if (lowerText.contains('master') ||
          lowerText.contains('post graduation') ||
          lowerText.contains('pg') ||
          lowerText.contains('m.tech') ||
          lowerText.contains('mba')) {
        return 'Post Graduation';
      }

      // Default based on category
      if (category.contains('Degree') || category.contains('Marksheet')) {
        return 'Graduation';
      }

      return 'Other Documents';
    } catch (e) {
      _logger.e('Error determining education stage: $e');
      return 'Other Documents';
    }
  }

  /// Extract key information from document
  Map<String, dynamic> extractKeyInformation(String extractedText) {
    try {
      final lowerText = extractedText.toLowerCase();
      final lines = extractedText.split('\n');

      Map<String, dynamic> keyInfo = {
        'studentName': null,
        'institutionName': null,
        'date': null,
        'registrationNumber': null,
      };

      // Extract student name (usually in first few lines)
      if (lines.length > 2) {
        keyInfo['studentName'] = lines[0].trim();
      }

      // Extract institution name
      for (var line in lines) {
        if (line.toLowerCase().contains('school') ||
            line.toLowerCase().contains('college') ||
            line.toLowerCase().contains('university') ||
            line.toLowerCase().contains('board')) {
          keyInfo['institutionName'] = line.trim();
          break;
        }
      }

      // Extract registration/roll number
      final regexPattern = RegExp(
        r'(?:roll|reg|registration)\s*(?:no|number|no\.)?:?\s*(\d+)',
      );
      final match = regexPattern.firstMatch(lowerText);
      if (match != null) {
        keyInfo['registrationNumber'] = match.group(1);
      }

      return keyInfo;
    } catch (e) {
      _logger.e('Error extracting key information: $e');
      return {
        'studentName': null,
        'institutionName': null,
        'date': null,
        'registrationNumber': null,
      };
    }
  }

  /// Dispose OCR service
  Future<void> dispose() async {
    if (!_isSupported || !_isInitialized) {
      return;
    }

    try {
      await _textRecognizer.close();
      _logger.i('OCR service disposed');
    } catch (e) {
      _logger.e('Error disposing OCR: $e');
    }
  }
}
