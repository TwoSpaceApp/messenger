import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/core/utils/responsive.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_group_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  GroupVisibility _visibility = GroupVisibility.private;
  bool _showMessageHistory = false;
  bool _isLoading = false;

  late AegisGroupService _groupService;

  @override
  void initState() {
    super.initState();
    _groupService = AegisGroupService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imagePickError(e.toString()))),
        );
      }
    }
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterRoomNameError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final avatarBytes = await _selectedImage?.readAsBytes();
      final group = await _groupService.createGroupRoom(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        visibility: _visibility,
        showMessageHistory: _showMessageHistory,
        avatarBytes: avatarBytes,
        avatarFileName: _selectedImage == null
            ? null
            : p.basename(_selectedImage!.path),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.roomCreatedSuccess)),
        );
        final chatObj = Chat(
          id: group.roomId,
          name: group.name,
          members: group.members.map((m) => m.userId).toList(),
          roomType: 'group',
          lastMessageTime: DateTime.now(),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatId: chatObj.id),
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildVisibilityOption({
    required String title,
    required String subtitle,
    required GroupVisibility value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = _visibility == value;

    return GestureDetector(
      onTap: () => setState(() => _visibility = value),
      child: Container(
        padding: EdgeInsets.all(16 * Responsive.scaleFor(context)),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected
                ? 2 * Responsive.scaleWidth(context)
                : 1 * Responsive.scaleWidth(context),
          ),
          borderRadius: BorderRadius.circular(
            12 * Responsive.scaleWidth(context),
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24 * Responsive.scaleFor(context),
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            SizedBox(width: 16 * Responsive.scaleWidth(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 14 * Responsive.scaleFor(context),
                      color: isSelected ? theme.colorScheme.primary : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4 * Responsive.scaleHeight(context)),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12 * Responsive.scaleFor(context),
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 700;

    return Scaffold(
      appBar: AppBar(
        leading: ShadIconButton.ghost(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.createRoomTitle),
        centerTitle: !isWideScreen,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ShadButton.secondary(
              onPressed: _isLoading ? null : _createGroup,
              child: Row(
                children: [
                  if (_isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.check, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.createButton),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth >= 1100
                      ? 860.0
                      : double.infinity;
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar selector
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.mediaPlaceholder(context),
                                    borderRadius: BorderRadius.circular(60),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: _selectedImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            60,
                                          ),
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.6),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Group name field
                            Text(
                              l10n.roomNameLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ShadInput(
                              controller: _nameController,
                              placeholder: Text(l10n.roomNameHint),
                              leading: const Icon(
                                Icons.forum_outlined,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Description field
                            Text(
                              l10n.roomTopicLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ShadInput(
                              controller: _descriptionController,
                              maxLines: 3,
                              placeholder: Text(l10n.roomTopicHint),
                              leading: const Icon(
                                Icons.description_outlined,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Visibility section
                            Text(
                              l10n.roomVisibilityLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildVisibilityOption(
                              title: l10n.privateRoomOption,
                              subtitle: l10n.privateRoomSubtitle,
                              value: GroupVisibility.private,
                              icon: Icons.lock,
                            ),
                            _buildVisibilityOption(
                              title: l10n.publicRoomOption,
                              subtitle: l10n.publicRoomSubtitle,
                              value: GroupVisibility.public,
                              icon: Icons.public,
                            ),
                            const SizedBox(height: 24),

                            // Message history checkbox
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ShadSwitch(
                                value: _showMessageHistory,
                                onChanged: (value) =>
                                    setState(() => _showMessageHistory = value),
                                label: Text(
                                  l10n.showHistoryLabel,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                sublabel: Text(
                                  l10n.showHistorySubtitle,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
