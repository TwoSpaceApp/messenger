import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/features/people/providers/people_provider.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(filteredPeopleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.push('/people/invite'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Search contacts...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                getSearchQueryNotifier().value = value;
              },
            ),
          ),
          Expanded(
            child: peopleAsync.when(
              data: (people) {
                if (people.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No contacts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.push('/people/invite'),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Invite Friends'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    final person = people[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          person.displayName.isNotEmpty
                              ? person.displayName[0]
                              : '?',
                        ),
                      ),
                      title: Text(person.displayName),
                      subtitle: Text(
                        person.isOnline ? 'Online' : 'Offline',
                      ),
                      onTap: () => context.push('/people/${person.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, st) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
