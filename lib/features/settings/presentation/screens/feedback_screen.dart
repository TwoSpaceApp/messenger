import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suggestImprovementLabel),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: InputDecoration(
                          labelText: l10n.categoryLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'features',
                              child: Text(l10n.feedbackCategoryFeatures)),
                          DropdownMenuItem(
                              value: 'ux_design',
                              child: Text(l10n.feedbackCategoryUxDesign)),
                          DropdownMenuItem(
                              value: 'performance',
                              child: Text(l10n.feedbackCategoryPerformance)),
                          DropdownMenuItem(
                              value: 'security',
                              child: Text(l10n.feedbackCategorySecurity)),
                          DropdownMenuItem(
                              value: 'network',
                              child: Text(l10n.feedbackCategoryNetworkSync)),
                        ],
                        onChanged: (v) =>
                            setState(() => _category = v ?? 'features'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.shortDescriptionLabel,
                          hintText: l10n.shortDescriptionHint,
                        ),
                        validator: (v) {
                          final hasTitle = (v ?? '').trim().isNotEmpty;
                          final hasDetails =
                              _detailsController.text.trim().isNotEmpty;
                          if (!hasTitle && !hasDetails) {
                            return l10n.feedbackValidation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _detailsController,
                        minLines: 3,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: l10n.detailsOptionalLabel,
                          hintText: l10n.detailsHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sending ? null : _copy,
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.copyButton),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _send,
                        icon: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(l10n.sendButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
