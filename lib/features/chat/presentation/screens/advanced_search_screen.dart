// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
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
    } catch (e) {
      setState(() => _results = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.advancedSearchTitle),
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
                    padding: const EdgeInsets.all(UITokens.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search input
                        TextField(
                          controller: _queryController,
                          onSubmitted: (_) => _performSearch(),
                          decoration: InputDecoration(
                            hintText: l10n.searchQueryHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _isSearching
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: UITokens.borderThick,
                                      ),
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UITokens.corner,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceMd),

                        // Search type filter
                        Text(
                          l10n.searchTypeLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: UITokens.spaceSm),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['all', 'messages', 'media', 'users']
                                .map(
                                  (type) => Padding(
                                    padding: const EdgeInsets.only(
                                      right: UITokens.spaceSm,
                                    ),
                                    child: FilterChip(
                                      label: Text(
                                        type == 'all'
                                            ? l10n.searchTypeAll
                                            : type == 'messages'
                                            ? l10n.searchTypeMessages
                                            : type == 'media'
                                            ? l10n.searchTypeMedia
                                            : l10n.searchTypeUsers,
                                      ),
                                      selected: _searchType == type,
                                      onSelected: (selected) {
                                        if (selected)
                                          setState(() => _searchType = type);
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceMd),

                        // Date filters
                        Text(
                          l10n.periodLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: UITokens.spaceSm),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _dateFrom ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null)
                                    setState(() => _dateFrom = picked);
                                },
                                child: GlassCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      UITokens.space,
                                    ),
                                    child: Text(
                                      _dateFrom == null
                                          ? l10n.fromDate
                                          : '${_dateFrom!.day}.${_dateFrom!.month}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: UITokens.space),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _dateTo ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null)
                                    setState(() => _dateTo = picked);
                                },
                                child: GlassCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      UITokens.space,
                                    ),
                                    child: Text(
                                      _dateTo == null
                                          ? l10n.toDate
                                          : '${_dateTo!.day}.${_dateTo!.month}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UITokens.spaceMd),

                        // Search button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSearching ? null : _performSearch,
                            icon: const Icon(Icons.search),
                            label: Text(l10n.searchButton),
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceXLg),

                        // Results
                        if (_results.isNotEmpty)
                          Text(
                            l10n.resultsCount(_results.length),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        else if (!_isSearching &&
                            _queryController.text.isNotEmpty)
                          Text(
                            l10n.noResultsFound,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        const SizedBox(height: UITokens.space),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            final sender =
                                result['sender']?.toString() ?? 'Unknown';
                            final body =
                                result['content']?['body']?.toString() ?? '';
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  sender.isNotEmpty ? sender[0] : '?',
                                ),
                              ),
                              title: Text(sender),
                              subtitle: Text(
                                body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
