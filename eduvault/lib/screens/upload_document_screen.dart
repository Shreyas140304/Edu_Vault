import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/providers/document_provider.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final ImagePicker _picker = ImagePicker();
  String _selectedStage = AppConstants.educationStages.first;
  String? _selectedCategory;
  XFile? _selectedFile;

  List<String> _categoriesForStage(String stage) {
    final required = AppConstants.requiredDocuments[stage] ?? <String>[];
    if (required.isEmpty) {
      return const <String>['Other'];
    }
    return <String>[...required, 'Other'];
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick file. Please try again.')),
      );
    }
  }

  Future<void> _showPickOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an image first.')),
      );
      return;
    }

    final category =
        _selectedCategory ?? _categoriesForStage(_selectedStage).first;
    final provider = context.read<DocumentProvider>();
    final success = await provider.uploadDocumentFromPath(
      _selectedFile!.path,
      _selectedStage,
      recognizedCategory: category,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully.')),
      );
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'Upload failed. Please try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesForStage(_selectedStage);
    _selectedCategory ??= categories.first;

    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Upload Document')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This upload flow is mobile-focused for now. Mobile support is being prioritized in this phase.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      backgroundColor: AppColors.background,
      body: Consumer<DocumentProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Add an academic document',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStage,
                decoration: const InputDecoration(
                  labelText: 'Education Stage',
                  prefixIcon: Icon(Icons.school),
                ),
                items: AppConstants.educationStages
                    .map(
                      (stage) =>
                          DropdownMenuItem(value: stage, child: Text(stage)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedStage = value;
                    _selectedCategory = _categoriesForStage(value).first;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_selectedFile == null)
                        const Icon(Icons.insert_drive_file_outlined, size: 44)
                      else
                        Text(
                          _selectedFile!.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: provider.isLoading ? null : _showPickOptions,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          _selectedFile == null ? 'Choose File' : 'Change File',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _upload,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  provider.isLoading ? 'Uploading...' : 'Upload Document',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
