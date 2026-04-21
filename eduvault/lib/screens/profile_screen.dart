import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/providers/index.dart';
import 'package:eduvault/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _collegeController = TextEditingController();
  final _universityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  String? _selectedBoard;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().userProfile;
      if (user == null) return;
      _nameController.text = user.fullName ?? '';
      _schoolController.text = user.schoolName ?? '';
      _collegeController.text = user.collegeName ?? '';
      _universityController.text = user.universityName ?? '';
      _stateController.text = user.state ?? '';
      _countryController.text = user.country ?? '';
      setState(() {
        _selectedBoard = user.board;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _universityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    await context.read<AppSettingsProvider>().setProfileImagePath(file.path);
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<UserProvider>().updateUserProfile(
      fullName: _nameController.text.trim(),
      schoolName: _schoolController.text.trim(),
      board: _selectedBoard,
      collegeName: _collegeController.text.trim(),
      universityName: _universityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profile updated' : 'Failed to update profile'),
      ),
    );
  }

  Future<void> _manageQualification({
    Map<String, String>? existing,
    int? index,
  }) async {
    final titleController = TextEditingController(
      text: existing?['title'] ?? '',
    );
    final instituteController = TextEditingController(
      text: existing?['institute'] ?? '',
    );
    final yearController = TextEditingController(text: existing?['year'] ?? '');
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            index == null ? 'Add Qualification' : 'Edit Qualification',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              TextField(
                controller: instituteController,
                decoration: const InputDecoration(labelText: 'Institution'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'title': titleController.text.trim(),
                  'institute': instituteController.text.trim(),
                  'year': yearController.text.trim(),
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;
    final settings = context.read<AppSettingsProvider>();
    final list = [...settings.qualifications];
    if (index == null) {
      list.add(result);
    } else {
      list[index] = result;
    }
    await settings.saveQualifications(list);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final settingsProvider = context.watch<AppSettingsProvider>();
    final institutionProvider = context.watch<InstitutionProvider>();
    final user = userProvider.userProfile;
    final boardOptions = institutionProvider.boards.isEmpty
        ? <String>['CBSE', 'ICSE', 'State Board']
        : institutionProvider.boards;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('No profile found'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: InkWell(
                    onTap: _pickProfileImage,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundImage: settingsProvider.profileImagePath != null
                          ? FileImage(File(settingsProvider.profileImagePath!))
                          : null,
                      child: settingsProvider.profileImagePath == null
                          ? const Icon(Icons.person, size: 34)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _schoolController,
                        decoration: const InputDecoration(labelText: 'School'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBoard,
                        decoration: const InputDecoration(labelText: 'Board'),
                        items: [
                          ...boardOptions.map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _selectedBoard = value == null
                              ? null
                              : institutionProvider.normalizeBoardName(value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _collegeController,
                        decoration: const InputDecoration(labelText: 'College'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _universityController,
                        decoration: const InputDecoration(
                          labelText: 'University',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(labelText: 'State'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(labelText: 'Country'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Qualifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _manageQualification(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                ...settingsProvider.qualifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(row['title'] ?? 'Qualification'),
                      subtitle: Text(
                        '${row['institute'] ?? ''} ${row['year'] ?? ''}'.trim(),
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            onPressed: () => _manageQualification(
                              existing: row,
                              index: index,
                            ),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              final list = [...settingsProvider.qualifications]
                                ..removeAt(index);
                              await settingsProvider.saveQualifications(list);
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Target Exams',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.popularExams.map((exam) {
                    final selected = (user.targetExams ?? []).contains(exam);
                    return FilterChip(
                      label: Text(exam),
                      selected: selected,
                      onSelected: (value) async {
                        if (value) {
                          await userProvider.addTargetExam(exam);
                        } else {
                          await userProvider.removeTargetExam(exam);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
