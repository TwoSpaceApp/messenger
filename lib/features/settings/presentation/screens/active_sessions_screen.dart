import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  final AuthService _authService = AuthService();

  bool _loading = true;
  bool _signingOut = false;
  String? _error;
  String? _revokeSessionId;
  List<ActiveSessionInfo> _sessions = const <ActiveSessionInfo>[];

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: session load result handled within the method
    // ignore: discarded_futures
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sessions = await _authService.listActiveSessions();
      if (!mounted) {
        return;
      }
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = UserFacingError.format(error, AppLocalizations.of(context));
        _loading = false;
      });
    }
  }

  Future<void> _revokeSession(ActiveSessionInfo session) async {
    if (_revokeSessionId != null || _signingOut) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              session.isCurrent ? l10n.logoutAction : l10n.deleteButton,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _revokeSessionId = session.sessionId);

    try {
      await _authService.revokeSession(session.sessionId);

      if (session.isCurrent) {
        setState(() => _signingOut = true);
        await _authService.signOut();
        if (!mounted) {
          return;
        }
        context.go(AppStrings.routeLogin);
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _sessions = _sessions
            .where((item) => item.sessionId != session.sessionId)
            .toList(growable: false);
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(UserFacingError.format(error, l10n))),
      );
    } finally {
      if (mounted) {
        setState(() => _revokeSessionId = null);
      }
    }
  }

  String _formatDateTime(DateTime? value, AppLocalizations l10n) {
    if (value == null) {
      return l10n.noData;
    }

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _sessionMeta(ActiveSessionInfo session, AppLocalizations l10n) {
    return <String>[
      if ((session.platform ?? '').trim().isNotEmpty) session.platform!.trim(),
      if ((session.appVersion ?? '').trim().isNotEmpty)
        session.appVersion!.trim(),
      if ((session.ipAddress ?? '').trim().isNotEmpty)
        session.ipAddress!.trim(),
      _formatDateTime(session.lastActivityAt ?? session.createdAt, l10n),
    ].join(' • ');
  }

  Widget _buildSessionTile(
    BuildContext context,
    ActiveSessionInfo session,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isBusy = _revokeSessionId == session.sessionId;

    return SectionCard(
      padding: const EdgeInsets.all(UITokens.spaceMd),
      radius: UITokens.cornerXL,
      borderColor: session.isCurrent
          ? theme.colorScheme.primary.withValues(alpha: 0.28)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: session.isCurrent
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(UITokens.cornerLg),
            ),
            child: Icon(
              session.isCurrent
                  ? Icons.smartphone_rounded
                  : Icons.devices_rounded,
              color: session.isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: UITokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.title ?? l10n.noData,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (session.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UITokens.spaceSm,
                          vertical: UITokens.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerPill,
                          ),
                        ),
                        child: Text(
                          l10n.currentDevice,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: UITokens.spaceXS),
                Text(
                  _sessionMeta(session, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if ((session.userAgent ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: UITokens.spaceXS),
                  Text(
                    session.userAgent!.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: UITokens.spaceSm),
          IconButton(
            onPressed: isBusy ? null : () => _revokeSession(session),
            tooltip: session.isCurrent ? l10n.logoutAction : l10n.deleteButton,
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    session.isCurrent
                        ? Icons.logout_rounded
                        : Icons.link_off_rounded,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget body;
    if (_loading) {
      body = AppLoadingState(label: l10n.loading);
    } else if (_error != null) {
      body = AppErrorState(
        title: l10n.activeSessionsLabel,
        message: _error!,
        actionLabel: l10n.retry,
        onAction: _loadSessions,
      );
    } else if (_sessions.isEmpty) {
      body = AppEmptyState(
        title: l10n.activeSessionsLabel,
        message: l10n.activeSessionsSubtitle,
        icon: Icons.devices_outlined,
        actionLabel: l10n.retry,
        onAction: _loadSessions,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _loadSessions,
        child: ListView.separated(
          padding: const EdgeInsets.all(UITokens.spaceMd),
          itemCount: _sessions.length + 1,
          separatorBuilder: (context, index) =>
              const SizedBox(height: UITokens.space),
          itemBuilder: (context, index) {
            if (index == 0) {
              return SectionCard(
                padding: const EdgeInsets.all(UITokens.spaceMd),
                radius: UITokens.cornerXL,
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined),
                    const SizedBox(width: UITokens.spaceSm),
                    Expanded(
                      child: Text(
                        l10n.activeSessionsSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildSessionTile(
              context,
              _sessions[index - 1],
              l10n,
            );
          },
        ),
      );
    }

    final content = Column(
      children: [
        if (widget.embedded)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UITokens.spaceMd,
              UITokens.space,
              UITokens.spaceMd,
              0,
            ),
            child: SectionPageHeader(
              title: l10n.activeSessionsLabel,
              subtitle: l10n.activeSessionsSubtitle,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
        Expanded(child: body),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.activeSessionsLabel)),
      body: ScreenBackground(child: content),
    );
  }
}
