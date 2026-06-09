// ignore_for_file: unnecessary_underscores // Needed for underscore-prefixed unused parameters

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/highlighted_text.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/features/settings/presentation/models/settings_catalog.dart';

class SettingsSearchScreen extends StatefulWidget {
  const SettingsSearchScreen({super.key, this.embedded = false});

  final bool embedded;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = _filteredEntries(l10n);
    final sections = _sections(l10n);

    final content = SafeArea(
      top: !widget.embedded,
      child: Column(
        children: [
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UITokens.spaceMd,
                UITokens.spaceSm,
                UITokens.spaceMd,
                UITokens.spaceSm,
              ),
              child: SectionPageHeader(
                title: l10n.settingsTitle,
                subtitle: l10n.searchTypeLabel,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UITokens.spaceMd,
              UITokens.spaceSm,
              UITokens.spaceMd,
              UITokens.spaceSm,
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                labelText: l10n.searchTypeLabel,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: UITokens.spaceMd),
              scrollDirection: Axis.horizontal,
              children: [
                ...sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(right: UITokens.spaceSm),
                    child: ChoiceChip(
                      label: Text(section),
                      selected: _sectionFilter == section,
                      onSelected: (selected) => setState(
                        () => _sectionFilter = selected ? section : null,
                      ),
                    ),
                  ),
                ),
                if (_sectionFilter != null)
                  IconButton(
                    onPressed: () => setState(() => _sectionFilter = null),
                    icon: const Icon(Icons.filter_alt_off_rounded),
                  ),
              ],
            ),
          ),
          const SizedBox(height: UITokens.spaceSm),
          Expanded(
            child: entries.isEmpty
                ? AppEmptyState(
                    title: l10n.nothingFound,
                    message: l10n.noResultsFound,
                    icon: Icons.manage_search_rounded,
                  )
                : ListView.separated(
                    key: ValueKey('${_query}_${_sectionFilter ?? 'all'}'),
                    padding: const EdgeInsets.fromLTRB(
                      UITokens.spaceMd,
                      0,
                      UITokens.spaceMd,
                      UITokens.spaceXLg,
                    ),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: UITokens.spaceSmMd),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerXLg,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            child: Icon(
                              entry.icon,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: HighlightedText(
                            entry.title,
                            query: _query,
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: UITokens.spaceXS),
                              HighlightedText(
                                entry.subtitle,
                                query: _query,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                                ),
                              ),
                              const SizedBox(height: UITokens.spaceSm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.09,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    UITokens.cornerPill,
                                  ),
                                ),
                                child: Text(
                                  entry.section,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => entry.onTap(context),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(child: content),
    );
  }
}
