import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';
import 'package:two_space_app/widgets/app_logo.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  bool _permissionPermanentlyDenied = false;
  bool _loading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<Contact> get _filteredContacts {
    if (_contacts == null) return [];
    if (_searchQuery.isEmpty) return _contacts!;
    return _contacts!.where((c) {
      final name = c.displayName.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermission() async {
    setState(() => _loading = true);
    
    final status = await Permission.contacts.status;
    
    if (status.isGranted) {
      await _fetchContacts();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _permissionPermanentlyDenied = true;
        _permissionDenied = true;
        _loading = false;
      });
    } else {
      // Request permission
      final result = await Permission.contacts.request();
      
      if (result.isGranted) {
        await _fetchContacts();
      } else if (result.isPermanentlyDenied) {
        setState(() {
          _permissionPermanentlyDenied = true;
          _permissionDenied = true;
          _loading = false;
        });
      } else {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true, 
        withPhoto: true,
        sorted: true,
      );
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _loading = false;
          _permissionDenied = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _permissionDenied = true;
        });
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with TwoSpace logo
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const AppLogo(large: false),
                    const SizedBox(width: 8),
                    Text(
                      'Контакты',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search bar if contacts loaded
              if (_contacts != null && _contacts!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Поиск контактов...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(120)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                ),
              
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.contacts_outlined,
                  size: 64,
                  color: Colors.white.withAlpha(150),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Доступ к контактам',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _permissionPermanentlyDenied
                      ? 'Разрешение на доступ к контактам отклонено. Пожалуйста, откройте настройки приложения и предоставьте доступ.'
                      : 'Для отображения контактов необходимо разрешение на доступ к контактам устройства.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _permissionPermanentlyDenied 
                        ? _openAppSettings 
                        : _checkAndRequestPermission,
                    icon: Icon(_permissionPermanentlyDenied 
                        ? Icons.settings 
                        : Icons.refresh),
                    label: Text(_permissionPermanentlyDenied 
                        ? 'Открыть настройки' 
                        : 'Запросить разрешение'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_contacts == null || _contacts!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: Colors.white.withAlpha(150),
            ),
            const SizedBox(height: 16),
            Text(
              'Контакты не найдены',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ],
        ),
      );
    }
    
    final filteredContacts = _filteredContacts;
    
    if (filteredContacts.isEmpty) {
      return Center(
        child: Text(
          'Ничего не найдено',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withAlpha(150),
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchContacts,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = filteredContacts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(8),
              onTap: () => _showContactOptions(contact),
              child: ListTile(
                leading: contact.photo != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(contact.photo!),
                        radius: 24,
                      )
                    : CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                        child: Text(
                          contact.displayName.isNotEmpty 
                              ? contact.displayName[0].toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                title: Text(
                  contact.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: contact.phones.isNotEmpty 
                    ? Text(
                        contact.phones.first.number,
                        style: TextStyle(color: Colors.white.withAlpha(150)),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (contact.phones.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.white70),
                        onPressed: () => _callContact(contact),
                      ),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.white70),
                      onPressed: () => _messageContact(contact),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showContactOptions(Contact contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: contact.photo != null
                  ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(contact.displayName),
              subtitle: contact.phones.isNotEmpty 
                  ? Text(contact.phones.first.number)
                  : null,
            ),
            const Divider(),
            if (contact.phones.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.call),
                title: const Text('Позвонить'),
                onTap: () {
                  Navigator.pop(context);
                  _callContact(contact);
                },
              ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Написать сообщение'),
              onTap: () {
                Navigator.pop(context);
                _messageContact(contact);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _callContact(Contact contact) {
    if (contact.phones.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Звонок: ${contact.phones.first.number}')),
    );
  }

  void _messageContact(Contact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Сообщение для: ${contact.displayName}')),
    );
  }
}
