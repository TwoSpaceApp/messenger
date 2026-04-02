import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/update_service.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/presentation/widgets/settings_showcase.dart';

class _ReleaseSection {
  const _ReleaseSection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({required this.info, super.key});

  final UpdateInfo info;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  double _progress = 0;
  bool _downloading = false;
  bool _installing = false;
  bool _verifying = false;
  String? _error;
  String _selectedAbi = '';
  String _currentVersion = '';

  @override
  void initState() {
    super.initState();
    _selectedAbi = widget.info.selectedAbi ?? '';
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _currentVersion = packageInfo.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentVersion = '...');
    }
  }

  SettingsStageState _stageState(int stageIndex) {
    if (_error != null) {
      if (_installing && stageIndex == 2) return SettingsStageState.error;
      if (_verifying && stageIndex == 1) return SettingsStageState.error;
      if (_downloading && stageIndex == 0) return SettingsStageState.error;
    }
    if (_installing) {
      if (stageIndex < 2) return SettingsStageState.complete;
      return stageIndex == 2
          ? SettingsStageState.active
          : SettingsStageState.idle;
    }
    if (_verifying) {
      if (stageIndex == 0) return SettingsStageState.complete;
      return stageIndex == 1
          ? SettingsStageState.active
          : SettingsStageState.idle;
    }
    if (_downloading) {
      return stageIndex == 0
          ? SettingsStageState.active
          : SettingsStageState.idle;
    }
    if (_progress >= 1 && _error == null) {
      return stageIndex < 2
          ? SettingsStageState.complete
          : SettingsStageState.idle;
    }
    return SettingsStageState.idle;
  }

  Future<void> _startDownload() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _downloading = true;
      _verifying = false;
      _installing = false;
      _error = null;
      _progress = 0;
    });

    final apkPath = await UpdateService.downloadApk(
      widget.info.updateUrl,
      onProgress: (value) {
        if (!mounted) return;
        setState(() => _progress = value);
      },
    );

    if (!mounted) return;
    setState(() => _downloading = false);
    if (apkPath == null) {
      setState(() => _error = l10n.downloadFailed);
      return;
    }

    if (widget.info.sha256 != null && widget.info.sha256!.isNotEmpty) {
      setState(() => _verifying = true);
      final isValid = await UpdateService.verifySha256(apkPath, widget.info.sha256!);
      if (!mounted) return;
      setState(() => _verifying = false);
      if (!isValid) {
        setState(() => _error = l10n.integrityCheckFailed);
        return;
      }
    }

    if (Platform.isAndroid) {
      final canInstall = await UpdateService.canRequestInstallPackages();
      if (!canInstall) {
        if (!mounted) return;
        final width = MediaQuery.of(context).size.width;
        final horizontalInset = (width * 0.08).clamp(12.0, 28.0);
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: horizontalInset,
              vertical: 24,
            ),
            child: GlassCard(
              borderRadius: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.installPermissionTitle,
                    style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.installPermissionContent),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.outline(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          child: Text(l10n.openSettingsButton),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (openSettings ?? false) {
          await UpdateService.openInstallSettings();
        } else {
          if (!mounted) return;
          setState(() => _error = l10n.installPermissionRequired);
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() => _installing = true);
    final installed = await UpdateService.installApk(apkPath);
    if (!mounted) return;
    setState(() => _installing = false);
    if (!installed) {
      setState(() => _error = l10n.installFailed);
    }
  }

  List<_ReleaseSection> _parseSections(AppLocalizations l10n) {
    final normalized = widget.info.notes.trim();
    if (normalized.isEmpty) {
      return [
        _ReleaseSection(
          title: l10n.releaseSectionNew,
          items: [l10n.noUpdateDescription],
        ),
      ];
    }

    final lines = normalized
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final grouped = <String, List<String>>{
      'new': <String>[],
      'improved': <String>[],
      'fixed': <String>[],
      'security': <String>[],
    };
    final fallback = <String>[];

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.startsWith('new:')) {
        grouped['new']!.add(line.substring(4).trim());
      } else if (lower.startsWith('improved:')) {
        grouped['improved']!.add(line.substring(9).trim());
      } else if (lower.startsWith('fixed:')) {
        grouped['fixed']!.add(line.substring(6).trim());
      } else if (lower.startsWith('security:')) {
        grouped['security']!.add(line.substring(9).trim());
      } else if (line.startsWith('-') || line.startsWith('•')) {
        fallback.add(line.substring(1).trim());
      } else {
        fallback.add(line);
      }
    }

    final sections = <_ReleaseSection>[];
    if (grouped['new']!.isNotEmpty) {
      sections.add(_ReleaseSection(title: l10n.releaseSectionNew, items: grouped['new']!));
    }
    if (grouped['improved']!.isNotEmpty) {
      sections.add(_ReleaseSection(
        title: l10n.releaseSectionImproved,
        items: grouped['improved']!,
      ));
    }
    if (grouped['fixed']!.isNotEmpty) {
      sections.add(_ReleaseSection(title: l10n.releaseSectionFixed, items: grouped['fixed']!));
    }
    if (grouped['security']!.isNotEmpty) {
      sections.add(_ReleaseSection(
        title: l10n.releaseSectionSecurity,
        items: grouped['security']!,
      ));
    }
    if (fallback.isNotEmpty) {
      sections.add(_ReleaseSection(title: l10n.whatsNewLabel, items: fallback));
    }
    return sections;
  }

  String _statusLabel(AppLocalizations l10n) {
    if (widget.info.forceUpdate) {
      return l10n.updateStatusRequired;
    }
    return l10n.updateStatusRecommended;
  }

  String _integrityValue(AppLocalizations l10n) {
    if (_error == l10n.integrityCheckFailed) {
      return l10n.updateTrustFailed;
    }
    if (_verifying) return l10n.checkingIntegrity;
    if (widget.info.sha256 == null || widget.info.sha256!.isEmpty) {
      return l10n.updateTrustUnavailable;
    }
    if (_progress >= 1 && !_verifying && _error == null) {
      return l10n.updateTrustVerified;
    }
    return l10n.updateTrustPending;
  }

  String _sourceHost(AppLocalizations l10n) {
    final uri = Uri.tryParse(widget.info.updateUrl);
    final host = uri?.host.trim() ?? '';
    return host.isEmpty ? l10n.updateTrustUnknown : host;
  }

  bool _isPreviewBuild() {
    final version = widget.info.latestVersion.toLowerCase();
    final notes = widget.info.notes.toLowerCase();
    final host = Uri.tryParse(widget.info.updateUrl)?.host.toLowerCase() ?? '';
    return version.contains('dev') ||
        notes.contains('debug preview') ||
        host == 'example.com';
  }

  Widget _buildPreviewBuildCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.science_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.updatePreviewModeTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.updatePreviewModeSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.subtitleText(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SettingsPill(
                icon: Icons.draw_rounded,
                label: widget.info.latestVersion,
              ),
              SettingsPill(
                icon: Icons.notes_rounded,
                label: widget.info.notes.trim().isEmpty
                    ? l10n.updatePreviewModeEmptyNotes
                    : widget.info.notes.trim(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRing(BuildContext context) {
    final theme = Theme.of(context);
    final activity = _downloading || _verifying || _installing;
    final displayProgress = _downloading ? _progress : activity ? null : 0.0;

    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.18),
            theme.colorScheme.tertiary.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 124,
            height: 124,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              value: displayProgress,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              _installing
                  ? Icons.download_done_rounded
                  : _verifying
                      ? Icons.verified_rounded
                      : Icons.system_update_alt_rounded,
              size: 42,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionStrip(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: _VersionColumn(
              label: l10n.updateCurrentVersionLabel,
              value: _currentVersion.isNotEmpty ? _currentVersion : '...',
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_forward_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: _VersionColumn(
              label: l10n.updateIncomingVersionLabel,
              value: widget.info.latestVersion,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sections = _parseSections(l10n);
    final isPreviewBuild = _isPreviewBuild();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShadIconButton.ghost(
                          onPressed: widget.info.forceUpdate
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.updateAvailableTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SettingsHeroCard(
                      icon: Icons.system_update_alt_rounded,
                      title: l10n.updateHeroTitle,
                      subtitle: l10n.updateHeroSubtitle,
                      badges: [
                        SettingsPill(
                          icon: widget.info.forceUpdate
                              ? Icons.priority_high_rounded
                              : Icons.verified_rounded,
                          label: _statusLabel(l10n),
                        ),
                        if (_selectedAbi.isNotEmpty)
                          SettingsPill(
                            icon: Icons.memory_rounded,
                            label: _selectedAbi,
                          ),
                      ],
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final vertical = constraints.maxWidth < 620;
                          return Flex(
                            direction: vertical ? Axis.vertical : Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRing(context),
                              SizedBox(
                                width: vertical ? 0 : 24,
                                height: vertical ? 20 : 0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildVersionStrip(context),
                                    const SizedBox(height: 16),
                                    if (_error != null)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: theme.colorScheme.error
                                                .withValues(alpha: 0.22),
                                          ),
                                        ),
                                        child: Text(
                                          _error!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SettingsSectionHeader(
                      title: l10n.updatePipelineTitle,
                      subtitle: l10n.updatePipelineSubtitle,
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          MediaQuery.of(context).size.width < 760 ? 1 : 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          MediaQuery.of(context).size.width < 760 ? 3.6 : 1.9,
                      children: [
                        SettingsStageTile(
                          title: l10n.updateStageDownloadTitle,
                          subtitle: _downloading
                              ? l10n.downloadingProgress(
                                  (_progress * 100).clamp(0, 100).toInt(),
                                )
                              : l10n.updateStageDownloadSubtitle,
                          state: _stageState(0),
                        ),
                        SettingsStageTile(
                          title: l10n.updateStageVerifyTitle,
                          subtitle: _verifying
                              ? l10n.checkingIntegrity
                              : l10n.updateStageVerifySubtitle,
                          state: _stageState(1),
                        ),
                        SettingsStageTile(
                          title: l10n.updateStageInstallTitle,
                          subtitle: _installing
                              ? l10n.requestingInstall
                              : l10n.updateStageInstallSubtitle,
                          state: _stageState(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SettingsSectionHeader(
                      title: isPreviewBuild
                          ? l10n.updatePreviewModeTitle
                          : l10n.releaseSummaryTitle,
                      subtitle: isPreviewBuild
                          ? l10n.updatePreviewModeSubtitle
                          : l10n.releaseSummarySubtitle,
                    ),
                    const SizedBox(height: 14),
                    if (isPreviewBuild)
                      _buildPreviewBuildCard(context)
                    else
                      ...sections.map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...section.items.map(
                                  (item) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SettingsSectionHeader(
                      title: l10n.updateTrustTitle,
                      subtitle: l10n.updateTrustSubtitle,
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        children: [
                          _TrustRow(
                            label: l10n.updateTrustSource,
                            value: _sourceHost(l10n),
                          ),
                          const Divider(height: 20),
                          _TrustRow(
                            label: l10n.updateTrustIntegrity,
                            value: _integrityValue(l10n),
                          ),
                          const Divider(height: 20),
                          _TrustRow(
                            label: l10n.updateTrustPlatform,
                            value: widget.info.platform?.isNotEmpty ?? false
                                ? widget.info.platform!
                                : Platform.operatingSystem,
                          ),
                          const Divider(height: 20),
                          _TrustRow(
                            label: l10n.updateTrustAbi,
                            value: _selectedAbi.isNotEmpty
                                ? _selectedAbi
                                : l10n.updateTrustUnknown,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ShadButton.outline(
                            onPressed: widget.info.forceUpdate ||
                                    _downloading ||
                                    _verifying ||
                                    _installing
                                ? null
                                : () => Navigator.of(context).maybePop(),
                            child: Text(
                              widget.info.forceUpdate
                                  ? l10n.updateMandatory
                                  : l10n.laterButton,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ShadButton(
                            onPressed:
                                _downloading || _verifying || _installing
                                    ? null
                                    : _startDownload,
                            child: Text(
                              _installing
                                  ? l10n.installingLabel
                                  : _verifying
                                      ? l10n.checkingIntegrity
                                      : _downloading
                                          ? l10n.downloadingLabel
                                          : l10n.updateButton,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionColumn extends StatelessWidget {
  const _VersionColumn({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.subtitleText(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.subtitleText(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
