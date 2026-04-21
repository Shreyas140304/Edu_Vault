import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('mr')];

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return instance ?? AppLocalizations(const Locale('en'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'EduVault',
      'splash_tagline': 'Intelligent Academic Document Manager',
      'choose_language': 'Choose Language',
      'select_language': 'Select app language',
      'english': 'English',
      'hindi': 'Hindi',
      'marathi': 'Marathi',
      'continue': 'Continue',
      'settings': 'Settings',
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'sync_entrance_exams': 'Sync Entrance Exams',
      'sync_exam_subtitle': 'Refresh timelines, deadlines, and requirements',
      'exam_sync_completed': 'Exam sync completed',
      'send_test_notification': 'Send Test Notification',
      'test_notification_sent': 'Test notification sent',
      'delete_profile': 'Delete Profile',
      'delete_profile_confirm_title': 'Delete Profile?',
      'delete_profile_confirm_text':
          'This will remove your profile and profile settings.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'notifications': 'Notifications',
      'no_notifications': 'No notifications yet',
      'search': 'Search',
      'no_matches_found': 'No matches found',
      'search_hint': 'Search docs, exams, institutions',
      'documents': 'Documents',
      'exams': 'Exams',
      'institutions': 'Institutions',
      'recent_documents': 'Recent Documents',
      'academic_progress': 'Academic Progress',
      'no_docs_uploaded': 'No documents uploaded yet',
      'no_exams_added': 'No entrance exams added yet',
      'add_exam': 'Add Exam',
      'active_exams': 'Active Exams',
      'approaching_deadlines': 'Approaching Deadlines',
      'completed_stages': 'Completed Stages',
      'reset': 'Reset',
      'stages': 'Stages',
      'overview': 'Overview',
      'upload_document': 'Upload Document',
      'profile': 'Profile',
      'no_profile_found': 'No profile found',
      'save_changes': 'Save Changes',
      'profile_updated': 'Profile updated',
      'profile_update_failed': 'Failed to update profile',
      'qualifications': 'Qualifications',
      'add': 'Add',
      'target_exams': 'Target Exams',
      'full_name': 'Full Name',
      'school': 'School',
      'board': 'Board',
      'college': 'College',
      'university': 'University',
      'state': 'State',
      'country': 'Country',
      'required': 'Required',
    },
    'hi': {
      'app_name': 'एजुवॉल्ट',
      'splash_tagline': 'स्मार्ट अकादमिक दस्तावेज़ प्रबंधक',
      'choose_language': 'भाषा चुनें',
      'select_language': 'ऐप की भाषा चुनें',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिंदी',
      'marathi': 'मराठी',
      'continue': 'जारी रखें',
      'settings': 'सेटिंग्स',
      'edit_profile': 'प्रोफाइल संपादित करें',
      'language': 'भाषा',
      'sync_entrance_exams': 'प्रवेश परीक्षाएं सिंक करें',
      'sync_exam_subtitle': 'टाइमलाइन, समयसीमा और आवश्यकताएं ताज़ा करें',
      'exam_sync_completed': 'परीक्षा सिंक पूरा हुआ',
      'send_test_notification': 'टेस्ट नोटिफिकेशन भेजें',
      'test_notification_sent': 'टेस्ट नोटिफिकेशन भेजा गया',
      'delete_profile': 'प्रोफाइल हटाएं',
      'delete_profile_confirm_title': 'प्रोफाइल हटाएं?',
      'delete_profile_confirm_text':
          'इससे आपकी प्रोफाइल और प्रोफाइल सेटिंग्स हट जाएंगी।',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'notifications': 'सूचनाएं',
      'no_notifications': 'अभी कोई सूचना नहीं',
      'search': 'खोज',
      'no_matches_found': 'कोई परिणाम नहीं मिला',
      'search_hint': 'दस्तावेज़, परीक्षाएं, संस्थान खोजें',
      'documents': 'दस्तावेज़',
      'exams': 'परीक्षाएं',
      'institutions': 'संस्थान',
      'recent_documents': 'हाल के दस्तावेज़',
      'academic_progress': 'शैक्षणिक प्रगति',
      'no_docs_uploaded': 'अभी तक कोई दस्तावेज़ अपलोड नहीं हुआ',
      'no_exams_added': 'अभी कोई प्रवेश परीक्षा नहीं जोड़ी गई',
      'add_exam': 'परीक्षा जोड़ें',
      'active_exams': 'सक्रिय परीक्षाएं',
      'approaching_deadlines': 'निकट समयसीमा',
      'completed_stages': 'पूर्ण स्तर',
      'reset': 'रीसेट',
      'stages': 'स्तर',
      'overview': 'ओवरव्यू',
      'upload_document': 'दस्तावेज़ अपलोड करें',
      'profile': 'प्रोफाइल',
      'no_profile_found': 'प्रोफाइल नहीं मिला',
      'save_changes': 'परिवर्तन सहेजें',
      'profile_updated': 'प्रोफाइल अपडेट हो गया',
      'profile_update_failed': 'प्रोफाइल अपडेट नहीं हुआ',
      'qualifications': 'योग्यताएं',
      'add': 'जोड़ें',
      'target_exams': 'लक्षित परीक्षाएं',
      'full_name': 'पूरा नाम',
      'school': 'स्कूल',
      'board': 'बोर्ड',
      'college': 'कॉलेज',
      'university': 'विश्वविद्यालय',
      'state': 'राज्य',
      'country': 'देश',
      'required': 'अनिवार्य',
    },
    'mr': {
      'app_name': 'एडुवॉल्ट',
      'splash_tagline': 'स्मार्ट शैक्षणिक दस्तऐवज व्यवस्थापक',
      'choose_language': 'भाषा निवडा',
      'select_language': 'ॲपची भाषा निवडा',
      'english': 'इंग्रजी',
      'hindi': 'हिंदी',
      'marathi': 'मराठी',
      'continue': 'पुढे जा',
      'settings': 'सेटिंग्ज',
      'edit_profile': 'प्रोफाइल संपादित करा',
      'language': 'भाषा',
      'sync_entrance_exams': 'प्रवेश परीक्षा सिंक करा',
      'sync_exam_subtitle': 'टाइमलाइन, डेडलाइन आणि कागदपत्रे अपडेट करा',
      'exam_sync_completed': 'परीक्षा सिंक पूर्ण झाले',
      'send_test_notification': 'टेस्ट सूचना पाठवा',
      'test_notification_sent': 'टेस्ट सूचना पाठवली',
      'delete_profile': 'प्रोफाइल हटवा',
      'delete_profile_confirm_title': 'प्रोफाइल हटवायचे?',
      'delete_profile_confirm_text':
          'यामुळे तुमचा प्रोफाइल आणि सेटिंग्ज हटतील.',
      'cancel': 'रद्द करा',
      'delete': 'हटवा',
      'notifications': 'सूचना',
      'no_notifications': 'अजून सूचना नाहीत',
      'search': 'शोधा',
      'no_matches_found': 'कोणतेही निकाल नाहीत',
      'search_hint': 'कागदपत्रे, परीक्षा, संस्था शोधा',
      'documents': 'कागदपत्रे',
      'exams': 'परीक्षा',
      'institutions': 'संस्था',
      'recent_documents': 'अलीकडील कागदपत्रे',
      'academic_progress': 'शैक्षणिक प्रगती',
      'no_docs_uploaded': 'अजून कागदपत्रे अपलोड केलेली नाहीत',
      'no_exams_added': 'अजून प्रवेश परीक्षा जोडलेल्या नाहीत',
      'add_exam': 'परीक्षा जोडा',
      'active_exams': 'सक्रिय परीक्षा',
      'approaching_deadlines': 'जवळ येणाऱ्या डेडलाइन',
      'completed_stages': 'पूर्ण टप्पे',
      'reset': 'रीसेट',
      'stages': 'टप्पे',
      'overview': 'ओव्हरव्ह्यू',
      'upload_document': 'कागदपत्र अपलोड करा',
      'profile': 'प्रोफाइल',
      'no_profile_found': 'प्रोफाइल आढळला नाही',
      'save_changes': 'बदल जतन करा',
      'profile_updated': 'प्रोफाइल अपडेट झाला',
      'profile_update_failed': 'प्रोफाइल अपडेट अयशस्वी',
      'qualifications': 'पात्रता',
      'add': 'जोडा',
      'target_exams': 'लक्ष्य परीक्षा',
      'full_name': 'पूर्ण नाव',
      'school': 'शाळा',
      'board': 'बोर्ड',
      'college': 'कॉलेज',
      'university': 'विद्यापीठ',
      'state': 'राज्य',
      'country': 'देश',
      'required': 'आवश्यक',
    },
  };

  String t(String key) {
    final lang = _localizedValues[locale.languageCode];
    if (lang != null && lang.containsKey(key)) {
      return lang[key]!;
    }
    return _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => l10n.t(key);
}
