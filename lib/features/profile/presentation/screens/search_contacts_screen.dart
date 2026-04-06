import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/people/presentation/screens/people_screen.dart';

enum SearchContactsPurpose { browse, newChat, call }

class SearchContactsScreen extends StatelessWidget {
  const SearchContactsScreen({
    super.key,
    this.purpose = SearchContactsPurpose.browse,
  });

  final SearchContactsPurpose purpose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSelectionMode = purpose != SearchContactsPurpose.browse;
    return PeopleScreen(
      autofocusSearch: true,
      simplified: true,
      titleOverride: purpose == SearchContactsPurpose.newChat
          ? l10n.newChatTitle
          : l10n.searchContactsTitle,
      searchHintOverride: l10n.searchContactsHint,
      subtitleOverride: purpose == SearchContactsPurpose.newChat
          ? l10n.contactIdExplanation
          : purpose == SearchContactsPurpose.call
          ? l10n.callsSearchHint
          : l10n.searchContactsHint,
      showCallsShortcut: !isSelectionMode,
      onRemotePersonTap: isSelectionMode
          ? (person) async {
              Navigator.of(context).pop(person);
            }
          : null,
    );
  }
}
