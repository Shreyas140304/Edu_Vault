import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/models/institution_directory_model.dart';
import 'package:eduvault/providers/index.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _collegeController = TextEditingController();
  final _universityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedBoard;
  List<String> _selectedExams = [];

  List<String> _extractNames(List<InstitutionDirectoryEntry> entries) {
    return entries.map((entry) => entry.name).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstitutionProvider>().loadDirectory();
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.toInt() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _universityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasSchool = _schoolController.text.trim().isNotEmpty;
    final hasBoard = _selectedBoard != null;

    if (hasName && hasSchool && hasBoard) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.createUserProfile(
        fullName: _nameController.text.trim(),
        schoolName: _schoolController.text.trim(),
        board: context.read<InstitutionProvider>().normalizeBoardName(
          _selectedBoard!,
        ),
        collegeName: _collegeController.text.trim(),
        universityName: _universityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        targetExams: _selectedExams,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Error creating profile'),
          ),
        );
      }
    } else {
      // The form lives on page 1, so bring users back there if they submit from page 3.
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.validate();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !hasName
                ? 'Please enter your full name'
                : !hasSchool
                ? 'Please enter your school name'
                : 'Please select a board',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            minHeight: 4,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildBasicInfoPage(),
                _buildEducationInfoPage(),
                _buildExamSelectionPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    final institutionProvider = context.watch<InstitutionProvider>();
    final schoolSuggestions = _extractNames(
      institutionProvider.searchSchools(_schoolController.text),
    );
    final boardOptions = institutionProvider.boards.isEmpty
        ? <String>['CBSE', 'State Board', 'ICSE', 'IAMSE', 'Others']
        : institutionProvider.boards;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                hintText: 'Enter your full name',
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _schoolController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'School Name',
                prefixIcon: const Icon(Icons.school),
                hintText: 'Enter your school name',
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Please enter school name';
                }
                return null;
              },
            ),
            if (_schoolController.text.trim().isNotEmpty &&
                schoolSuggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: schoolSuggestions.take(5).map((name) {
                    return ActionChip(
                      label: Text(name),
                      onPressed: () {
                        setState(() {
                          _schoolController.text = name;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedBoard,
              decoration: InputDecoration(
                labelText: 'School Board',
                prefixIcon: const Icon(Icons.domain),
              ),
              items: boardOptions
                  .map(
                    (board) =>
                        DropdownMenuItem(value: board, child: Text(board)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBoard = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a board';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(
                labelText: 'State / Country',
                prefixIcon: const Icon(Icons.location_on),
                hintText: 'Enter your state',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                prefixIcon: const Icon(Icons.public),
                hintText: 'Enter your country',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationInfoPage() {
    final institutionProvider = context.watch<InstitutionProvider>();
    final collegeSuggestions = _extractNames(
      institutionProvider.searchColleges(_collegeController.text),
    );
    final universitySuggestions = _extractNames(
      institutionProvider.searchUniversities(_universityController.text),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _collegeController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'College Name (Optional)',
              prefixIcon: const Icon(Icons.business),
              hintText: 'Enter your college name',
            ),
          ),
          if (_collegeController.text.trim().isNotEmpty &&
              collegeSuggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: collegeSuggestions.take(5).map((name) {
                  return ActionChip(
                    label: Text(name),
                    onPressed: () {
                      setState(() {
                        _collegeController.text = name;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _universityController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'University Name (Optional)',
              prefixIcon: const Icon(Icons.verified_user),
              hintText: 'Enter your university name',
            ),
          ),
          if (_universityController.text.trim().isNotEmpty &&
              universitySuggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: universitySuggestions.take(5).map((name) {
                  return ActionChip(
                    label: Text(name),
                    onPressed: () {
                      setState(() {
                        _universityController.text = name;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'Tip: You can update education details later.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Entrance Exams',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the exams you plan to apply for (Optional)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.popularExams.map((exam) {
              final isSelected = _selectedExams.contains(exam);
              return FilterChip(
                label: Text(exam),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedExams.add(exam);
                    } else {
                      _selectedExams.remove(exam);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'You can add more exams later from the dashboard.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentPage > 0
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return ElevatedButton(
                  onPressed: userProvider.isLoading
                      ? null
                      : () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _submitProfile();
                          }
                        },
                  child: userProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(_currentPage == 2 ? 'Complete' : 'Next'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
