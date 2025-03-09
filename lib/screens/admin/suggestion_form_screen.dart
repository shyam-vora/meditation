import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'dart:io';
import '../../models/suggestion_model.dart';
import '../../database/app_database.dart';
import 'package:image_picker/image_picker.dart';

class SuggestionFormScreen extends StatefulWidget {
  final Suggestion? suggestion;

  const SuggestionFormScreen({this.suggestion, super.key});

  @override
  State<SuggestionFormScreen> createState() => _SuggestionFormScreenState();
}

class _SuggestionFormScreenState extends State<SuggestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'mandatory';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.suggestion != null) {
      _nameController.text = widget.suggestion!.name;
      _descriptionController.text = widget.suggestion!.description;
      _selectedType = widget.suggestion!.type;
      _imagePath = widget.suggestion!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveSuggestion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      final suggestion = Suggestion(
        id: widget.suggestion?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imagePath: _imagePath!,
        type: _selectedType,
      );

      if (widget.suggestion != null) {
        await AppDatabase.instance.updateSuggestion(suggestion);
      } else {
        await AppDatabase.instance.createSuggestion(suggestion);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Text(
          widget.suggestion != null ? 'Edit Suggestion' : 'Create Suggestion',
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primaryTextW),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveSuggestion,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: TColor.primaryTextW,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_imagePath != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(_imagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _imagePath = null),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate, size: 50),
                      SizedBox(height: 8),
                      Text('Tap to add image'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Required' : null,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              items: ['mandatory', 'optional'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
