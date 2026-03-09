import 'package:flutter/material.dart';
import 'package:two_space_app/features/people/presentation/screens/people_screen.dart';

class SearchContactsScreen extends StatelessWidget {
  const SearchContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PeopleScreen(autofocusSearch: true);
  }
}
