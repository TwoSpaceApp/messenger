import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _searchType = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  Future<void> _performSearch() async {
    if (_queryController.text.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final chatService = AegisChatService();
      final searchResults = await chatService.searchMessages(
        query: _queryController.text,
        type: _searchType,
      );
      setState(() => _results = searchResults);
    } on Object catch (_) {
      setState(() => _results = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_dateFrom ?? DateTime.now())
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.advancedSearchTitle),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 1100
                  ? 860.0
                  : double.infinity;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          borderRadius: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShadInput(
                                controller: _queryController,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _performSearch(),
                                placeholder: Text(l10n.searchQueryHint),
                                leading: const Icon(Icons.search, size: 18),
                                trailing: _isSearching
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : (_queryController.text.isEmpty
                                          ? null
                                          : ShadIconButton.ghost(
                                              width: 32,
                                              height: 32,
                                              onPressed: () {
                                                _queryController.clear();
                                                setState(() => _results = []);
                                              },
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                              ),
                                            )),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.searchTypeLabel,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ['all', 'messages', 'media', 'users']
                                    .map(
                                      (type) => _searchType == type
                                          ? ShadButton.secondary(
                                              onPressed: () {},
                                              height: 36,
                                              child: Text(
                                                type == 'all'
                                                    ? l10n.searchTypeAll
                                                    : type == 'messages'
                                                    ? l10n.searchTypeMessages
                                                    : type == 'media'
                                                    ? l10n.searchTypeMedia
                                                    : l10n.searchTypeUsers,
                                              ),
                                            )
                                          : ShadButton.outline(
                                              onPressed: () => setState(
                                                () => _searchType = type,
                                              ),
                                              height: 36,
                                              child: Text(
                                                type == 'all'
                                                    ? l10n.searchTypeAll
                                                    : type == 'messages'
                                                    ? l10n.searchTypeMessages
                                                    : type == 'media'
                                                    ? l10n.searchTypeMedia
                                                    : l10n.searchTypeUsers,
                                              ),
                                            ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.periodLabel,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DateTriggerCard(
                                      label: l10n.fromDate,
                                      value: _dateFrom == null
                                          ? null
                                          : _formatDate(_dateFrom!),
                                      icon: Icons.calendar_today_outlined,
                                      onTap: () => _pickDate(isFrom: true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _DateTriggerCard(
                                      label: l10n.toDate,
                                      value: _dateTo == null
                                          ? null
                                          : _formatDate(_dateTo!),
                                      icon: Icons.event_available_outlined,
                                      onTap: () => _pickDate(isFrom: false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ShadButton(
                                onPressed: _isSearching ? null : _performSearch,
                                width: double.infinity,
                                leading: const Icon(Icons.search, size: 18),
                                child: Text(l10n.searchButton),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_results.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              l10n.resultsCount(_results.length),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        else if (!_isSearching &&
                            _queryController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AppEmptyState(
                              title: l10n.nothingFound,
                              message: l10n.noResultsFound,
                              icon: Icons.manage_search_rounded,
                            ),
                          ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _results.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            final sender =
                                result['sender']?.toString() ?? 'Unknown';
                            final body =
                                result['content']?['body']?.toString() ?? '';
                            return GlassCard(
                              borderRadius: 18,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      sender.isNotEmpty ? sender[0] : '?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sender,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          body,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}

class _DateTriggerCard extends StatelessWidget {
  const _DateTriggerCard({
    required this.label,
    required this.icon,
    required this.onTap,
    this.value,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      borderRadius: 18,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
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
                    const SizedBox(height: 4),
                    Text(value ?? label),
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
