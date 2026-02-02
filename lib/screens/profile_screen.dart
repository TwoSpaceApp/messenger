import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_space_app/services/chat_service.dart';
import 'package:two_space_app/services/chat_backend_factory.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:two_space_app/services/navigation_service.dart';
import 'package:two_space_app/config/ui_tokens.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/screens/call_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialAvatar;

  const ProfileScreen({super.key, required this.userId, this.initialName, this.initialAvatar});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _actionLoading = false;
  bool _isMe = false;
  bool _isEditing = false;
  
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      // AppwriteService not available, skip loading user data
      if (mounted) {
        setState(() {
        _user = null;
        _isMe = false;
        _loading = false;
      });
      _initializeControllers();
      }
    } catch (_) {
      if (mounted) {
        setState(() { _loading = false; _user = null; });
        _initializeControllers();
      }
    }
  }

  void _initializeControllers() {
    if (_user != null) {
      final prefs = (_user!['prefs'] is Map) ? Map<String, dynamic>.from(_user!['prefs']) : <String, dynamic>{};
      _nameController.text = (_user!['name'] as String?)?.trim() ?? '';
      _nicknameController.text = (prefs['nickname'] as String?)?.trim() ?? '';
      _aboutController.text = (prefs['about'] as String?)?.trim() ?? (_user!['bio'] as String?)?.trim() ?? '';
      _locationController.text = (_user!['location'] as String?)?.trim() ?? '';
      _birthdayController.text = (_user!['birthday'] as String?)?.trim() ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // TODO: Upload avatar to server
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Загрузка аватара будет добавлена позже')),
      );
    }
  }

  Future<void> _saveProfile() async {
    // TODO: Save profile changes to server
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль сохранён')),
    );
  }

  String _displayName() {
    try {
      if (_user == null) return widget.initialName ?? widget.userId;
      final prefs = (_user!['prefs'] is Map) ? Map<String, dynamic>.from(_user!['prefs']) : <String, dynamic>{};
      final name = (_user!['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) return name;
      final nick = (prefs['nickname'] as String?)?.trim();
      if (nick != null && nick.isNotEmpty) return nick;
      final email = (_user!['email'] as String?) ?? '';
      if (email.isNotEmpty) return email.split('@').first;
    } catch (_) {}
    return widget.initialName ?? widget.userId;
  }

  String? _avatarUrl() {
    try {
      if (_user != null) {
        final prefs = (_user!['prefs'] is Map) ? Map<String, dynamic>.from(_user!['prefs']) : <String, dynamic>{};
        return (prefs['avatarUrl'] as String?) ?? (_user!['avatar'] as String?);
      }
    } catch (_) {}
    return widget.initialAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName();
    final avatar = _avatarUrl();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: false,
        actions: [
          if (_isMe)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
              tooltip: _isEditing ? 'Сохранить' : 'Редактировать',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(UITokens.space),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Avatar with gradient background
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withAlpha(150),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: UserAvatar(
                              key: ValueKey(avatar ?? 'noavatar_${widget.userId}'),
                              avatarUrl: avatar,
                              initials: (name.isNotEmpty ? name[0] : '?'),
                              fullName: name,
                              radius: 66,
                            ),
                          ),
                        ),
                        if (_isMe && _isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: Theme.of(context).colorScheme.primary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: _pickAvatar,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600))),
                  const SizedBox(height: 6),
                  if (_user != null) ...[
                    Center(
                      child: Text(
                        '@${_user!['prefs']?['nickname'] ?? _user!['name'] ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!_isMe) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: _actionLoading ? null : Icons.chat_bubble_outline,
                          label: 'Написать',
                          loading: _actionLoading,
                          onPressed: _actionLoading
                              ? null
                              : () async {
                                  setState(() => _actionLoading = true);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navState = appNavigatorKey.currentState;
                                  try {
                                    final cs = createChatBackend();
                                    final m = await cs.getOrCreateDirectChat(widget.userId);
                                    final chat = Chat.fromMap(m);
                                    if (!mounted) return;
                                    navState?.pop(chat);
                                  } catch (e) {
                                    messenger.showSnackBar(SnackBar(content: Text('Не удалось создать чат: $e')));
                                  } finally {
                                    if (mounted) setState(() => _actionLoading = false);
                                  }
                                },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.call_outlined,
                          label: 'Позвонить',
                          onPressed: () async {
                            final roomName = 'call_${widget.userId.replaceAll(RegExp(r"[^a-zA-Z0-9_-]"), '_')}_${DateTime.now().millisecondsSinceEpoch}';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CallScreen(
                                  room: roomName,
                                  isVideo: true,
                                  displayName: _displayName(),
                                  avatarUrl: _avatarUrl(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  Card(
                    elevation: UITokens.cardElevation,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
                    child: Padding(
                      padding: const EdgeInsets.all(UITokens.space),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEditing) ...[
                            _buildEditableField('Имя', _nameController, Icons.person),
                            const Divider(),
                            _buildEditableField('Никнейм', _nicknameController, Icons.alternate_email),
                            const Divider(),
                            _buildEditableField('О себе', _aboutController, Icons.info_outline, maxLines: 3),
                            const Divider(),
                            _buildEditableField('Место', _locationController, Icons.location_on_outlined),
                            const Divider(),
                            _buildEditableField('День рождения', _birthdayController, Icons.cake_outlined),
                          ] else ...[
                            _buildInfoRow('О себе', (_user != null) ? (_user!['prefs']?['about'] ?? _user!['bio'] ?? '') : ''),
                            const Divider(),
                            if (_user != null)
                              Builder(builder: (c) {
                                final prefs = (_user!['prefs'] is Map) ? Map<String, dynamic>.from(_user!['prefs']) : <String, dynamic>{};
                                final serverShowEmail = prefs['showEmail'] == true;
                                final email = (_user!['email'] as String?) ?? '';
                                final shouldShowEmail = (_isMe ? SettingsService.showEmailNotifier.value : serverShowEmail);
                                if (email.isNotEmpty && shouldShowEmail) {
                                  return Column(children: [
                                    _buildInfoRow('Email', email),
                                    const Divider(),
                                  ]);
                                }
                                return const SizedBox.shrink();
                              }),
                            if (_user != null)
                              Builder(builder: (c) {
                                final prefs = (_user!['prefs'] is Map) ? Map<String, dynamic>.from(_user!['prefs']) : <String, dynamic>{};
                                final serverShowPhone = prefs['showPhone'] == true;
                                final phone = (_user!['phone'] as String?) ?? '';
                                final shouldShowPhone = (_isMe ? SettingsService.showPhoneNotifier.value : serverShowPhone);
                                if (phone.isNotEmpty && shouldShowPhone) {
                                  return Column(children: [
                                    _buildInfoRow('Телефон', phone),
                                    const Divider(),
                                  ]);
                                }
                                return const SizedBox.shrink();
                              }),
                            _buildInfoRow('Никнейм', (_user != null) ? (_user!['prefs']?['nickname'] ?? '') : ''),
                            const Divider(),
                            _buildInfoRow('Место', (_user != null) ? (_user!['location'] ?? '') : ''),
                            const Divider(),
                            _buildInfoRow('День рождения', (_user != null) ? (_user!['birthday'] ?? '') : ''),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton({required IconData? icon, required String label, VoidCallback? onPressed, bool loading = false}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.cornerSm)),
      ),
      icon: loading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: Text(label),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(UITokens.cornerSm)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value?.isNotEmpty == true ? value! : '-', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()))),
      ]),
    );
  }
}
