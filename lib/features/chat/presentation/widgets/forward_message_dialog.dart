// Forward message dialog
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';

class ForwardMessageDialog extends StatefulWidget {
  const ForwardMessageDialog({
    required this.availableChats,
    required this.onForward,
    super.key,
  });
  final List<Chat> availableChats;
  final Function(List<String> selectedChatIds) onForward;

  @override
  State<ForwardMessageDialog> createState() => _ForwardMessageDialogState();
}

class _ForwardMessageDialogState extends State<ForwardMessageDialog> {
  final Set<String> _selectedChats = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final filtered = widget.availableChats
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassCard(
        borderRadius: 24,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.forwardMessageTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ShadInput(
                placeholder: Text(l10n.searchChatHint),
                leading: const Icon(Icons.search, size: 18),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final chat = filtered[index];
                    final isSelected = _selectedChats.contains(chat.id);
                    return ShadCheckbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            _selectedChats.add(chat.id);
                          } else {
                            _selectedChats.remove(chat.id);
                          }
                        });
                      },
                      label: Text(chat.name),
                      sublabel: Text(
                        l10n.membersCount(chat.members.length),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadButton(
                      onPressed: _selectedChats.isEmpty
                          ? null
                          : () {
                              widget.onForward(_selectedChats.toList());
                              Navigator.pop(context);
                            },
                      child: Text(l10n.forwardButton(_selectedChats.length)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
