import 'package:flutter/material.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/config/ui_tokens.dart';
import 'package:two_space_app/screens/profile_screen.dart'; // To reuse SocialMediaPlatform

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> initialProfileData;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.initialProfileData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _aboutController;
  final Map<String, TextEditingController> _socialMediaControllers = {};

  bool _isSaving = false;
  final ChatMatrixService _matrixService = ChatMatrixService();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.initialProfileData['displayname'] ?? '');
    _aboutController = TextEditingController(text: widget.initialProfileData['about'] ?? '');

    for (var platform in _socialMediaPlatforms) {
      _socialMediaControllers[platform.key] = TextEditingController(
        text: widget.initialProfileData[platform.key] ?? '',
      );
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _aboutController.dispose();
    _socialMediaControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> updatedData = {
        'displayname': _displayNameController.text.trim(),
        'about': _aboutController.text.trim(),
      };

      for (var platform in _socialMediaPlatforms) {
        final controller = _socialMediaControllers[platform.key];
        if (controller != null && controller.text.trim().isNotEmpty) {
          updatedData[platform.key] = controller.text.trim();
        } else {
          updatedData[platform.key] = null; // Clear if empty
        }
      }

      await _matrixService.setUserInfo(widget.userId, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(true); // Pop with true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isSaving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UITokens.space),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Information', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Display Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(
                  labelText: 'About Me',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              Text('Social Media Links', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ..._socialMediaPlatforms.map((platform) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: TextFormField(
                    controller: _socialMediaControllers[platform.key],
                    decoration: InputDecoration(
                      labelText: platform.name,
                      hintText: platform.baseUrl != null ? 'e.g., ${platform.baseUrl}your_id' : 'Your ${platform.name} ID/URL',
                      prefixIcon: Icon(platform.icon),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
