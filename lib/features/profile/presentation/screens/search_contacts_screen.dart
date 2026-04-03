import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/people/presentation/screens/people_screen.dart';

class SearchContactsScreen extends StatelessWidget {
  const SearchContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PeopleScreen(
      autofocusSearch: true,
      simplified: true,
      titleOverride: l10n.searchContactsTitle,
      searchHintOverride: l10n.searchContactsHint,
    );
  }
}
