import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/data/admin_course_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/domain/admin_course_model.dart';

class AdminCourseEditor extends StatefulWidget {
  final AdminCourseModel? course;

  const AdminCourseEditor({super.key, this.course});

  @override
  State<AdminCourseEditor> createState() => _AdminCourseEditorState();
}

class _AdminCourseEditorState extends State<AdminCourseEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _slugController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _taglineController;
  late final TextEditingController _priceController;
  late final TextEditingController _instructorNameController;
  late final TextEditingController _instructorTitleController;
  late final TextEditingController _instructorQuoteController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _durationController;
  late final TextEditingController _objectivesController;
  late final TextEditingController _featuresController;
  late final TextEditingController _subjectsController;

  String _type = 'online';
  String _level = 'Beginner';
  bool _isSubmitting = false;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleController = TextEditingController(text: c?.title);
    _slugController = TextEditingController(text: c?.slug);
    _categoryController = TextEditingController(text: c?.category);
    _descriptionController = TextEditingController(text: c?.description);
    _taglineController = TextEditingController(text: c?.tagline);
    _priceController = TextEditingController(text: c?.price?.toString() ?? '0');
    _instructorNameController = TextEditingController(text: c?.instructorName);
    _instructorTitleController = TextEditingController(text: c?.instructorTitle);
    _instructorQuoteController = TextEditingController(text: c?.instructorQuote);
    _imageUrlController = TextEditingController(text: c?.imageUrl);
    _videoUrlController = TextEditingController(text: c?.videoUrl);
    _durationController = TextEditingController(text: c?.duration);
    _objectivesController = TextEditingController(text: c?.objectives.join('\n'));
    _featuresController = TextEditingController(text: c?.features.join('\n'));
    _subjectsController = TextEditingController(text: c?.subjectAreas.join(', '));
    _type = c?.type ?? 'online';
    _level = c?.level ?? 'Beginner';

    _titleController.addListener(() {
      if (widget.course == null && _slugController.text.isEmpty) {
         _slugController.text = _titleController.text.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _taglineController.dispose();
    _priceController.dispose();
    _instructorNameController.dispose();
    _instructorTitleController.dispose();
    _instructorQuoteController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _durationController.dispose();
    _objectivesController.dispose();
    _featuresController.dispose();
    _subjectsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.course == null ? 'Create New Course' : 'Edit Course Details',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 800,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('BASIC INFORMATION'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_titleController, 'Course Title', required: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_slugController, 'Slug (URL id)', required: true)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_categoryController, 'Category (e.g., Aqaid)')),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                        items: ['online', 'onsite'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('THUMBNAIL IMAGE'),
                _buildImagePicker(),

                const SizedBox(height: 32),
                _buildSectionTitle('CONTENT & STATUS'),
                _buildTextField(_taglineController, 'Tagline', hint: 'Short catchy summary'),
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, 'About Course (Description)', maxLines: 5),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _level,
                        decoration: const InputDecoration(labelText: 'Level', border: OutlineInputBorder()),
                        items: ['Beginner', 'Intermediate', 'Advanced'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (val) => setState(() => _level = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_durationController, 'Duration (e.g. 12 Hours)')),
                  ],
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('PRICING'),
                SizedBox(
                  width: 250,
                  child: _buildTextField(_priceController, 'Price (USD)', prefix: '\$', isNumeric: true),
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('INSTRUCTOR'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_instructorNameController, 'Instructor Name')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_instructorTitleController, 'Instructor Title')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_instructorQuoteController, 'Instructor Quote / Statement'),

                const SizedBox(height: 32),
                _buildSectionTitle('MEDIA'),
                _buildTextField(_videoUrlController, 'Intro Video URL (Vimeo)'),

                const SizedBox(height: 32),
                _buildSectionTitle('DETAILED LISTS'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_objectivesController, 'Objectives (One per line)', maxLines: 5)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_featuresController, 'Features/Includes (One per line)', maxLines: 5)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_subjectsController, 'Subject Areas (Comma separated)'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, _) => ElevatedButton(
            onPressed: _isSubmitting ? null : () => _handleSubmit(ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.course == null ? 'Create Course' : 'Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 67.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: _selectedImageBytes != null
                  ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                  : (_imageUrlController.text.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_imageUrlController.text), fit: BoxFit.cover)
                      : null),
            ),
            child: (_selectedImageBytes == null && _imageUrlController.text.isEmpty)
                ? const Icon(Icons.image_outlined, color: AdminTheme.textSecondary)
                : null,
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choose Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.secondaryNavy,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_selectedImageName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: $_selectedImageName',
                    style: const TextStyle(fontSize: 12, color: AdminTheme.primaryEmerald),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AdminTheme.secondaryNavy.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {
    bool required = false,
    bool isNumeric = false,
    String? hint,
    String? prefix,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : null,
      validator: required ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
    );
  }

  Future<void> _handleSubmit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(adminCourseRepositoryProvider);
      
      String? finalImageUrl = _imageUrlController.text;

      if (_selectedImageBytes != null && _selectedImageName != null) {
        finalImageUrl = await repo.uploadCourseThumbnail(
          _selectedImageBytes!, 
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedImageName!}'
        );
      }

      final data = {
        'title': _titleController.text,
        'slug': _slugController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'tagline': _taglineController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'type': _type,
        'level': _level,
        'duration': _durationController.text,
        'instructorName': _instructorNameController.text,
        'instructorTitle': _instructorTitleController.text,
        'instructorQuote': _instructorQuoteController.text,
        'imageUrl': finalImageUrl,
        'videoUrl': _videoUrlController.text,
        'objectives': _objectivesController.text.split('\n').where((s) => s.isNotEmpty).toList(),
        'features': _featuresController.text.split('\n').where((s) => s.isNotEmpty).toList(),
        'subjectAreas': _subjectsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      };

      if (widget.course == null) {
        await repo.createCourse(data);
      } else {
        await repo.updateCourseMetadata(widget.course!.id, data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course ${widget.course == null ? 'created' : 'updated'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
