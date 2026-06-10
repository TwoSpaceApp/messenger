import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/dev_log_export_service.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';
import 'package:two_space_app/core/services/media_file_service.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:url_launcher/url_launcher.dart';

class _FeedbackCategoryOption {
  const _FeedbackCategoryOption({
    required this.value,
    required this.icon,
    required this.label,
  });

  final String value;
  final IconData icon;
  final String label;
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  String _category = 'features';
  bool _attachLogs = false;
  bool _sending = false;

  String _appVersion = '...';

  List<_FeedbackCategoryOption> _categoryOptions(AppLocalizations l10n) {
    return <_FeedbackCategoryOption>[
      _FeedbackCategoryOption(
        value: 'features',
        icon: Icons.auto_awesome_rounded,
        label: l10n.feedbackCategoryFeatures,
      ),
      _FeedbackCategoryOption(
        value: 'ux_design',
        icon: Icons.design_services_rounded,
        label: l10n.feedbackCategoryUxDesign,
      ),
      _FeedbackCategoryOption(
        value: 'performance',
        icon: Icons.speed_rounded,
        label: l10n.feedbackCategoryPerformance,
      ),
      _FeedbackCategoryOption(
        value: 'security',
        icon: Icons.security_rounded,
        label: l10n.feedbackCategorySecurity,
      ),
      _FeedbackCategoryOption(
        value: 'network',
        icon: Icons.sync_rounded,
        label: l10n.feedbackCategoryNetworkSync,
      ),
    ];
  }

  _FeedbackCategoryOption _selectedCategory(AppLocalizations l10n) {
    return _categoryOptions(l10n).firstWhere(
      (option) => option.value == _category,
      orElse: () => _categoryOptions(l10n).first,
    );
  }

  String _categoryLabel(AppLocalizations l10n) => _selectedCategory(l10n).label;

  Uri _telegramUri(String text) {
    return Uri.parse(
      'https://t.me/twospace_messenger?direct&text=${Uri.encodeQueryComponent(text)}',
    );
  }

  Future<void> _showCategoryPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final options = _categoryOptions(l10n);

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(UITokens.corner2XL),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: UITokens.space),
                  width: UITokens.dragHandleWidth,
                  height: UITokens.dragHandleHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(UITokens.corner2XS),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UITokens.spaceLg,
                    0,
                    UITokens.spaceLg,
                    UITokens.spaceSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(UITokens.spaceSm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(UITokens.corner),
                        ),
                        child: Icon(
                          Icons.category_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: UITokens.spaceMd),
                      Expanded(
                        child: Text(
                          l10n.categoryLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: UITokens.spaceSm),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final selected = option.value == _category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UITokens.spaceMd,
                          vertical: UITokens.space2XS,
                        ),
                        child: Material(
                          color: selected
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(UITokens.cornerLg),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(UITokens.cornerLg),
                            onTap: () => Navigator.of(sheetContext).pop(option.value),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: UITokens.spaceMd,
                                vertical: UITokens.space,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    option.icon,
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: UITokens.spaceMd),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null || selected == _category) {
      return;
    }
    setState(() => _category = selected);
  }

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: version load result handled within the method
    // ignore: discarded_futures
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _appVersion = 'unknown');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String _buildMessage(AppLocalizations l10n) {
    final title = _titleController.text.trim();
    final details = _detailsController.text.trim();

    return [
      l10n.feedbackMessageHeader,
      l10n.feedbackVersion(_appVersion),
      l10n.feedbackCategoryLine(_categoryLabel(l10n)),
      if (title.isNotEmpty) l10n.feedbackShortTitle(title),
      if (details.isNotEmpty) ...[
        '',
        l10n.feedbackDetailsLine,
        details,
      ],
    ].join('\n');
  }

  Future<void> _copy() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final text = _buildMessage(l10n);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.textCopied)),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      final text = _buildMessage(l10n);
      if (_attachLogs) {
        final logFilePath = await DevLogExportService.createBundleFile(
          appLogs: DevLogger.all,
          networkLogs: DevNetworkLogger.instance.logs,
        );
        final isMobileShare =
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS);

        if (isMobileShare) {
          await SharePlus.instance.share(
            ShareParams(
              text: text,
              subject: l10n.feedbackShareSubject,
              files: <XFile>[XFile(logFilePath)],
            ),
          );
          return;
        }

        final savedPath = await MediaFileService.saveAs(
          logFilePath,
          suggestedName: MediaFileService.resolvedFileName(logFilePath),
        );
        if (!mounted || savedPath == null) {
          return;
        }
        await Clipboard.setData(ClipboardData(text: text));
        final launched = await launchUrl(
          _telegramUri(text),
          mode: LaunchMode.externalApplication,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              launched
                  ? l10n.fileDownloaded(savedPath)
                  : l10n.shareSheetFailed,
            ),
          ),
        );
        return;
      }

      final telegramUri = _telegramUri(text);
      await Clipboard.setData(ClipboardData(text: text));
      final launched = await launchUrl(
        telegramUri,
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shareSheetFailed)),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.textCopied)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final list = SafeArea(
      top: !widget.embedded,
      child: ListView(
        padding: const EdgeInsets.all(UITokens.spaceMd),
        children: [
          if (widget.embedded) ...[
            SectionPageHeader(
              title: l10n.suggestImprovementLabel,
              subtitle: l10n.suggestImprovementSubtitle,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(height: UITokens.space),
          ],
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UITokens.spaceMd,
                    vertical: UITokens.space,
                  ),
                  child: Column(
                    children: [
                      _FeedbackSelectionField(
                        icon: _selectedCategory(l10n).icon,
                        label: l10n.categoryLabel,
                        value: _categoryLabel(l10n),
                        onTap: _sending ? null : _showCategoryPicker,
                      ),
                      const SizedBox(height: UITokens.space),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.shortDescriptionLabel,
                          hintText: l10n.shortDescriptionHint,
                        ),
                        validator: (v) {
                          final hasTitle = (v ?? '').trim().isNotEmpty;
                          final hasDetails = _detailsController.text
                              .trim()
                              .isNotEmpty;
                          if (!hasTitle && !hasDetails) {
                            return l10n.feedbackValidation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: UITokens.space),
                      TextFormField(
                        controller: _detailsController,
                        minLines: 3,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: l10n.detailsOptionalLabel,
                          hintText: l10n.detailsHint,
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceSm),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.feedbackAttachLogsLabel),
                        subtitle: Text(l10n.feedbackAttachLogsSubtitle),
                        value: _attachLogs,
                        onChanged: _sending
                            ? null
                            : (value) => setState(() => _attachLogs = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UITokens.spaceMd),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 420;
                    final copyButton = OutlinedButton.icon(
                      onPressed: _sending ? null : _copy,
                      icon: const Icon(Icons.copy),
                      label: Text(l10n.copyButton),
                    );
                    final sendButton = ElevatedButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(l10n.sendButton),
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: copyButton,
                          ),
                          const SizedBox(height: UITokens.space),
                          SizedBox(
                            width: double.infinity,
                            child: sendButton,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: copyButton),
                        const SizedBox(width: UITokens.space),
                        Expanded(child: sendButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return list;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.suggestImprovementLabel),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(child: list),
    );
  }
}

class _FeedbackSelectionField extends StatelessWidget {
  const _FeedbackSelectionField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(UITokens.cornerLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(UITokens.space),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: UITokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: UITokens.space2XS),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: UITokens.spaceSm),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
