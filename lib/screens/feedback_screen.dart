import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/widgets/glass_card.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  String _category = 'Функции';
  bool _sending = false;

  String _appVersion = '...';

  final Map<String, bool> _ideas = {
    'Сквозное E2E-шифрование (Olm/Megolm) + верификация устройств': false,
    'Резервное копирование чатов (локально/облако) + перенос на новое устройство': false,
    'Треды, реакции и упоминания, улучшенный поиск по сообщениям': false,
    'Голосовые/видео-звонки и быстрые voice rooms': false,
    'Папки/категории чатов и умные фильтры уведомлений': false,
    'Боты и интеграции (вебхуки, GitHub/Jira, напоминания)': false,
    'Режим “медленного интернета” + агрессивное кэширование медиа': false,
  };

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

  String _buildMessage() {
    final selected = _ideas.entries.where((e) => e.value).map((e) => '- ${e.key}').join('\n');

    final title = _titleController.text.trim();
    final details = _detailsController.text.trim();

    return [
      'TwoSpace — предложение/улучшение',
      'Версия: $_appVersion',
      'Категория: $_category',
      if (title.isNotEmpty) 'Коротко: $title',
      if (selected.isNotEmpty) ...[
        '',
        'Что было бы особенно круто:',
        selected,
      ],
      if (details.isNotEmpty) ...[
        '',
        'Детали:',
        details,
      ],
    ].join('\n');
  }

  Future<void> _copy() async {
    if (!_formKey.currentState!.validate()) return;
    final text = _buildMessage();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Текст скопирован')),
    );
  }

  Future<void> _share() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final text = _buildMessage();
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'TwoSpace — предложение',
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предложить улучшение'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Функции', child: Text('Функции')),
                          DropdownMenuItem(value: 'UX/Дизайн', child: Text('UX/Дизайн')),
                          DropdownMenuItem(value: 'Производительность', child: Text('Производительность')),
                          DropdownMenuItem(value: 'Безопасность/Приватность', child: Text('Безопасность/Приватность')),
                          DropdownMenuItem(value: 'Синхронизация/Сеть', child: Text('Синхронизация/Сеть')),
                        ],
                        onChanged: (v) => setState(() => _category = v ?? 'Функции'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Короткое описание',
                          hintText: 'Например: “Бэкап чатов в облако”',
                        ),
                        validator: (v) {
                          final anyIdeaSelected = _ideas.values.any((x) => x);
                          final hasTitle = (v ?? '').trim().isNotEmpty;
                          if (!anyIdeaSelected && !hasTitle) {
                            return 'Выберите хотя бы одну идею или напишите описание';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _detailsController,
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Детали (опционально)',
                          hintText: 'Что именно должно работать, как сейчас и как хотелось бы?',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Большие нововведения (выберите, что интереснее всего)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: _ideas.entries.map((e) {
                      return CheckboxListTile(
                        value: e.value,
                        dense: false,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(e.key),
                        onChanged: (v) => setState(() => _ideas[e.key] = v ?? false),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sending ? null : _copy,
                        icon: const Icon(Icons.copy),
                        label: const Text('Скопировать'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _share,
                        icon: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: const Text('Поделиться'),
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
