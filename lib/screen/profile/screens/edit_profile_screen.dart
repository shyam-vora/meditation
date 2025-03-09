import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/show_snackbar_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String?> _saveImage() async {
    if (_imageFile == null) return widget.user.profilePicture;

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'profile_${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await _imageFile!.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final profilePicture = await _saveImage();
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        profilePicture: profilePicture,
      );

      await AppDatabase.instance.updateUser(updatedUser);

      if (mounted) {
        context.showSnackbar(
          message: 'Profile updated successfully!',
          type: SnackbarMessageType.success,
        );
        // Ensure we're returning true to indicate successful update
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackbar(
          message: 'Failed to update profile: ${e.toString()}',
          type: SnackbarMessageType.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: TColor.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _getProfileImage(),
                    backgroundColor: TColor.primary,
                    child: _getAvatarContent(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }
    if (widget.user.profilePicture != null) {
      return FileImage(File(widget.user.profilePicture!));
    }
    return null;
  }

  Widget? _getAvatarContent() {
    if (_imageFile != null || widget.user.profilePicture != null) {
      return null;
    }
    return Text(
      widget.user.name[0].toUpperCase(),
      style: const TextStyle(fontSize: 32, color: Colors.white),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
