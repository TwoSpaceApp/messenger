import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      setState(() => _contacts = contacts);
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text('Контакты', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
               ),
               Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_permissionDenied) {
      return Center(child: Text('Нет разрешения на доступ к контактам'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_contacts!.isEmpty) {
      return const Center(child: Text('Контакты не найдены'));
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, index) {
        final contact = _contacts![index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: (contact.photo != null) 
                  ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(contact.displayName),
              subtitle: contact.phones.isNotEmpty ? Text(contact.phones.first.number) : null,
              onTap: () {
                  // Handle tap
              },
            ),
          ),
        );
      },
    );
  }
}
