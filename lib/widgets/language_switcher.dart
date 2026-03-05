import 'package:flutter/material.dart';
import 'package:two_space_app/services/settings_service.dart';

/// Данные о языке: код, родное название, флаг-эмодзи
class _LangInfo {
  final String code;
  final String native;
  final String flag;
  const _LangInfo(this.code, this.native, this.flag);
}

const _languages = [
  _LangInfo('de', 'Deutsch', '🇩🇪'),
  _LangInfo('en', 'English', '🇬🇧'),
  _LangInfo('es', 'Español', '🇪🇸'),
  _LangInfo('fr', 'Français', '🇫🇷'),
  _LangInfo('it', 'Italiano', '🇮🇹'),
  _LangInfo('ja', '日本語', '🇯🇵'),
  _LangInfo('ko', '한국어', '🇰🇷'),
  _LangInfo('pl', 'Polski', '🇵🇱'),
  _LangInfo('ru', 'Русский', '🇷🇺'),
  _LangInfo('zh', '中文', '🇨🇳'),
];

/// Компактная кнопка «глобус + текущий язык».
///
/// При нажатии открывает красивый bottom-sheet со списком языков.
/// Работает через [SettingsService.setLanguage], изменение подхватывается
/// [MaterialApp.locale] через [ValueListenableBuilder] в main.dart.
class LanguageSwitcherButton extends StatelessWidget {
  /// Показывать ли текстовую метку рядом с иконкой
  final bool showLabel;
  const LanguageSwitcherButton({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.languageNotifier,
      builder: (context, lang, _) {
        final info = _languages.firstWhere(
          (l) => l.code == lang,
          orElse: () => const _LangInfo('en', 'English', '🇬🇧'),
        );
        return _LanguageButton(info: info, showLabel: showLabel);
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final _LangInfo info;
  final bool showLabel;
  const _LanguageButton({required this.info, required this.showLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(180),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(60),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.flag, style: const TextStyle(fontSize: 18, height: 1.2)),
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  info.code.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LanguagePickerSheet(currentCode: info.code),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  final String currentCode;
  const _LanguagePickerSheet({required this.currentCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Ручка ──────────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Icon(Icons.language_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Language / Язык',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Список языков ─────────────────────────────────────────────────
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _languages.length,
            itemBuilder: (_, i) {
              final lang = _languages[i];
              final selected = lang.code == currentCode;
              return ListTile(
                leading: Text(
                  lang.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  lang.native,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                selected: selected,
                selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                onTap: () {
                  Navigator.pop(context);
                  SettingsService.setLanguage(lang.code);
                },
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
