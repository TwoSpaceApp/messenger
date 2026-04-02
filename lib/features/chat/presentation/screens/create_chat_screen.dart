import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateChatScreen extends ConsumerStatefulWidget {
  const CreateChatScreen({super.key});

  @override
  ConsumerState<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends ConsumerState<CreateChatScreen> {
  final _searchController = TextEditingController();
  final _chatNameController = TextEditingController();
  final List<String> _selectedUsers = [];

  @override
  void dispose() {
    _searchController.dispose();
    _chatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search contacts...',
              leading: const Icon(Icons.search),
            ),
          ),
          if (_selectedUsers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected (${_selectedUsers.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _selectedUsers.map((user) {
                      return Chip(
                        label: Text(user),
                        onDeleted: () {
                          setState(() => _selectedUsers.remove(user));
                        },
                        avatar: CircleAvatar(
                          child: Text(user[0].toUpperCase()),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedUsers.length > 1)
                    TextField(
                      controller: _chatNameController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'Enter group name',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                final userName = 'User ${index + 1}';
                final isSelected = _selectedUsers.contains(userName);
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((index + 1).toString()),
                  ),
                  title: Text(userName),
                  subtitle: const Text('Available'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUsers.add(userName);
                        } else {
                          _selectedUsers.remove(userName);
                        }
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedUsers.remove(userName);
                      } else {
                        _selectedUsers.add(userName);
                      }
                    });
                  },
                );
              },
            ),
          ),
          if (_selectedUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.check),
                label: const Text('Create Chat'),
              ),
            ),
        ],
      ),
    );
  }
}
