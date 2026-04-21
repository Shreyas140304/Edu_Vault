import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/providers/entrance_exam_provider.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedExam;
  DateTime? _applicationDeadline;
  DateTime? _examDate;
  bool _autoFetchOfficialData = true;
  final _officialPortalController = TextEditingController();
  final _examLinkController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _officialPortalController.dispose();
    _examLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDeadline}) async {
    final initialDate = isDeadline
        ? (_applicationDeadline ?? DateTime.now())
        : (_examDate ?? DateTime.now().add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;
    setState(() {
      if (isDeadline) {
        _applicationDeadline = picked;
      } else {
        _examDate = picked;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedExam == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select exam name.')));
      return;
    }

    final provider = context.read<EntranceExamProvider>();
    final ok = await provider.addEntranceExam(
      examName: _selectedExam!,
      applicationDeadline: _applicationDeadline!,
      examDate: _examDate,
      officialPortal: _officialPortalController.text.trim().isEmpty
          ? null
          : _officialPortalController.text.trim(),
      examLink: _examLinkController.text.trim().isEmpty
          ? null
          : _examLinkController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      autoFetchOfficialData: _autoFetchOfficialData,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exam added successfully.')));
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.error ?? 'Unable to add exam.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Entrance Exam')),
      body: Consumer<EntranceExamProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Auto-sync currently has strongest coverage for GATE, CAT, NEET, and IIT JEE.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedExam,
                  decoration: const InputDecoration(
                    labelText: 'Exam Name',
                    prefixIcon: Icon(Icons.assignment),
                  ),
                  items: AppConstants.popularExams
                      .map(
                        (exam) =>
                            DropdownMenuItem(value: exam, child: Text(exam)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExam = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select an exam.' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text('Auto-fetch official details'),
                  subtitle: const Text(
                    'Uses official portals when available and falls back to templates',
                  ),
                  value: _autoFetchOfficialData,
                  onChanged: (value) {
                    setState(() {
                      _autoFetchOfficialData = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Application Deadline'),
                  subtitle: Text(
                    _autoFetchOfficialData
                        ? 'Auto-filled from sync (or fallback)'
                        : _formatDate(_applicationDeadline),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _autoFetchOfficialData
                      ? null
                      : () => _pickDate(isDeadline: true),
                ),
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.event),
                  title: const Text('Exam Date (Optional)'),
                  subtitle: Text(
                    _autoFetchOfficialData
                        ? 'Auto-filled from sync when available'
                        : _formatDate(_examDate),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _autoFetchOfficialData
                      ? null
                      : () => _pickDate(isDeadline: false),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _officialPortalController,
                  decoration: const InputDecoration(
                    labelText: 'Official Portal (Optional)',
                    prefixIcon: Icon(Icons.public),
                    hintText: 'https://example.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _examLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Application Link (Optional)',
                    prefixIcon: Icon(Icons.link),
                    hintText: 'https://example.com/apply',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _submit,
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(provider.isLoading ? 'Saving...' : 'Save Exam'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
