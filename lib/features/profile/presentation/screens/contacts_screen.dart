import 'package:flutter/material.dart';
import 'package:two_space_app/features/people/presentation/screens/people_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PeopleScreen(simplified: true);
  }
}
