import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  String _category = 'features';
  bool _sending = false;

  String _appVersion = '...';

  String _categoryLabel(AppLocalizations l10n) {
    switch (_category) {
      case 'features':
        return l10n.feedbackCategoryFeatures;
      case 'ux_design':
        return l10n.feedbackCategoryUxDesign;
      case 'performance':
        return l10n.feedbackCategoryPerformance;
      case 'security':
        return l10n.feedbackCategorySecurity;
      case 'network':
        return l10n.feedbackCategoryNetworkSync;
      default:
        return _category;
    }
  }

  List<(String, String)> _categoryItems(AppLocalizations l10n) {
    return [
      ('features', l10n.feedbackCategoryFeatures),
      ('ux_design', l10n.feedbackCategoryUxDesign),
      ('performance', l10n.feedbackCategoryPerformance),
      ('security', l10n.feedbackCategorySecurity),
      ('network', l10n.feedbackCategoryNetworkSync),
    ];
  }

  @override
  void initState() {
    super.initState();
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

  bool _hasFeedbackContent() {
    return _titleController.text.trim().isNotEmpty ||
        _detailsController.text.trim().isNotEmpty;
  }

  Future<void> _copy() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_hasFeedbackContent()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackValidation)));
      return;
    }
    final text = _buildMessage(l10n);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.textCopied)),
    );
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_hasFeedbackContent()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackValidation)));
      return;
    }
    setState(() => _sending = true);
    try {
      final text = _buildMessage(l10n);
      final telegramUri = Uri.parse(
        'https://t.me/twospace_messenger?direct&text=${Uri.encodeQueryComponent(text)}',
      );
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

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final items = _categoryItems(l10n);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in items)
                  ListTile(
                    title: Text(item.$2),
                    trailing: item.$1 == _category
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(item.$1),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _category = selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.suggestImprovementLabel),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ShadButton.outline(
                              onPressed: _pickCategory,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_categoryLabel(l10n)),
                                  const Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ShadInput(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            placeholder: Text(l10n.shortDescriptionHint),
                          ),
                          const SizedBox(height: 12),
                          ShadInput(
                            controller: _detailsController,
                            minLines: 3,
                            maxLines: 8,
                            placeholder: Text(l10n.detailsHint),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 420;
                        final copyButton = ShadButton.outline(
                          onPressed: _sending ? null : _copy,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.copy, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.copyButton),
                            ],
                          ),
                        );
                        final sendButton = ShadButton(
                          onPressed: _sending ? null : _send,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_sending)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Icon(Icons.send, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.sendButton),
                            ],
                          ),
                        );

                        if (isCompact) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: copyButton,
                              ),
                              const SizedBox(height: 12),
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
                            const SizedBox(width: 12),
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
        ),
      ),
    );
  }
}
