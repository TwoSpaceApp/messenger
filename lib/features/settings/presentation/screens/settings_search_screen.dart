import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/highlighted_text.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/presentation/models/settings_catalog.dart';

class SettingsSearchScreen extends StatefulWidget {
  const SettingsSearchScreen({super.key});

  @override
  State<SettingsSearchScreen> createState() => _SettingsSearchScreenState();
}

class _SettingsSearchScreenState extends State<SettingsSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  String _query = '';
  String? _sectionFilter;

  List<SettingsSearchEntry> _entries(AppLocalizations l10n) {
    return buildSettingsSearchEntries(l10n);
  }

  List<String> _sections(AppLocalizations l10n) {
    return _entries(l10n).map((entry) => entry.section).toSet().toList()
      ..sort();
  }

  List<SettingsSearchEntry> _filteredEntries(AppLocalizations l10n) {
    final query = _query.trim().toLowerCase();
    return _entries(l10n).where((entry) {
      final matchesSection =
          _sectionFilter == null || entry.section == _sectionFilter;
      if (!matchesSection) return false;
      if (query.isEmpty) return true;
      return entry.searchText.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearQuery() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = _filteredEntries(l10n);
    final sections = _sections(l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ShadInput(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  placeholder: Text(l10n.searchTypeLabel),
                  leading: const Icon(Icons.search_rounded, size: 18),
                  trailing: _query.isEmpty
                      ? null
                      : ShadIconButton.ghost(
                          width: 32,
                          height: 32,
                          onPressed: _clearQuery,
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _sectionFilter == section
                            ? ShadButton.secondary(
                                onPressed: () =>
                                    setState(() => _sectionFilter = null),
                                height: 36,
                                child: Text(section),
                              )
                            : ShadButton.outline(
                                onPressed: () =>
                                    setState(() => _sectionFilter = section),
                                height: 36,
                                child: Text(section),
                              ),
                      ),
                    ),
                    if (_sectionFilter != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ShadIconButton.ghost(
                          width: 36,
                          height: 36,
                          onPressed: () =>
                              setState(() => _sectionFilter = null),
                          icon: const Icon(
                            Icons.filter_alt_off_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: entries.isEmpty
                    ? AppEmptyState(
                        title: l10n.nothingFound,
                        message: l10n.noResultsFound,
                        icon: Icons.manage_search_rounded,
                      )
                    : ListView.separated(
                        key: ValueKey('${_query}_${_sectionFilter ?? 'all'}'),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return GlassCard(
                            borderRadius: 18,
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => entry.onTap(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        entry.icon,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          HighlightedText(
                                            entry.title,
                                            query: _query,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          HighlightedText(
                                            entry.subtitle,
                                            query: _query,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.72),
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.09),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              entry.section,
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
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
      ),
    );
  }
}
