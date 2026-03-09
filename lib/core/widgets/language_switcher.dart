import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

/// Данные о языке: код, родное название, код страны для флага
class _LangInfo {
  const _LangInfo(this.code, this.native, this.countryCode);
  final String code;
  final String native;
  final String countryCode;

  String get flagUrl => 'https://flagcdn.com/w80/$countryCode.png';
}

const _languages = [
  _LangInfo('de', 'Deutsch', 'de'),
  _LangInfo('en', 'English', 'gb'),
  _LangInfo('es', 'Español', 'es'),
  _LangInfo('fr', 'Français', 'fr'),
  _LangInfo('it', 'Italiano', 'it'),
  _LangInfo('ja', '日本語', 'jp'),
  _LangInfo('ko', '한국어', 'kr'),
  _LangInfo('pl', 'Polski', 'pl'),
  _LangInfo('ru', 'Русский', 'ru'),
  _LangInfo('zh', '中文', 'cn'),
];

/// Компактная кнопка «глобус + текущий язык».
///
/// При нажатии открывает красивый bottom-sheet со списком языков.
/// Работает через [SettingsService.setLanguage], изменение подхватывается
/// [MaterialApp.locale] через [ValueListenableBuilder] в main.dart.
class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key, this.showLabel = true});

  /// Показывать ли текстовую метку рядом с иконкой
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.languageNotifier,
      builder: (context, lang, _) {
        final info = _languages.firstWhere(
          (l) => l.code == lang,
          orElse: () => const _LangInfo('en', 'English', 'gb'),
        );
        return _LanguageButton(info: info, showLabel: showLabel);
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.info, required this.showLabel});
  final _LangInfo info;
  final bool showLabel;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: info.flagUrl,
                  width: 24,
                  height: 18,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                      width: 24,
                      height: 18,
                      color: Colors.grey.withValues(alpha: 0.3)),
                  errorWidget: (context, url, err) =>
                      const Icon(Icons.language, size: 18),
                ),
              ),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LanguagePickerSheet(currentCode: info.code),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.currentCode});
  final String currentCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.85),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.language_rounded,
                        color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.languageLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Список языков ─────────────────────────────────────────────────
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _languages.length,
                itemBuilder: (_, i) {
                  final lang = _languages[i];
                  final selected = lang.code == currentCode;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Material(
                      color: selected
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(context);
                          SettingsService.setLanguage(lang.code);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: lang.flagUrl,
                                  width: 36,
                                  height: 26,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 36,
                                    height: 26,
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                  errorWidget: (context, url, err) => Container(
                                    width: 36,
                                    height: 26,
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.error_outline,
                                        size: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  lang.native,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (selected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: theme.colorScheme.onPrimary,
                                  ),
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
  }
}
