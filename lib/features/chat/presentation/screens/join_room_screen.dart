import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/chat_creation_scaffold.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _linkController = TextEditingController();
  final AegisChatService _chatService = AegisChatService();

  bool _loading = false;
  String? _errorMessage;
  Map<String, dynamic>? _preview;
  Timer? _previewDebounce;
  int _previewRequestId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prefillFromClipboard());
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _linkController.dispose();
    super.dispose();
  }

  bool _looksLikeInviteCandidate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.contains('\n') || trimmed.length > 180) {
      return false;
    }
    return trimmed.contains('://') || trimmed.contains('@') || trimmed.contains('/') || trimmed.length > 6;
  }

  Future<void> _prefillFromClipboard() async {
    if (_linkController.text.trim().isNotEmpty) {
      return;
    }
    final clipboard = await Clipboard.getData('text/plain');
    final candidate = clipboard?.text?.trim() ?? '';
    if (!_looksLikeInviteCandidate(candidate) || !mounted) {
      return;
    }
    _linkController.text = candidate;
    _schedulePreview();
  }

  void _schedulePreview() {
    _previewDebounce?.cancel();
    final value = _linkController.text.trim();
    if (value.isEmpty) {
      setState(() {
        _preview = null;
        _errorMessage = null;
      });
      return;
    }
    final silent = !_looksLikeInviteCandidate(value);
    _previewDebounce = Timer(
      const Duration(milliseconds: 650),
      () => unawaited(_resolvePreview(silent: silent)),
    );
  }

  Future<void> _resolvePreview({bool silent = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final value = _linkController.text.trim();
    if (value.isEmpty) {
      if (!silent) {
        setState(() => _errorMessage = l10n.joinLinkHint);
      }
      return;
    }

    final requestId = ++_previewRequestId;

    setState(() {
      _loading = true;
      if (!silent) {
        _errorMessage = null;
      }
      _preview = null;
    });

    try {
      final preview = await _chatService.resolveRoomLink(value);
      if (!mounted || requestId != _previewRequestId) {
        return;
      }
      setState(() {
        _preview = preview;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted || requestId != _previewRequestId) {
        return;
      }
      setState(() {
        _preview = null;
        _errorMessage = silent ? null : chatCreationFriendlyError(error);
      });
    } finally {
      if (mounted && requestId == _previewRequestId) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _joinRoom() async {
    final l10n = AppLocalizations.of(context)!;
    final value = _linkController.text.trim();
    if (value.isEmpty) {
      setState(() => _errorMessage = l10n.joinLinkHint);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final chat = await _chatService.joinRoomByLink(value);
      if (!mounted) {
        return;
      }
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = chatCreationFriendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _typeLabel(AppLocalizations l10n, String? type) {
    switch (type) {
      case 'group':
        return l10n.groupChatTab;
      case 'public':
        return l10n.channelChatTab;
      case 'private':
        return l10n.channelChatTab;
      default:
        return l10n.newChatTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preview = _preview;
    final isChannel = preview != null && preview['type'] != 'group';

    return ChatCreationScaffold(
      title: l10n.joinByCodeTitle,
      subtitle: l10n.joinByCodeSubtitle,
      icon: Icons.link_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(UITokens.spaceLg),
            child: Column(
              children: [
                TextField(
                  controller: _linkController,
                  minLines: 2,
                  maxLines: 3,
                  onChanged: (_) => _schedulePreview(),
                  decoration: chatCreationInputDecoration(
                    context: context,
                    label: l10n.joinByCodeTitle,
                    icon: Icons.qr_code_rounded,
                    hint: l10n.joinLinkHint,
                    suffixIcon: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(UITokens.spaceSmMd),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: UITokens.borderThick,
                              ),
                            ),
                          )
                        : preview != null
                        ? Icon(
                            Icons.verified_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UITokens.spaceMd),
          ChatCreationErrorBanner(message: _errorMessage),
          if (preview != null) ...[
            const SizedBox(height: UITokens.spaceMd),
            GlassCard(
              padding: const EdgeInsets.all(UITokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerLg,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isChannel
                              ? Icons.campaign_outlined
                              : Icons.group_outlined,
                        ),
                      ),
                      const SizedBox(width: UITokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preview['name']?.toString() ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: UITokens.spaceXsSm),
                            Text(
                              _typeLabel(l10n, preview['type']?.toString()),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UITokens.spaceMd),
                  Wrap(
                    spacing: UITokens.spaceSm,
                    runSpacing: UITokens.spaceSm,
                    children: [
                      _JoinPreviewBadge(
                        icon: isChannel ? Icons.campaign_outlined : Icons.group_outlined,
                        label: _typeLabel(l10n, preview['type']?.toString()),
                      ),
                      _JoinPreviewBadge(
                        icon: Icons.group_rounded,
                        label: '${l10n.membersLabel}: ${preview['memberCount'] ?? 0}',
                      ),
                      _JoinPreviewBadge(
                        icon: preview['type'] == 'public'
                            ? Icons.public_rounded
                            : Icons.lock_outline_rounded,
                        label: preview['type'] == 'public'
                            ? l10n.publicLabel
                            : preview['type'] == 'private'
                                ? l10n.privateLabel
                                : l10n.groupChatTab,
                      ),
                    ],
                  ),
                  if (preview['description']?.toString().isNotEmpty ?? false) ...[
                    const SizedBox(height: UITokens.spaceMd),
                    Text(preview['description']!.toString()),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: UITokens.spaceMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _joinRoom,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isChannel
                          ? Icons.notifications_active_outlined
                          : Icons.login_rounded,
                    ),
              label: Text(isChannel ? l10n.subscribeAction : l10n.joinRoomAction),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UITokens.cornerXLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinPreviewBadge extends StatelessWidget {
  const _JoinPreviewBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceSmMd,
        vertical: UITokens.spaceXsSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(UITokens.cornerPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: UITokens.space2XS),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
