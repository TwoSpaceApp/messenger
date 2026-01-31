import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_notifier.dart';
import '../utils/responsive.dart';
import '../widgets/password_strength_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _nicknameCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _avatarPath;
  Uint8List? _avatarBytes;
  int _step = 0;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    _nicknameCtl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);
      try {
        await ref.read(authNotifierProvider.notifier).register(
              _nameCtl.text,
              _emailCtl.text,
              _passCtl.text,
            );
        setState(() => _step = 1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _finishRegistration() async {
    setState(() => _loading = true);
    try {
      // Here you would typically upload the avatar and update the user profile
      // For now, we just pop the screen
      Navigator.pop(context);
    } finally {
      setState(() => _loading = false);
    }
  }

  int _getPasswordStrength(String password) {
    if (password.length < 6) return 0;
    int strength = 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) strength++;
    return strength;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _avatarPath = file.path;
        _avatarBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _loading
            ? null
            : () {
                if (_step == 0) {
                  _register();
                } else {
                  _finishRegistration();
                }
              },
        onStepCancel: _loading || _step == 0 ? null : () => setState(() => _step = 0),
        steps: [
          Step(
            title: const Text('Account'),
            content: _buildAccountStep(),
            isActive: _step >= 0,
          ),
          Step(
            title: const Text('Profile'),
            content: _buildProfileStep(),
            isActive: _step >= 1,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtl,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          TextFormField(
            controller: _passCtl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (v) => setState(() {}),
            validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
          ),
          PasswordStrengthIndicator(strength: _getPasswordStrength(_passCtl.text)),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAvatar,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
            child: _avatarBytes == null ? const Icon(Icons.add_a_photo, size: 50) : null,
          ),
        ),
        TextFormField(
          controller: _nameCtl,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        TextFormField(
          controller: _nicknameCtl,
          decoration: const InputDecoration(labelText: 'Nickname (optional)'),
        ),
      ],
    );
  }
}
